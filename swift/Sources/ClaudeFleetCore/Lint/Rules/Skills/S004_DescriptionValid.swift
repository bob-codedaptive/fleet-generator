import Foundation

/// S004 — Skill `description` present, ≤1024 chars, no XML tags.
public struct S004_DescriptionValid: LintRule {
    public static let id = "S004"
    public static let severity: Severity = .error
    public static let title = "Skill description present, ≤1024 chars, no XML"
    public init() {}

    private static let xmlTag = try! NSRegularExpression(pattern: "</?[a-zA-Z][a-zA-Z0-9_:-]*[^>]*>")

    public func check(_ library: Library) -> [Finding] {
        var out: [Finding] = []
        for skill in library.skills {
            let desc = skill.frontmatter.description
            if desc.isEmpty {
                out.append(Finding(
                    ruleID: Self.id,
                    severity: Self.severity,
                    path: skill.skillMD,
                    title: "Skill description missing",
                    detail: "Skill '\(skill.frontmatter.name)' has empty `description`.",
                    suggestedFix: "Add a third-person description with a 'use when…' trigger."
                ))
                continue
            }
            if desc.count > 1024 {
                out.append(Finding(
                    ruleID: Self.id,
                    severity: Self.severity,
                    path: skill.skillMD,
                    title: "Skill description exceeds 1024 chars",
                    detail: "Got \(desc.count) chars; max 1024.",
                    suggestedFix: "Trim or move detail into SKILL.md body."
                ))
            }
            let range = NSRange(desc.startIndex..<desc.endIndex, in: desc)
            if Self.xmlTag.firstMatch(in: desc, range: range) != nil {
                out.append(Finding(
                    ruleID: Self.id,
                    severity: Self.severity,
                    path: skill.skillMD,
                    title: "Skill description contains XML tags",
                    detail: "Description must not include XML tags.",
                    suggestedFix: "Remove markup from the description."
                ))
            }
        }
        return out
    }
}
