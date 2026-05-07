import Foundation

/// S010 — Prefer gerund-form skill names. Flags vague suffixes/words like
/// `helper`, `utils`, `tools`, `documents`.
public struct S010_GerundForm: LintRule {
    public static let id = "S010"
    public static let severity: Severity = .info
    public static let title = "Skill name prefer gerund form"
    public init() {}

    private static let vague: Set<String> = ["helper", "helpers", "utils", "util", "tools", "tool", "documents", "document"]

    public func check(_ library: Library) -> [Finding] {
        var out: [Finding] = []
        for skill in library.skills {
            let name = skill.frontmatter.name.lowercased()
            let parts = name.split(separator: "-").map(String.init)
            let hits = parts.filter { Self.vague.contains($0) }
            if !hits.isEmpty {
                out.append(Finding(
                    ruleID: Self.id,
                    severity: Self.severity,
                    path: skill.skillMD,
                    title: "Skill name uses vague term(s)",
                    detail: "Components \(hits) are vague. Anthropic recommends gerund-form names (e.g. `processing-pdfs`).",
                    suggestedFix: "Rename to a gerund form describing the action."
                ))
            }
        }
        return out
    }
}
