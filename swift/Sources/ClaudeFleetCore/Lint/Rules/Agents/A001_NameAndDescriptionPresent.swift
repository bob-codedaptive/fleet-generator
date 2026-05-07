import Foundation

/// A001 — Agent must declare both `name` and `description` in frontmatter.
public struct A001_NameAndDescriptionPresent: LintRule {
    public static let id = "A001"
    public static let severity: Severity = .error
    public static let title = "Agent name and description present"
    public init() {}

    public func check(_ library: Library) -> [Finding] {
        var out: [Finding] = []
        for agent in library.agents {
            if agent.frontmatter.name.isEmpty {
                out.append(Finding(
                    ruleID: Self.id,
                    severity: Self.severity,
                    path: agent.path,
                    title: "Agent missing `name`",
                    detail: "Agent at \(agent.path.lastPathComponent) has empty `name`.",
                    suggestedFix: "Add `name: <kebab-case-id>` to frontmatter."
                ))
            }
            if agent.frontmatter.description.isEmpty {
                out.append(Finding(
                    ruleID: Self.id,
                    severity: Self.severity,
                    path: agent.path,
                    title: "Agent missing `description`",
                    detail: "Agent '\(agent.frontmatter.name)' has empty `description`.",
                    suggestedFix: "Add a `description:` describing when to delegate to this agent."
                ))
            }
        }
        return out
    }
}
