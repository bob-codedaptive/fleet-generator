import Foundation

/// S009 — File paths in SKILL.md must use forward slashes; backslash paths
/// like `scripts\helper.py` are flagged.
public struct S009_BackslashPaths: LintRule {
    public static let id = "S009"
    public static let severity: Severity = .warning
    public static let title = "No backslash paths in SKILL.md"
    public init() {}

    private static let backslashPath = try! NSRegularExpression(
        pattern: #"[a-zA-Z0-9_.-]+\\[a-zA-Z0-9_./\\-]+"#
    )

    public func check(_ library: Library) -> [Finding] {
        var out: [Finding] = []
        for skill in library.skills {
            let body = skill.body
            let range = NSRange(body.startIndex..<body.endIndex, in: body)
            let matches = Self.backslashPath.matches(in: body, range: range)
            if !matches.isEmpty {
                let samples = matches.prefix(3).compactMap { m -> String? in
                    guard let r = Range(m.range, in: body) else { return nil }
                    return String(body[r])
                }
                out.append(Finding(
                    ruleID: Self.id,
                    severity: Self.severity,
                    path: skill.skillMD,
                    title: "Backslash file paths in SKILL.md",
                    detail: "Found Windows-style paths: \(samples.joined(separator: ", "))",
                    suggestedFix: "Use forward slashes (`scripts/helper.py`)."
                ))
            }
        }
        return out
    }
}
