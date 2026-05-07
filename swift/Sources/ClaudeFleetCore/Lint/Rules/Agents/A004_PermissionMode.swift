import Foundation

/// A004 — `permissionMode` ∈ valid enum:
/// `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, `plan`.
public struct A004_PermissionMode: LintRule {
    public static let id = "A004"
    public static let severity: Severity = .error
    public static let title = "Agent permissionMode in valid enum"
    public init() {}

    private static let valid: Set<String> = [
        "default", "acceptEdits", "auto", "dontAsk", "bypassPermissions", "plan",
    ]

    public func check(_ library: Library) -> [Finding] {
        var out: [Finding] = []
        for agent in library.agents {
            guard let mode = agent.frontmatter.permissionMode, !mode.isEmpty else { continue }
            if !Self.valid.contains(mode) {
                out.append(Finding(
                    ruleID: Self.id,
                    severity: Self.severity,
                    path: agent.path,
                    title: "Invalid `permissionMode`",
                    detail: "Got '\(mode)'. Allowed: \(Self.valid.sorted().joined(separator: ", ")).",
                    suggestedFix: "Pick one of the documented enum values."
                ))
            }
        }
        return out
    }
}
