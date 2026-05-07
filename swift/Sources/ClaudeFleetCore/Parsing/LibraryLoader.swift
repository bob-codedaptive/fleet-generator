import Foundation

public enum LoadError: Error {
    case rootMissing(URL)
    case rootNotADirectory(URL)
}

public enum LibraryLoader {
    /// Load a Library from a `.claude/` directory (or any directory containing
    /// agents/, skills/, settings.json, etc.). Returns a populated Library
    /// even when individual files fail to parse — the failures land in
    /// `loadFindings` so they can surface through the lint engine.
    public static func load(_ root: URL) throws -> Library {
        let fm = FileManager.default
        var isDir: ObjCBool = false
        guard fm.fileExists(atPath: root.path, isDirectory: &isDir) else {
            throw LoadError.rootMissing(root)
        }
        guard isDir.boolValue else {
            throw LoadError.rootNotADirectory(root)
        }

        var findings: [Finding] = []

        let scope: Scope = {
            // Crude scope inference from the path.
            let p = root.path
            if p.contains("/.claude/plugins/") { return .plugin }
            if p.hasPrefix(NSHomeDirectory() + "/.claude") { return .user }
            if p.hasSuffix("/.claude") { return .project }
            return .unknown
        }()

        let agentsDir = root.appendingPathComponent("agents", isDirectory: true)
        let skillsDir = root.appendingPathComponent("skills", isDirectory: true)
        let commandsDir = root.appendingPathComponent("commands", isDirectory: true)
        let rulesDir = root.appendingPathComponent("rules", isDirectory: true)
        let settingsURL = root.appendingPathComponent("settings.json")

        let agents = loadAgents(in: agentsDir, findings: &findings)
        let skills = loadSkills(in: skillsDir, findings: &findings)
        let commands = loadCommands(in: commandsDir)
        let rules = loadRuleDocs(in: rulesDir)
        let settings = loadSettings(at: settingsURL, findings: &findings)
        let hooks = settings?.hooks ?? []

        return Library(
            root: root,
            scope: scope,
            agents: agents,
            skills: skills,
            hooks: hooks,
            settings: settings,
            rules: rules,
            commands: commands,
            loadFindings: findings
        )
    }

    // MARK: - Agents

    private static func loadAgents(in dir: URL, findings: inout [Finding]) -> [Agent] {
        guard FileManager.default.fileExists(atPath: dir.path) else { return [] }
        var out: [Agent] = []
        for url in mdFiles(in: dir) {
            guard let raw = try? String(contentsOf: url, encoding: .utf8) else { continue }
            let split = FrontmatterParser.split(raw)
            do {
                let dict = try FrontmatterParser.parseDict(split.yamlString)
                let fm = parseAgentFrontmatter(dict, fallbackName: url.deletingPathExtension().lastPathComponent)
                out.append(Agent(path: url, frontmatter: fm, body: split.body, rawYAML: split.yamlString))
            } catch {
                findings.append(Finding(
                    ruleID: "S002",
                    severity: .error,
                    path: url,
                    title: "Agent frontmatter failed to parse",
                    detail: "\(error)"
                ))
            }
        }
        return out
    }

    private static func parseAgentFrontmatter(_ d: [String: Any], fallbackName: String) -> AgentFrontmatter {
        var unknown = d
        let name = (d["name"] as? String) ?? fallbackName
        let desc = (d["description"] as? String) ?? ""
        unknown.removeValue(forKey: "name")
        unknown.removeValue(forKey: "description")

        func takeString(_ k: String) -> String? {
            let v = unknown.removeValue(forKey: k)
            return v as? String
        }
        func takeStringList(_ k: String) -> [String]? {
            guard let v = unknown.removeValue(forKey: k) else { return nil }
            if let arr = v as? [String] { return arr }
            if let arr = v as? [Any] { return arr.compactMap { $0 as? String } }
            if let s = v as? String { return s.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } }
            return nil
        }
        func takeInt(_ k: String) -> Int? {
            guard let v = unknown.removeValue(forKey: k) else { return nil }
            return v as? Int
        }
        func takeBool(_ k: String) -> Bool? {
            guard let v = unknown.removeValue(forKey: k) else { return nil }
            return v as? Bool
        }
        func takeStringOrCSV(_ k: String) -> String? {
            guard let v = unknown.removeValue(forKey: k) else { return nil }
            if let s = v as? String { return s }
            if let arr = v as? [Any] {
                return arr.compactMap { $0 as? String }.joined(separator: ", ")
            }
            return nil
        }

        let tools = takeStringOrCSV("tools")
        let disallowed = takeStringOrCSV("disallowedTools")
        let model = takeString("model")
        let permMode = takeString("permissionMode")
        let maxTurns = takeInt("maxTurns")
        let skills = takeStringList("skills")
        let mcpServers = takeStringList("mcpServers")
        let memory = takeString("memory")
        let background = takeBool("background")
        let effort = takeString("effort")
        let isolation = takeString("isolation")
        let color = takeString("color")
        let initialPrompt = takeString("initialPrompt")
        let status = takeString("status")
        let updated = takeStringOrDate("updated", from: &unknown)
        let created = takeStringOrDate("created", from: &unknown)

        // hooks: map of event -> [{matcher?, command}] OR flat list — keep loose for v1
        var agentHooks: [HookEntry]? = nil
        if let raw = unknown.removeValue(forKey: "hooks") {
            agentHooks = parseHooksList(raw)
        }

        return AgentFrontmatter(
            name: name,
            description: desc,
            tools: tools,
            disallowedTools: disallowed,
            model: model,
            permissionMode: permMode,
            maxTurns: maxTurns,
            skills: skills,
            mcpServers: mcpServers,
            hooks: agentHooks,
            memory: memory,
            background: background,
            effort: effort,
            isolation: isolation,
            color: color,
            initialPrompt: initialPrompt,
            status: status,
            updated: updated,
            created: created,
            unknownKeys: unknown
        )
    }

    private static func takeStringOrDate(_ k: String, from d: inout [String: Any]) -> String? {
        guard let v = d.removeValue(forKey: k) else { return nil }
        if let s = v as? String { return s }
        if let date = v as? Date {
            let f = ISO8601DateFormatter()
            f.formatOptions = [.withFullDate]
            return f.string(from: date)
        }
        return String(describing: v)
    }

    private static func parseHooksList(_ raw: Any) -> [HookEntry]? {
        // Frontmatter agent-hooks shape (per Anthropic docs):
        // hooks: [{matcher: "...", hooks: [{type: command, command: "..."}]}]
        // or simplified: [{event, matcher, command}]
        if let arr = raw as? [Any] {
            var out: [HookEntry] = []
            for item in arr {
                guard let dict = item as? [String: Any] else { continue }
                let event = (dict["event"] as? String) ?? ""
                let matcher = dict["matcher"] as? String ?? dict["pattern"] as? String
                if let cmd = dict["command"] as? String {
                    out.append(HookEntry(event: event, matcher: matcher, command: cmd))
                } else if let nested = dict["hooks"] as? [Any] {
                    for n in nested {
                        if let nd = n as? [String: Any], let cmd = nd["command"] as? String {
                            out.append(HookEntry(event: event, matcher: matcher, command: cmd))
                        }
                    }
                }
            }
            return out.isEmpty ? nil : out
        }
        return nil
    }

    // MARK: - Skills

    private static func loadSkills(in dir: URL, findings: inout [Finding]) -> [Skill] {
        guard FileManager.default.fileExists(atPath: dir.path) else { return [] }
        let fm = FileManager.default
        var out: [Skill] = []
        guard let entries = try? fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.isDirectoryKey]) else {
            return []
        }
        for entry in entries.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
            var isDir: ObjCBool = false
            guard fm.fileExists(atPath: entry.path, isDirectory: &isDir), isDir.boolValue else { continue }
            let skillMD = entry.appendingPathComponent("SKILL.md")
            guard fm.fileExists(atPath: skillMD.path) else {
                findings.append(Finding(
                    ruleID: "S001",
                    severity: .error,
                    path: entry,
                    title: "Skill directory missing SKILL.md",
                    detail: "Skill directory '\(entry.lastPathComponent)' does not contain SKILL.md.",
                    suggestedFix: "Create \(skillMD.path) with required frontmatter (name, description)."
                ))
                continue
            }
            guard let raw = try? String(contentsOf: skillMD, encoding: .utf8) else { continue }
            let split = FrontmatterParser.split(raw)
            let bodyLines = split.body.split(separator: "\n", omittingEmptySubsequences: false).count
            do {
                let dict = try FrontmatterParser.parseDict(split.yamlString)
                let sf = parseSkillFrontmatter(dict, fallbackName: entry.lastPathComponent)
                let supporting = collectSupporting(in: entry, excluding: skillMD)
                out.append(Skill(
                    directory: entry,
                    skillMD: skillMD,
                    frontmatter: sf,
                    body: split.body,
                    bodyLines: bodyLines,
                    supportingFiles: supporting,
                    rawYAML: split.yamlString
                ))
            } catch {
                findings.append(Finding(
                    ruleID: "S002",
                    severity: .error,
                    path: skillMD,
                    title: "Skill frontmatter failed to parse",
                    detail: "\(error)"
                ))
            }
        }
        return out
    }

    private static func parseSkillFrontmatter(_ d: [String: Any], fallbackName: String) -> SkillFrontmatter {
        var unknown = d
        let name = (d["name"] as? String) ?? fallbackName
        let desc = (d["description"] as? String) ?? ""
        unknown.removeValue(forKey: "name")
        unknown.removeValue(forKey: "description")

        func takeString(_ k: String) -> String? {
            return unknown.removeValue(forKey: k) as? String
        }
        func takeBool(_ k: String) -> Bool? {
            return unknown.removeValue(forKey: k) as? Bool
        }
        func takeStringList(_ k: String) -> [String]? {
            guard let v = unknown.removeValue(forKey: k) else { return nil }
            if let arr = v as? [String] { return arr }
            if let arr = v as? [Any] { return arr.compactMap { $0 as? String } }
            if let s = v as? String { return [s] }
            return nil
        }
        func takeStringOrCSV(_ k: String) -> String? {
            guard let v = unknown.removeValue(forKey: k) else { return nil }
            if let s = v as? String { return s }
            if let arr = v as? [Any] {
                return arr.compactMap { $0 as? String }.joined(separator: ", ")
            }
            return nil
        }

        let whenToUse = takeString("when_to_use")
        let argHint = takeString("argument-hint")
        let arguments = takeString("arguments")
        let disableModelInvocation = takeBool("disable-model-invocation")
        let userInvocable = takeBool("user-invocable")
        let allowedTools = takeStringOrCSV("allowed-tools")
        let model = takeString("model")
        let effort = takeString("effort")
        let context = takeString("context")
        let agent = takeString("agent")
        let paths = takeStringList("paths")
        let shell = takeString("shell")
        let status = takeString("status")
        let updated = takeStringOrDate("updated", from: &unknown)
        let created = takeStringOrDate("created", from: &unknown)
        let tags = takeStringList("tags")

        var skillHooks: [HookEntry]? = nil
        if let raw = unknown.removeValue(forKey: "hooks") {
            skillHooks = parseHooksList(raw)
        }

        return SkillFrontmatter(
            name: name,
            description: desc,
            whenToUse: whenToUse,
            argumentHint: argHint,
            arguments: arguments,
            disableModelInvocation: disableModelInvocation,
            userInvocable: userInvocable,
            allowedTools: allowedTools,
            model: model,
            effort: effort,
            context: context,
            agent: agent,
            hooks: skillHooks,
            paths: paths,
            shell: shell,
            status: status,
            updated: updated,
            created: created,
            tags: tags,
            unknownKeys: unknown
        )
    }

    private static func collectSupporting(in dir: URL, excluding: URL) -> [URL] {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(at: dir, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
            return []
        }
        var out: [URL] = []
        for case let url as URL in enumerator {
            if url.path == excluding.path { continue }
            var isDir: ObjCBool = false
            if fm.fileExists(atPath: url.path, isDirectory: &isDir), !isDir.boolValue {
                out.append(url)
            }
        }
        return out.sorted { $0.path < $1.path }
    }

    // MARK: - Commands and rules

    private static func loadCommands(in dir: URL) -> [LegacyCommand] {
        guard FileManager.default.fileExists(atPath: dir.path) else { return [] }
        var out: [LegacyCommand] = []
        for url in mdFiles(in: dir) {
            let body = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
            out.append(LegacyCommand(path: url, name: url.deletingPathExtension().lastPathComponent, body: body))
        }
        return out
    }

    private static func loadRuleDocs(in dir: URL) -> [RuleDoc] {
        guard FileManager.default.fileExists(atPath: dir.path) else { return [] }
        var out: [RuleDoc] = []
        for url in mdFiles(in: dir) {
            let body = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
            out.append(RuleDoc(path: url, body: body))
        }
        return out
    }

    // MARK: - Settings + hooks normalization

    private static func loadSettings(at url: URL, findings: inout [Finding]) -> Settings? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        guard let data = try? Data(contentsOf: url),
              let raw = String(data: data, encoding: .utf8) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            findings.append(Finding(
                ruleID: "S002",
                severity: .error,
                path: url,
                title: "settings.json failed to parse",
                detail: "Invalid JSON."
            ))
            return Settings(path: url, rawJSON: raw)
        }

        let permsRaw = json["permissions"] as? [String: Any]
        let perms = permsRaw.map { p in
            PermissionsBlock(
                allow: (p["allow"] as? [String]) ?? [],
                deny: (p["deny"] as? [String]) ?? [],
                ask: (p["ask"] as? [String]) ?? []
            )
        }
        let defaultAgent = json["agent"] as? String
        let cleanup = json["cleanupPeriodDays"] as? Int
        let disableShell = json["disableSkillShellExecution"] as? Bool
        let overrides = (json["skillOverrides"] as? [String: String]) ?? [:]

        let hooks = normalizeHooks(json["hooks"], settingsPath: url)

        return Settings(
            path: url,
            permissions: perms,
            defaultAgent: defaultAgent,
            cleanupPeriodDays: cleanup,
            disableSkillShellExecution: disableShell,
            skillOverrides: overrides,
            hooks: hooks,
            rawJSON: raw
        )
    }

    /// Accepts both:
    ///   forge flat-array: `[{event, pattern, command}, ...]`
    ///   canonical map:    `{EventName: [{matcher?, hooks: [{type, command, shell?}]}]}`
    static func normalizeHooks(_ raw: Any?, settingsPath: URL) -> [Hook] {
        guard let raw = raw else { return [] }
        var out: [Hook] = []

        // Flat-array (forge dialect)
        if let arr = raw as? [Any] {
            for item in arr {
                guard let dict = item as? [String: Any] else { continue }
                let event = (dict["event"] as? String) ?? ""
                let matcher = (dict["matcher"] as? String) ?? (dict["pattern"] as? String)
                let command = (dict["command"] as? String) ?? ""
                let type = (dict["type"] as? String) ?? "command"
                let shell = dict["shell"] as? String
                if event.isEmpty || command.isEmpty { continue }
                out.append(Hook(event: event, matcher: matcher, command: command, type: type, shell: shell, sourcePath: settingsPath))
            }
            return out
        }

        // Canonical map
        if let map = raw as? [String: Any] {
            for (event, value) in map {
                guard let entries = value as? [Any] else { continue }
                for entry in entries {
                    guard let dict = entry as? [String: Any] else { continue }
                    let matcher = dict["matcher"] as? String
                    if let nested = dict["hooks"] as? [Any] {
                        for n in nested {
                            guard let nd = n as? [String: Any] else { continue }
                            let cmd = (nd["command"] as? String) ?? ""
                            let type = (nd["type"] as? String) ?? "command"
                            let shell = nd["shell"] as? String
                            if cmd.isEmpty { continue }
                            out.append(Hook(event: event, matcher: matcher, command: cmd, type: type, shell: shell, sourcePath: settingsPath))
                        }
                    } else if let cmd = dict["command"] as? String {
                        let type = (dict["type"] as? String) ?? "command"
                        let shell = dict["shell"] as? String
                        out.append(Hook(event: event, matcher: matcher, command: cmd, type: type, shell: shell, sourcePath: settingsPath))
                    }
                }
            }
            return out
        }

        return out
    }

    // MARK: - Helpers

    private static func mdFiles(in dir: URL) -> [URL] {
        let fm = FileManager.default
        guard let entries = try? fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) else {
            return []
        }
        return entries.filter { $0.pathExtension == "md" }.sorted { $0.lastPathComponent < $1.lastPathComponent }
    }
}
