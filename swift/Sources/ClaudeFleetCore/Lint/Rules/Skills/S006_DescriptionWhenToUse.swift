import Foundation

/// S006 — Skill description (or `when_to_use`) should state a trigger
/// for invocation. Flags missing "use when…" / "trigger" / similar cues.
public struct S006_DescriptionWhenToUse: LintRule {
    public static let id = "S006"
    public static let severity: Severity = .warning
    public static let title = "Skill description states a trigger"
    public init() {}

    private static let triggerPhrases = [
        "use when",
        "use this when",
        "when to use",
        "trigger",
        "use proactively",
        "must be used",
        "use for",
    ]

    public func check(_ library: Library) -> [Finding] {
        var out: [Finding] = []
        for skill in library.skills {
            let combined = ((skill.frontmatter.description) + " " + (skill.frontmatter.whenToUse ?? "")).lowercased()
            if combined.trimmingCharacters(in: .whitespaces).isEmpty { continue }
            let hasCue = Self.triggerPhrases.contains(where: { combined.contains($0) })
            if !hasCue {
                out.append(Finding(
                    ruleID: Self.id,
                    severity: Self.severity,
                    path: skill.skillMD,
                    title: "Skill description has no 'when to use' cue",
                    detail: "Description and `when_to_use` lack a trigger phrase. Claude relies on these cues to decide when to load the skill.",
                    suggestedFix: "Add a 'Use when…' or 'Use proactively…' clause."
                ))
            }
        }
        return out
    }
}
