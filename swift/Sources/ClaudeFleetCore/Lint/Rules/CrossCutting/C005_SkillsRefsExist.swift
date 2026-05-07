import Foundation

/// C005 — Skills listed in an agent's `skills:` field must exist in the
/// library (this scope only — cross-scope resolution isn't checked here).
public struct C005_SkillsRefsExist: LintRule {
    public static let id = "C005"
    public static let severity: Severity = .warning
    public static let title = "Agent's `skills:` references exist in library"
    public init() {}

    public func check(_ library: Library) -> [Finding] {
        let known = Set(library.skills.map { $0.frontmatter.name })
        var out: [Finding] = []
        for agent in library.agents {
            for skillName in agent.frontmatter.skills ?? [] {
                let bare = skillName.contains(":") ? String(skillName.split(separator: ":").last ?? Substring(skillName)) : skillName
                if !known.contains(bare) {
                    out.append(Finding(
                        ruleID: Self.id,
                        severity: Self.severity,
                        path: agent.path,
                        title: "Skill '\(skillName)' not found in library",
                        detail: "Agent '\(agent.frontmatter.name)' references skill '\(skillName)', which is not present in this library scope.",
                        suggestedFix: "Add the skill to .claude/skills/ or remove the reference."
                    ))
                }
            }
        }
        return out
    }
}
