import Foundation

/// S007 — SKILL.md body should be ≤500 lines.
public struct S007_BodyLines: LintRule {
    public static let id = "S007"
    public static let severity: Severity = .warning
    public static let title = "SKILL.md body ≤500 lines"
    public init() {}

    public func check(_ library: Library) -> [Finding] {
        var out: [Finding] = []
        for skill in library.skills where skill.bodyLines > 500 {
            out.append(Finding(
                ruleID: Self.id,
                severity: Self.severity,
                path: skill.skillMD,
                title: "SKILL.md body exceeds 500 lines",
                detail: "Got \(skill.bodyLines) lines; >500 hurts performance. Split content into sibling reference files.",
                suggestedFix: "Move detail into separate .md files in the skill directory and link to them."
            ))
        }
        return out
    }
}
