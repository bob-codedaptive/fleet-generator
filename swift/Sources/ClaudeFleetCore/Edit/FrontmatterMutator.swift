import Foundation

public enum FrontmatterMutatorError: Error, Equatable {
    case fileMissing
    case noFrontmatter
    case invalidKey(String)
}

/// Mutates YAML frontmatter in-place using line-based replacements when the
/// key is a simple scalar already present, otherwise appends. This keeps git
/// diffs minimal — Yams re-emit is reserved for cases that genuinely need it.
public enum FrontmatterMutator {
    /// Apply one or more `key=value` pairs to a markdown file's frontmatter.
    public static func apply(_ pairs: [(key: String, value: String)], to fileURL: URL) throws {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw FrontmatterMutatorError.fileMissing
        }
        let original = try String(contentsOf: fileURL, encoding: .utf8)
        var updated = original
        for (k, v) in pairs {
            updated = try setValue(v, forKey: k, in: updated)
        }
        if updated != original {
            try updated.write(to: fileURL, atomically: true, encoding: .utf8)
        }
    }

    /// Same as `apply`, but operates on a string and returns the result.
    /// Throws if the input has no frontmatter at all.
    public static func setValue(_ value: String, forKey key: String, in content: String) throws -> String {
        guard isValidKey(key) else { throw FrontmatterMutatorError.invalidKey(key) }
        let split = FrontmatterParser.split(content)
        guard !split.yamlString.isEmpty else {
            throw FrontmatterMutatorError.noFrontmatter
        }
        var yaml = split.yamlString

        let escaped = NSRegularExpression.escapedPattern(for: key)
        let pattern = "^([ \\t]*)\(escaped):[ \\t]*(.*)$"
        let regex = try NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        let range = NSRange(yaml.startIndex..<yaml.endIndex, in: yaml)

        if let match = regex.firstMatch(in: yaml, range: range) {
            // Replace existing simple scalar line, preserving indent. If the
            // match's value range is empty AND the next line is more indented,
            // we have a block scalar (`name: >-` etc.) — fall back to append
            // semantics is wrong; instead, replace the entire block down to
            // the next sibling key.
            let indent: String = (Range(match.range(at: 1), in: yaml).map { String(yaml[$0]) }) ?? ""
            let oldVal: String = (Range(match.range(at: 2), in: yaml).map { String(yaml[$0]) }) ?? ""
            let isBlockScalar = oldVal.hasPrefix(">") || oldVal.hasPrefix("|")
            if isBlockScalar {
                let lineRange = expandToBlockScalar(in: yaml, startingAt: match.range, indent: indent)
                let replacement = "\(indent)\(key): \(formatScalar(value))"
                let nsString = yaml as NSString
                yaml = nsString.replacingCharacters(in: lineRange, with: replacement)
            } else {
                let replacement = "\(indent)\(key): \(formatScalar(value))"
                let nsString = yaml as NSString
                yaml = nsString.replacingCharacters(in: match.range, with: replacement)
            }
        } else {
            // Key not present — append a new top-level line.
            let suffix = yaml.hasSuffix("\n") ? "" : "\n"
            yaml = yaml + "\(suffix)\(key): \(formatScalar(value))"
        }

        return "---\n\(yaml)\n---\n\(split.body)"
    }

    // MARK: - Helpers

    private static func isValidKey(_ key: String) -> Bool {
        guard !key.isEmpty else { return false }
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-")
        return key.unicodeScalars.allSatisfy { allowed.contains($0) }
    }

    /// Quote when YAML would interpret the value as something other than a
    /// plain string, or when it contains characters that need escaping.
    static func formatScalar(_ s: String) -> String {
        if s.isEmpty { return "''" }
        let leading = s.first ?? " "
        let trailing = s.last ?? " "
        let problematicLeads: Set<Character> = ["-", "?", ":", ",", "[", "]", "{", "}", "#", "&", "*", "!", "|", ">", "'", "\"", "%", "@", "`"]
        if leading.isWhitespace || trailing.isWhitespace { return quote(s) }
        if problematicLeads.contains(leading) { return quote(s) }
        if s.contains(": ") || s.contains(" #") || s.contains("\n") { return quote(s) }
        // Reserved literal forms — quote so they stay strings.
        let reserved: Set<String> = ["null", "Null", "NULL", "~", "true", "True", "TRUE", "false", "False", "FALSE", "yes", "Yes", "YES", "no", "No", "NO", "on", "On", "ON", "off", "Off", "OFF"]
        if reserved.contains(s) { return quote(s) }
        return s
    }

    private static func quote(_ s: String) -> String {
        let escaped = s.replacingOccurrences(of: "'", with: "''")
        return "'\(escaped)'"
    }

    /// Expand a regex match range to cover a block-scalar (`key: >-` followed
    /// by indented continuation lines) up to the next sibling key.
    private static func expandToBlockScalar(in yaml: String, startingAt initial: NSRange, indent: String) -> NSRange {
        let nsYaml = yaml as NSString
        let totalLen = nsYaml.length
        var end = initial.location + initial.length
        while end < totalLen {
            // Find next newline + look at the following line
            let next = nsYaml.range(of: "\n", options: [], range: NSRange(location: end, length: totalLen - end))
            if next.location == NSNotFound { break }
            let lineStart = next.location + 1
            if lineStart >= totalLen { break }
            // Determine the continuation: a block scalar continues while the
            // line is more indented than the parent OR is blank.
            let lineEndRange = nsYaml.range(of: "\n", options: [], range: NSRange(location: lineStart, length: totalLen - lineStart))
            let lineEnd = lineEndRange.location == NSNotFound ? totalLen : lineEndRange.location
            let line = nsYaml.substring(with: NSRange(location: lineStart, length: lineEnd - lineStart))
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty {
                end = lineEnd
                continue
            }
            // If next line starts with deeper indent than the parent, it's part of the block.
            let leadingWS = String(line.prefix { $0 == " " || $0 == "\t" })
            if leadingWS.count > indent.count {
                end = lineEnd
                continue
            }
            break
        }
        return NSRange(location: initial.location, length: end - initial.location)
    }
}
