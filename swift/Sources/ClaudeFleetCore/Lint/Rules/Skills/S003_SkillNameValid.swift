import Foundation

/// S003 — `name` matches `^[a-z0-9-]{1,64}$` and is not reserved
/// (`anthropic*` or `claude*`).
public struct S003_SkillNameValid: LintRule {
    public static let id = "S003"
    public static let severity: Severity = .error
    public static let title = "Skill name regex + reserved-word check"
    public init() {}

    private static let pattern = try! NSRegularExpression(pattern: "^[a-z0-9-]{1,64}$")

    public func check(_ library: Library) -> [Finding] {
        var out: [Finding] = []
        for skill in library.skills {
            let name = skill.frontmatter.name
            let range = NSRange(name.startIndex..<name.endIndex, in: name)
            let matches = Self.pattern.firstMatch(in: name, range: range) != nil
            if !matches {
                out.append(Finding(
                    ruleID: Self.id,
                    severity: Self.severity,
                    path: skill.skillMD,
                    title: "Skill name violates `^[a-z0-9-]{1,64}$`",
                    detail: "Got '\(name)'. Use lowercase letters, digits, and hyphens only; max 64 chars.",
                    suggestedFix: "Rename the skill directory and `name:` field to kebab-case."
                ))
            }
            let lower = name.lowercased()
            if lower.hasPrefix("anthropic") || lower.hasPrefix("claude") {
                out.append(Finding(
                    ruleID: Self.id,
                    severity: Self.severity,
                    path: skill.skillMD,
                    title: "Skill name uses reserved prefix",
                    detail: "Names starting with 'anthropic' or 'claude' are reserved.",
                    suggestedFix: "Pick a non-reserved name."
                ))
            }
        }
        return out
    }
}
