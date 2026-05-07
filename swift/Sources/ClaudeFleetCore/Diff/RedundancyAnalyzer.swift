import Foundation

/// R001–R005 redundancy / dialect-drift detectors. These run as a single
/// `LintRule`-shaped struct so RuleEngine can include them, but they're
/// also exposed via `anvil redundancy` for a focused report.
public struct RedundancyAnalyzer: LintRule {
    public static let id = "R*"
    public static let severity: Severity = .warning
    public static let title = "Redundancy / dialect-drift detectors"
    public init() {}

    public func check(_ library: Library) -> [Finding] {
        var out: [Finding] = []
        out.append(contentsOf: r001(library))
        out.append(contentsOf: r002(library))
        out.append(contentsOf: r003(library))
        out.append(contentsOf: r004(library))
        out.append(contentsOf: r005(library))
        return out
    }

    /// R001 — Same name appears as both `skills/<name>/SKILL.md` and
    /// `commands/<name>.md`. Skills win; the command is dead weight.
    public func r001(_ library: Library) -> [Finding] {
        let skillNames = Set(library.skills.map { $0.frontmatter.name })
        var out: [Finding] = []
        for cmd in library.commands where skillNames.contains(cmd.name) {
            out.append(Finding(
                ruleID: "R001",
                severity: .warning,
                path: cmd.path,
                title: "Legacy command '\(cmd.name)' shadowed by skill of same name",
                detail: "Both .claude/commands/\(cmd.name).md and .claude/skills/\(cmd.name)/SKILL.md exist. The skill wins.",
                suggestedFix: "Delete .claude/commands/\(cmd.name).md."
            ))
        }
        return out
    }

    /// R002 — Two skills whose descriptions have a Jaccard token-overlap
    /// of ≥ 0.6.
    public func r002(_ library: Library) -> [Finding] {
        var out: [Finding] = []
        let skills = library.skills
        for i in 0..<skills.count {
            for j in (i + 1)..<skills.count {
                let a = tokens(skills[i].frontmatter.description + " " + (skills[i].frontmatter.whenToUse ?? ""))
                let b = tokens(skills[j].frontmatter.description + " " + (skills[j].frontmatter.whenToUse ?? ""))
                guard !a.isEmpty, !b.isEmpty else { continue }
                let jac = jaccard(a, b)
                if jac >= 0.6 {
                    out.append(Finding(
                        ruleID: "R002",
                        severity: .info,
                        path: skills[j].skillMD,
                        title: "Skill descriptions ~\(Int(jac * 100))% overlap",
                        detail: "'\(skills[i].frontmatter.name)' and '\(skills[j].frontmatter.name)' have very similar descriptions.",
                        suggestedFix: "Confirm they're not duplicates; merge or differentiate."
                    ))
                }
            }
        }
        return out
    }

    /// R003 — Two skills declare overlapping `paths:` globs (any identical
    /// glob string between them).
    public func r003(_ library: Library) -> [Finding] {
        var out: [Finding] = []
        let skills = library.skills
        for i in 0..<skills.count {
            guard let a = skills[i].frontmatter.paths, !a.isEmpty else { continue }
            for j in (i + 1)..<skills.count {
                guard let b = skills[j].frontmatter.paths, !b.isEmpty else { continue }
                let shared = Set(a).intersection(b)
                if !shared.isEmpty {
                    out.append(Finding(
                        ruleID: "R003",
                        severity: .info,
                        path: skills[j].skillMD,
                        title: "Skills share `paths:` globs",
                        detail: "'\(skills[i].frontmatter.name)' and '\(skills[j].frontmatter.name)' both match: \(shared.sorted().joined(separator: ", "))",
                        suggestedFix: "Tighten globs or consolidate the skills."
                    ))
                }
            }
        }
        return out
    }

    /// R004 — Two agents with identical `tools` AND overlapping description.
    public func r004(_ library: Library) -> [Finding] {
        var out: [Finding] = []
        let agents = library.agents
        for i in 0..<agents.count {
            for j in (i + 1)..<agents.count {
                let ai = agents[i].frontmatter
                let aj = agents[j].frontmatter
                let tools_i = (ai.tools ?? "").trimmingCharacters(in: .whitespaces)
                let tools_j = (aj.tools ?? "").trimmingCharacters(in: .whitespaces)
                guard !tools_i.isEmpty, tools_i == tools_j else { continue }
                let jac = jaccard(tokens(ai.description), tokens(aj.description))
                if jac >= 0.4 {
                    out.append(Finding(
                        ruleID: "R004",
                        severity: .info,
                        path: agents[j].path,
                        title: "Agents share tools and overlapping descriptions",
                        detail: "'\(ai.name)' and '\(aj.name)' have the same `tools` and ~\(Int(jac * 100))% description overlap.",
                        suggestedFix: "Confirm the agents aren't duplicates."
                    ))
                }
            }
        }
        return out
    }

    /// R005 — Two settings.json hook entries with the same event AND matcher.
    public func r005(_ library: Library) -> [Finding] {
        var out: [Finding] = []
        var seen: [String: [Hook]] = [:]
        for h in library.hooks {
            let key = "\(h.event)::\(h.matcher ?? "")"
            seen[key, default: []].append(h)
        }
        for (key, group) in seen where group.count > 1 {
            let path = group.first?.sourcePath ?? library.settings?.path ?? library.root
            out.append(Finding(
                ruleID: "R005",
                severity: .warning,
                path: path,
                title: "Multiple hooks share event+matcher \(key)",
                detail: "\(group.count) hook entries match. Only one fires deterministically per event.",
                suggestedFix: "Combine the commands or split the matchers."
            ))
        }
        return out
    }

    // MARK: - Helpers

    private func tokens(_ s: String) -> Set<String> {
        let lowered = s.lowercased()
        let parts = lowered
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count >= 3 }
        return Set(parts)
    }

    private func jaccard(_ a: Set<String>, _ b: Set<String>) -> Double {
        if a.isEmpty && b.isEmpty { return 0 }
        let inter = Double(a.intersection(b).count)
        let union = Double(a.union(b).count)
        return union > 0 ? inter / union : 0
    }
}
