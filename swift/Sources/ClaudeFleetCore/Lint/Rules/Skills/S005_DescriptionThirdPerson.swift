import Foundation

/// S005 — Skill description should be in the third person.
/// Flags first-person ("I ", "We ", "My ", "Our ") or second-person openers
/// ("You ", "Your ") in the first ~10 words.
public struct S005_DescriptionThirdPerson: LintRule {
    public static let id = "S005"
    public static let severity: Severity = .warning
    public static let title = "Skill description third-person"
    public init() {}

    private static let firstWordsCount = 10
    private static let badOpeners: Set<String> = [
        "i", "i'll", "i'm", "i've", "we", "we'll", "we've",
        "my", "our", "you", "you'll", "you're", "you've", "your",
    ]

    public func check(_ library: Library) -> [Finding] {
        var out: [Finding] = []
        for skill in library.skills {
            let desc = skill.frontmatter.description
            if desc.isEmpty { continue }
            let words = desc
                .lowercased()
                .components(separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
                .filter { !$0.isEmpty }
                .prefix(Self.firstWordsCount)
            if words.contains(where: { Self.badOpeners.contains($0) }) {
                out.append(Finding(
                    ruleID: Self.id,
                    severity: Self.severity,
                    path: skill.skillMD,
                    title: "Skill description uses first/second-person",
                    detail: "Description opens with first/second-person language. Prefer third-person ('Processes…', not 'I help…' / 'You can…').",
                    suggestedFix: "Rewrite the opening clause in the third person."
                ))
            }
        }
        return out
    }
}
