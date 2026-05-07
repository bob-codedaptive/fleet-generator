import Foundation

/// C003 — MCP tool refs in agent `tools:` should be qualified
/// `mcp__server__tool` (or `Server:tool_name`). Bare `mcp_*` strings are
/// flagged.
public struct C003_MCPRefForm: LintRule {
    public static let id = "C003"
    public static let severity: Severity = .warning
    public static let title = "MCP tool refs are server-qualified"
    public init() {}

    public func check(_ library: Library) -> [Finding] {
        var out: [Finding] = []
        for agent in library.agents {
            let tools = (agent.frontmatter.tools ?? "").split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            for t in tools {
                if t.hasPrefix("mcp_") && !t.hasPrefix("mcp__") {
                    out.append(Finding(
                        ruleID: Self.id,
                        severity: Self.severity,
                        path: agent.path,
                        title: "Unqualified MCP tool reference '\(t)'",
                        detail: "Use the `mcp__<server>__<tool>` (or `Server:tool_name`) form so the right MCP server resolves the tool.",
                        suggestedFix: "Replace '\(t)' with the fully-qualified form."
                    ))
                }
            }
        }
        return out
    }
}
