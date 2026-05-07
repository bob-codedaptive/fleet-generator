import Foundation

/// A003 — `model` ∈ alias (`sonnet`/`opus`/`haiku`), full ID
/// (`claude-...`), or `inherit`.
public struct A003_ModelValid: LintRule {
    public static let id = "A003"
    public static let severity: Severity = .error
    public static let title = "Agent model is valid alias / full ID / inherit"
    public init() {}

    private static let aliases: Set<String> = ["sonnet", "opus", "haiku", "inherit"]

    public func check(_ library: Library) -> [Finding] {
        var out: [Finding] = []
        for agent in library.agents {
            guard let model = agent.frontmatter.model, !model.isEmpty else { continue }
            let isAlias = Self.aliases.contains(model.lowercased())
            let isFullID = model.hasPrefix("claude-")
            if !isAlias && !isFullID {
                out.append(Finding(
                    ruleID: Self.id,
                    severity: Self.severity,
                    path: agent.path,
                    title: "Invalid `model` value",
                    detail: "Got '\(model)'. Must be one of sonnet|opus|haiku|inherit, or a full model ID starting with 'claude-'.",
                    suggestedFix: "Set `model: inherit` to inherit from the parent session."
                ))
            }
        }
        return out
    }
}
