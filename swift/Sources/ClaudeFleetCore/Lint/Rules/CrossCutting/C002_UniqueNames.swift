import Foundation

/// C002 — Skill and agent names should be unique within a library scope.
/// Anthropic precedence rules silently shadow lower-priority duplicates.
public struct C002_UniqueNames: LintRule {
    public static let id = "C002"
    public static let severity: Severity = .warning
    public static let title = "Unique skill and agent names within scope"
    public init() {}

    public func check(_ library: Library) -> [Finding] {
        var out: [Finding] = []
        // Within-kind duplicates
        let agentDupes = duplicates(library.agents.map { $0.frontmatter.name })
        for name in agentDupes {
            for agent in library.agents where agent.frontmatter.name == name {
                out.append(Finding(
                    ruleID: Self.id,
                    severity: Self.severity,
                    path: agent.path,
                    title: "Duplicate agent name '\(name)'",
                    detail: "Two or more agents share the name '\(name)'. Precedence rules will shadow one silently.",
                    suggestedFix: "Rename one of the conflicting agents."
                ))
            }
        }
        let skillDupes = duplicates(library.skills.map { $0.frontmatter.name })
        for name in skillDupes {
            for skill in library.skills where skill.frontmatter.name == name {
                out.append(Finding(
                    ruleID: Self.id,
                    severity: Self.severity,
                    path: skill.skillMD,
                    title: "Duplicate skill name '\(name)'",
                    detail: "Two or more skills share the name '\(name)'.",
                    suggestedFix: "Rename one of the conflicting skills."
                ))
            }
        }
        // Cross-kind: agent name == skill name (uncommon but worth a warning)
        let agentNames = Set(library.agents.map { $0.frontmatter.name })
        for skill in library.skills where agentNames.contains(skill.frontmatter.name) {
            out.append(Finding(
                ruleID: Self.id,
                severity: Self.severity,
                path: skill.skillMD,
                title: "Skill and agent share name '\(skill.frontmatter.name)'",
                detail: "Skills and agents inhabit different namespaces but sharing a name is confusing.",
                suggestedFix: "Pick distinct names for the agent and the skill."
            ))
        }
        return out
    }

    private func duplicates(_ names: [String]) -> Set<String> {
        var seen: [String: Int] = [:]
        for n in names where !n.isEmpty { seen[n, default: 0] += 1 }
        return Set(seen.filter { $0.value > 1 }.keys)
    }
}
