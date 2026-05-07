import Foundation

/// S008 — Reference links from SKILL.md should be at most one level deep.
/// SKILL.md → A.md is fine; SKILL.md → A.md → B.md is not.
public struct S008_ReferenceDepth: LintRule {
    public static let id = "S008"
    public static let severity: Severity = .warning
    public static let title = "Reference links one level deep from SKILL.md"
    public init() {}

    private static let mdLink = try! NSRegularExpression(pattern: #"\[[^\]]*\]\(([^)]+\.md)\)"#)

    public func check(_ library: Library) -> [Finding] {
        var out: [Finding] = []
        for skill in library.skills {
            let firstLevel = mdLinks(in: skill.body)
            for relPath in firstLevel {
                let target = skill.directory.appendingPathComponent(relPath).standardizedFileURL
                guard FileManager.default.fileExists(atPath: target.path) else { continue }
                guard let body = try? String(contentsOf: target, encoding: .utf8) else { continue }
                let nested = mdLinks(in: body).filter { $0.lowercased() != "skill.md" }
                if !nested.isEmpty {
                    out.append(Finding(
                        ruleID: Self.id,
                        severity: Self.severity,
                        path: target,
                        title: "Reference file links to further .md files",
                        detail: "SKILL.md → \(relPath) → \(nested.joined(separator: ", ")). Keep references one level from SKILL.md.",
                        suggestedFix: "Inline the deeper content into \(relPath) or restructure the references."
                    ))
                }
            }
        }
        return out
    }

    private func mdLinks(in body: String) -> [String] {
        let range = NSRange(body.startIndex..<body.endIndex, in: body)
        let matches = Self.mdLink.matches(in: body, range: range)
        var out: [String] = []
        for m in matches where m.numberOfRanges >= 2 {
            if let r = Range(m.range(at: 1), in: body) {
                let raw = String(body[r])
                if raw.hasPrefix("http://") || raw.hasPrefix("https://") { continue }
                out.append(raw)
            }
        }
        return out
    }
}
