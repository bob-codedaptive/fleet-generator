import Foundation

/// A007 — Agent description carries a "Use proactively" / "Use when…" cue
/// to help the orchestrator decide when to delegate.
public struct A007_DescriptionUseCue: LintRule {
    public static let id = "A007"
    public static let severity: Severity = .info
    public static let title = "Agent description has a 'use when' cue"
    public init() {}

    private static let cues = [
        "use when", "use proactively", "must be used", "use this when",
        "trigger when", "use for", "spawn when",
    ]

    public func check(_ library: Library) -> [Finding] {
        var out: [Finding] = []
        for agent in library.agents {
            let desc = agent.frontmatter.description.lowercased()
            if desc.isEmpty { continue }
            if !Self.cues.contains(where: { desc.contains($0) }) {
                out.append(Finding(
                    ruleID: Self.id,
                    severity: Self.severity,
                    path: agent.path,
                    title: "Agent description has no delegation cue",
                    detail: "No 'use when' / 'use proactively' / 'must be used' cue in description.",
                    suggestedFix: "Add a clause describing when the orchestrator should delegate to this agent."
                ))
            }
        }
        return out
    }
}
