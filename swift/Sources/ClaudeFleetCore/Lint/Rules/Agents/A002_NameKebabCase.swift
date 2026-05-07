import Foundation

/// A002 — Agent `name` is a kebab-case identifier (`^[a-z0-9-]+$`).
public struct A002_NameKebabCase: LintRule {
    public static let id = "A002"
    public static let severity: Severity = .error
    public static let title = "Agent name kebab-case"
    public init() {}

    private static let pattern = try! NSRegularExpression(pattern: "^[a-z0-9-]+$")

    public func check(_ library: Library) -> [Finding] {
        var out: [Finding] = []
        for agent in library.agents {
            let name = agent.frontmatter.name
            if name.isEmpty { continue }
            let range = NSRange(name.startIndex..<name.endIndex, in: name)
            if Self.pattern.firstMatch(in: name, range: range) == nil {
                out.append(Finding(
                    ruleID: Self.id,
                    severity: Self.severity,
                    path: agent.path,
                    title: "Agent name not kebab-case",
                    detail: "Got '\(name)'. Use lowercase letters, digits, and hyphens.",
                    suggestedFix: "Rename the file and `name:` field to kebab-case."
                ))
            }
        }
        return out
    }
}
