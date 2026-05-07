import Foundation
import Yams

public enum FrontmatterError: Error, Equatable {
    case missingFrontmatter
    case malformedFrontmatter(String)
    case yamlParseFailure(String)
}

public struct FrontmatterSplit {
    public let yamlString: String
    public let body: String
}

public enum FrontmatterParser {
    /// Splits a markdown file into (YAML frontmatter, body). Frontmatter is
    /// the block between an opening `---` and the next `---`, both on their
    /// own line at the very start of the file. If no frontmatter, returns the
    /// whole file as `body` and empty `yamlString`.
    public static func split(_ content: String) -> FrontmatterSplit {
        // Tolerate BOM and CRLF line endings.
        var s = content
        if s.hasPrefix("\u{FEFF}") {
            s.removeFirst()
        }
        let lines = s.components(separatedBy: "\n").map { line -> String in
            line.hasSuffix("\r") ? String(line.dropLast()) : line
        }
        guard lines.first == "---" else {
            return FrontmatterSplit(yamlString: "", body: content)
        }
        var endIdx: Int? = nil
        for i in 1..<lines.count {
            if lines[i] == "---" {
                endIdx = i
                break
            }
        }
        guard let end = endIdx else {
            return FrontmatterSplit(yamlString: "", body: content)
        }
        let yaml = lines[1..<end].joined(separator: "\n")
        let body = lines[(end + 1)...].joined(separator: "\n")
        return FrontmatterSplit(yamlString: yaml, body: body)
    }

    /// Parse the YAML frontmatter into a dictionary. Returns empty dict for
    /// empty input. Throws on malformed YAML.
    public static func parseDict(_ yamlString: String) throws -> [String: Any] {
        let trimmed = yamlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return [:] }
        do {
            let loaded = try Yams.load(yaml: yamlString)
            if loaded == nil { return [:] }
            guard let dict = loaded as? [String: Any] else {
                throw FrontmatterError.malformedFrontmatter("frontmatter is not a YAML mapping")
            }
            return dict
        } catch let yamsErr as YamlError {
            throw FrontmatterError.yamlParseFailure(String(describing: yamsErr))
        }
    }
}
