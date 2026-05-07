import Foundation

/// A005 — Plugin-located agents must not declare `hooks`, `mcpServers`, or
/// `permissionMode` (these fields are silently ignored when an agent ships
/// inside a plugin manifest).
public struct A005_PluginNoLifecycle: LintRule {
    public static let id = "A005"
    public static let severity: Severity = .warning
    public static let title = "Plugin agent has no hooks/mcpServers/permissionMode"
    public init() {}

    public func check(_ library: Library) -> [Finding] {
        guard library.scope == .plugin else { return [] }
        var out: [Finding] = []
        for agent in library.agents {
            var bad: [String] = []
            if (agent.frontmatter.hooks ?? []).isEmpty == false { bad.append("hooks") }
            if (agent.frontmatter.mcpServers ?? []).isEmpty == false { bad.append("mcpServers") }
            if let pm = agent.frontmatter.permissionMode, !pm.isEmpty { bad.append("permissionMode") }
            if !bad.isEmpty {
                out.append(Finding(
                    ruleID: Self.id,
                    severity: Self.severity,
                    path: agent.path,
                    title: "Plugin agent declares ignored field(s)",
                    detail: "Plugin agents silently ignore: \(bad.joined(separator: ", ")).",
                    suggestedFix: "Remove these fields or move the agent out of the plugin."
                ))
            }
        }
        return out
    }
}
