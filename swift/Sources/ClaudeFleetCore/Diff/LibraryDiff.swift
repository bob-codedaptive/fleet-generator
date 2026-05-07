import Foundation

/// Compare two libraries and produce a structured diff focused on what
/// matters for fleet curation: which agents/skills/hooks are unique to
/// each side, and for those present in both, which frontmatter fields
/// differ.
public struct LibraryDiff {
    public struct Section {
        public let kind: String
        public var onlyInA: [String]
        public var onlyInB: [String]
        public var changed: [(name: String, fieldDiffs: [(field: String, a: String, b: String)])]
    }

    public let aRoot: URL
    public let bRoot: URL
    public let agents: Section
    public let skills: Section
    public let hooks: Section

    public static func compute(_ a: Library, _ b: Library) -> LibraryDiff {
        return LibraryDiff(
            aRoot: a.root,
            bRoot: b.root,
            agents: diffAgents(a.agents, b.agents),
            skills: diffSkills(a.skills, b.skills),
            hooks: diffHooks(a.hooks, b.hooks)
        )
    }

    private static func diffAgents(_ a: [Agent], _ b: [Agent]) -> Section {
        let aMap = Dictionary(uniqueKeysWithValues: a.map { ($0.frontmatter.name, $0) })
        let bMap = Dictionary(uniqueKeysWithValues: b.map { ($0.frontmatter.name, $0) })
        let aNames = Set(aMap.keys)
        let bNames = Set(bMap.keys)
        let onlyA = Array(aNames.subtracting(bNames)).sorted()
        let onlyB = Array(bNames.subtracting(aNames)).sorted()
        let common = Array(aNames.intersection(bNames)).sorted()
        var changed: [(String, [(String, String, String)])] = []
        for name in common {
            let diffs = compareAgentFrontmatter(aMap[name]!.frontmatter, bMap[name]!.frontmatter)
            if !diffs.isEmpty { changed.append((name, diffs)) }
        }
        return Section(kind: "agents", onlyInA: onlyA, onlyInB: onlyB, changed: changed)
    }

    private static func diffSkills(_ a: [Skill], _ b: [Skill]) -> Section {
        let aMap = Dictionary(uniqueKeysWithValues: a.map { ($0.frontmatter.name, $0) })
        let bMap = Dictionary(uniqueKeysWithValues: b.map { ($0.frontmatter.name, $0) })
        let aNames = Set(aMap.keys)
        let bNames = Set(bMap.keys)
        let onlyA = Array(aNames.subtracting(bNames)).sorted()
        let onlyB = Array(bNames.subtracting(aNames)).sorted()
        let common = Array(aNames.intersection(bNames)).sorted()
        var changed: [(String, [(String, String, String)])] = []
        for name in common {
            let diffs = compareSkillFrontmatter(aMap[name]!.frontmatter, bMap[name]!.frontmatter)
            if !diffs.isEmpty { changed.append((name, diffs)) }
        }
        return Section(kind: "skills", onlyInA: onlyA, onlyInB: onlyB, changed: changed)
    }

    private static func diffHooks(_ a: [Hook], _ b: [Hook]) -> Section {
        func key(_ h: Hook) -> String { "\(h.event):\(h.matcher ?? "")" }
        let aSet = Set(a.map(key))
        let bSet = Set(b.map(key))
        return Section(
            kind: "hooks",
            onlyInA: Array(aSet.subtracting(bSet)).sorted(),
            onlyInB: Array(bSet.subtracting(aSet)).sorted(),
            changed: []
        )
    }

    private static func compareAgentFrontmatter(_ a: AgentFrontmatter, _ b: AgentFrontmatter) -> [(String, String, String)] {
        var out: [(String, String, String)] = []
        func cmp<T: Equatable & CustomStringConvertible>(_ name: String, _ av: T?, _ bv: T?) {
            if av != bv {
                out.append((name, av.map(String.init(describing:)) ?? "—", bv.map(String.init(describing:)) ?? "—"))
            }
        }
        cmp("description", a.description, b.description)
        cmp("tools", a.tools, b.tools)
        cmp("disallowedTools", a.disallowedTools, b.disallowedTools)
        cmp("model", a.model, b.model)
        cmp("permissionMode", a.permissionMode, b.permissionMode)
        cmp("memory", a.memory, b.memory)
        cmp("effort", a.effort, b.effort)
        cmp("color", a.color, b.color)
        cmp("initialPrompt", a.initialPrompt, b.initialPrompt)
        cmp("status", a.status, b.status)
        cmp("created", a.created, b.created)
        cmp("updated", a.updated, b.updated)
        // Lists
        if (a.skills ?? []) != (b.skills ?? []) {
            out.append(("skills", listFmt(a.skills), listFmt(b.skills)))
        }
        if (a.mcpServers ?? []) != (b.mcpServers ?? []) {
            out.append(("mcpServers", listFmt(a.mcpServers), listFmt(b.mcpServers)))
        }
        return out
    }

    private static func compareSkillFrontmatter(_ a: SkillFrontmatter, _ b: SkillFrontmatter) -> [(String, String, String)] {
        var out: [(String, String, String)] = []
        func cmp<T: Equatable & CustomStringConvertible>(_ name: String, _ av: T?, _ bv: T?) {
            if av != bv {
                out.append((name, av.map(String.init(describing:)) ?? "—", bv.map(String.init(describing:)) ?? "—"))
            }
        }
        cmp("description", a.description, b.description)
        cmp("when_to_use", a.whenToUse, b.whenToUse)
        cmp("model", a.model, b.model)
        cmp("effort", a.effort, b.effort)
        cmp("status", a.status, b.status)
        cmp("created", a.created, b.created)
        cmp("updated", a.updated, b.updated)
        if (a.paths ?? []) != (b.paths ?? []) {
            out.append(("paths", listFmt(a.paths), listFmt(b.paths)))
        }
        if (a.tags ?? []) != (b.tags ?? []) {
            out.append(("tags", listFmt(a.tags), listFmt(b.tags)))
        }
        return out
    }

    private static func listFmt(_ list: [String]?) -> String {
        guard let l = list, !l.isEmpty else { return "—" }
        return "[" + l.joined(separator: ", ") + "]"
    }

    public func textReport() -> String {
        var lines: [String] = []
        lines.append("--- A: \(aRoot.path)")
        lines.append("+++ B: \(bRoot.path)")
        for section in [agents, skills, hooks] {
            lines.append("")
            lines.append("=== \(section.kind) ===")
            if !section.onlyInA.isEmpty {
                lines.append("Only in A:")
                for n in section.onlyInA { lines.append("  - \(n)") }
            }
            if !section.onlyInB.isEmpty {
                lines.append("Only in B:")
                for n in section.onlyInB { lines.append("  + \(n)") }
            }
            if !section.changed.isEmpty {
                lines.append("Changed:")
                for (name, diffs) in section.changed {
                    lines.append("  \(name):")
                    for (field, av, bv) in diffs {
                        lines.append("    \(field): \(truncate(av)) | \(truncate(bv))")
                    }
                }
            }
            if section.onlyInA.isEmpty && section.onlyInB.isEmpty && section.changed.isEmpty {
                lines.append("(no differences)")
            }
        }
        return lines.joined(separator: "\n")
    }

    private func truncate(_ s: String, max: Int = 80) -> String {
        if s.count <= max { return s }
        let idx = s.index(s.startIndex, offsetBy: max - 1)
        return s[..<idx] + "…"
    }
}
