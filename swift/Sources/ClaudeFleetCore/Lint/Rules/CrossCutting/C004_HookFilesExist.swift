import Foundation

/// C004 — Hook commands referenced in `settings.json` must point to existing
/// files (when they look like file paths). Skips obvious shell built-ins.
public struct C004_HookFilesExist: LintRule {
    public static let id = "C004"
    public static let severity: Severity = .error
    public static let title = "settings.json hook scripts exist on disk"
    public init() {}

    public func check(_ library: Library) -> [Finding] {
        guard let settings = library.settings else { return [] }
        let claudeRoot = library.root
        let projectRoot = claudeRoot.deletingLastPathComponent()
        var out: [Finding] = []

        for hook in library.hooks {
            guard let path = scriptPath(from: hook.command) else { continue }
            let candidates = candidatePaths(for: path, claudeRoot: claudeRoot, projectRoot: projectRoot)
            let exists = candidates.contains { FileManager.default.fileExists(atPath: $0.path) }
            if !exists {
                out.append(Finding(
                    ruleID: Self.id,
                    severity: Self.severity,
                    path: settings.path,
                    title: "Hook script not found: \(path)",
                    detail: "Hook for event '\(hook.event)' references '\(path)', which is missing on disk.",
                    suggestedFix: "Create the script or update the hook's `command`."
                ))
            }
        }
        return out
    }

    /// Pull the first whitespace-delimited script path out of a command, if
    /// it looks file-pathy. Skip if the first token starts with `$`, `(`,
    /// or contains no path separator and isn't a recognizable script ext.
    private func scriptPath(from command: String) -> String? {
        let stripped = command
            .replacingOccurrences(of: "\"", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let firstToken = stripped.split(separator: " ", maxSplits: 1).first.map(String.init) ?? stripped
        guard !firstToken.isEmpty else { return nil }
        if firstToken.hasPrefix("$") { return nil }
        if firstToken.contains("$") || firstToken.contains("(") { return nil }
        let scriptExts = [".sh", ".py", ".rb", ".js", ".ts", ".mjs", ".bash", ".zsh"]
        let looksScripty = firstToken.contains("/") || scriptExts.contains(where: { firstToken.hasSuffix($0) })
        return looksScripty ? firstToken : nil
    }

    private func candidatePaths(for path: String, claudeRoot: URL, projectRoot: URL) -> [URL] {
        var resolved = path
        resolved = resolved.replacingOccurrences(of: "$CLAUDE_PROJECT_DIR/", with: "")
        resolved = resolved.replacingOccurrences(of: "${CLAUDE_PROJECT_DIR}/", with: "")
        resolved = resolved.replacingOccurrences(of: #"\/"#, with: "/")
        if resolved.hasPrefix("/") {
            return [URL(fileURLWithPath: resolved)]
        }
        return [
            projectRoot.appendingPathComponent(resolved),
            claudeRoot.appendingPathComponent(resolved),
        ]
    }
}
