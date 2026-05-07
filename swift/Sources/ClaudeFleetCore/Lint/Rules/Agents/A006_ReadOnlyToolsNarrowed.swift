import Foundation

/// A006 — Agents whose name implies read-only work should narrow `tools`
/// (or use `disallowedTools`) to drop Write/Edit. Info-level heuristic.
public struct A006_ReadOnlyToolsNarrowed: LintRule {
    public static let id = "A006"
    public static let severity: Severity = .info
    public static let title = "Read-only-implying agent narrows tools"
    public init() {}

    private static let cues = ["review", "explore", "research", "lint", "audit", "analyze", "analyse", "inspect"]
    private static let mutating = ["Write", "Edit", "MultiEdit"]

    public func check(_ library: Library) -> [Finding] {
        var out: [Finding] = []
        for agent in library.agents {
            let name = agent.frontmatter.name.lowercased()
            guard Self.cues.contains(where: { name.contains($0) }) else { continue }
            let tools = agent.frontmatter.tools ?? ""
            let disallowed = agent.frontmatter.disallowedTools ?? ""
            // If tools is empty, agent inherits everything → flag.
            if tools.isEmpty {
                out.append(Finding(
                    ruleID: Self.id,
                    severity: Self.severity,
                    path: agent.path,
                    title: "Read-only-implying agent inherits full tool set",
                    detail: "Agent '\(agent.frontmatter.name)' name implies read-only work but inherits all tools.",
                    suggestedFix: "Set `tools:` to an explicit allow-list or `disallowedTools: Write, Edit, MultiEdit`."
                ))
                continue
            }
            // If tools includes any mutating tool and they aren't disallowed elsewhere, flag.
            for m in Self.mutating {
                if tools.contains(m) && !disallowed.contains(m) {
                    out.append(Finding(
                        ruleID: Self.id,
                        severity: Self.severity,
                        path: agent.path,
                        title: "Read-only-implying agent allows '\(m)'",
                        detail: "Agent '\(agent.frontmatter.name)' name implies read-only work but `tools` includes '\(m)'.",
                        suggestedFix: "Remove '\(m)' from `tools` or list it in `disallowedTools`."
                    ))
                }
            }
        }
        return out
    }
}
