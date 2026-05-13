import XCTest
@testable import ClaudeFleetCore

final class ExtendedLintTests: XCTestCase {
    private func tempLib(_ build: (URL) throws -> Void) throws -> Library {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("anvil-ext-\(UUID().uuidString)")
            .appendingPathComponent(".claude")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        try build(root)
        return try LibraryLoader.load(root)
    }

    private func write(_ url: URL, _ s: String) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try s.write(to: url, atomically: true, encoding: .utf8)
    }

    private func run(_ lib: Library, _ id: String) -> [Finding] {
        let engine = RuleEngine(rules: RuleEngine.defaultRules)
        return engine.run(on: lib, ruleIDs: [id])
    }

    private func runR(_ lib: Library) -> [Finding] {
        let engine = RuleEngine(rules: RuleEngine.redundancyOnly)
        return engine.run(on: lib).filter { $0.ruleID.hasPrefix("R") }
    }

    // MARK: - S005 third-person

    func testS005FirstPersonOpener() throws {
        let lib = try tempLib { root in
            try self.write(root.appendingPathComponent("skills/x/SKILL.md"), "---\nname: x\ndescription: I help with documents. Use when relevant.\n---\n")
        }
        XCTAssertTrue(run(lib, "S005").contains { $0.ruleID == "S005" })
    }
    func testS005ThirdPersonOK() throws {
        let lib = try tempLib { root in
            try self.write(root.appendingPathComponent("skills/x/SKILL.md"), "---\nname: x\ndescription: Processes documents. Use when relevant.\n---\n")
        }
        XCTAssertFalse(run(lib, "S005").contains { $0.ruleID == "S005" })
    }

    // MARK: - S006 when-to-use cue

    func testS006MissingCue() throws {
        let lib = try tempLib { root in
            try self.write(root.appendingPathComponent("skills/x/SKILL.md"), "---\nname: x\ndescription: Processes documents.\n---\n")
        }
        XCTAssertTrue(run(lib, "S006").contains { $0.ruleID == "S006" })
    }
    func testS006HasCue() throws {
        let lib = try tempLib { root in
            try self.write(root.appendingPathComponent("skills/x/SKILL.md"), "---\nname: x\ndescription: Processes documents. Use when reading 5+ files.\n---\n")
        }
        XCTAssertFalse(run(lib, "S006").contains { $0.ruleID == "S006" })
    }

    // MARK: - S007 body lines

    func testS007TooLong() throws {
        let body = String(repeating: "line\n", count: 510)
        let lib = try tempLib { root in
            try self.write(root.appendingPathComponent("skills/x/SKILL.md"), "---\nname: x\ndescription: y use when needed\n---\n\(body)")
        }
        XCTAssertTrue(run(lib, "S007").contains { $0.ruleID == "S007" })
    }
    func testS007Short() throws {
        let lib = try tempLib { root in
            try self.write(root.appendingPathComponent("skills/x/SKILL.md"), "---\nname: x\ndescription: y use when needed\n---\nshort body\n")
        }
        XCTAssertFalse(run(lib, "S007").contains { $0.ruleID == "S007" })
    }

    // MARK: - S008 reference depth

    func testS008NestedRefs() throws {
        let lib = try tempLib { root in
            try self.write(root.appendingPathComponent("skills/x/SKILL.md"),
                "---\nname: x\ndescription: y use when needed\n---\nSee [a](a.md).\n")
            try self.write(root.appendingPathComponent("skills/x/a.md"), "Read [b](b.md) for more.\n")
            try self.write(root.appendingPathComponent("skills/x/b.md"), "leaf\n")
        }
        XCTAssertTrue(run(lib, "S008").contains { $0.ruleID == "S008" })
    }
    func testS008OneLevelOK() throws {
        let lib = try tempLib { root in
            try self.write(root.appendingPathComponent("skills/x/SKILL.md"),
                "---\nname: x\ndescription: y use when needed\n---\nSee [a](a.md).\n")
            try self.write(root.appendingPathComponent("skills/x/a.md"), "no further links\n")
        }
        XCTAssertFalse(run(lib, "S008").contains { $0.ruleID == "S008" })
    }

    // MARK: - S009 backslash paths

    func testS009Backslash() throws {
        let lib = try tempLib { root in
            try self.write(root.appendingPathComponent("skills/x/SKILL.md"),
                "---\nname: x\ndescription: y use when needed\n---\nRun scripts\\helper.py\n")
        }
        XCTAssertTrue(run(lib, "S009").contains { $0.ruleID == "S009" })
    }

    // MARK: - S010 vague names

    func testS010Vague() throws {
        let lib = try tempLib { root in
            try self.write(root.appendingPathComponent("skills/pdf-helper/SKILL.md"),
                "---\nname: pdf-helper\ndescription: y use when needed\n---\n")
        }
        XCTAssertTrue(run(lib, "S010").contains { $0.ruleID == "S010" })
    }

    // MARK: - A002 kebab-case

    func testA002NotKebab() throws {
        let lib = try tempLib { root in
            try self.write(root.appendingPathComponent("agents/Calvin.md"),
                "---\nname: Calvin\ndescription: x use when needed\n---\n")
        }
        XCTAssertTrue(run(lib, "A002").contains { $0.ruleID == "A002" })
    }

    // MARK: - A003 model

    func testA003BadModel() throws {
        let lib = try tempLib { root in
            try self.write(root.appendingPathComponent("agents/x.md"),
                "---\nname: x\ndescription: y use when needed\nmodel: gpt-4\n---\n")
        }
        XCTAssertTrue(run(lib, "A003").contains { $0.ruleID == "A003" })
    }
    func testA003ValidAlias() throws {
        let lib = try tempLib { root in
            try self.write(root.appendingPathComponent("agents/x.md"),
                "---\nname: x\ndescription: y use when needed\nmodel: opus\n---\n")
        }
        XCTAssertFalse(run(lib, "A003").contains { $0.ruleID == "A003" })
    }
    func testA003ValidFullID() throws {
        let lib = try tempLib { root in
            try self.write(root.appendingPathComponent("agents/x.md"),
                "---\nname: x\ndescription: y use when needed\nmodel: claude-opus-4-7\n---\n")
        }
        XCTAssertFalse(run(lib, "A003").contains { $0.ruleID == "A003" })
    }

    // MARK: - A004 permissionMode

    func testA004BadEnum() throws {
        let lib = try tempLib { root in
            try self.write(root.appendingPathComponent("agents/x.md"),
                "---\nname: x\ndescription: y use when needed\npermissionMode: yolo\n---\n")
        }
        XCTAssertTrue(run(lib, "A004").contains { $0.ruleID == "A004" })
    }

    // MARK: - A007 use cue

    func testA007MissingCue() throws {
        let lib = try tempLib { root in
            try self.write(root.appendingPathComponent("agents/x.md"),
                "---\nname: x\ndescription: An agent for things.\n---\n")
        }
        XCTAssertTrue(run(lib, "A007").contains { $0.ruleID == "A007" })
    }

    // MARK: - C001 secrets

    func testC001AnthropicKeyInBody() throws {
        let lib = try tempLib { root in
            let key = "sk-ant-" + String(repeating: "A", count: 40)
            try self.write(root.appendingPathComponent("agents/x.md"),
                "---\nname: x\ndescription: y use when needed\n---\nleaked: \(key)\n")
        }
        XCTAssertTrue(run(lib, "C001").contains { $0.ruleID == "C001" })
    }
    func testC001AwsKeyInSettings() throws {
        let lib = try tempLib { root in
            try self.write(root.appendingPathComponent("settings.json"),
                "{\"_note\": \"AKIAABCDEFGHIJKLMNOP\"}")
        }
        XCTAssertTrue(run(lib, "C001").contains { $0.ruleID == "C001" })
    }

    // MARK: - C002 unique names

    func testC002DuplicateAgents() throws {
        let lib = try tempLib { root in
            try self.write(root.appendingPathComponent("agents/a.md"),
                "---\nname: dup\ndescription: y use when needed\n---\n")
            try self.write(root.appendingPathComponent("agents/b.md"),
                "---\nname: dup\ndescription: y use when needed\n---\n")
        }
        XCTAssertTrue(run(lib, "C002").contains { $0.ruleID == "C002" })
    }

    // MARK: - C003 MCP refs

    func testC003UnqualifiedMCP() throws {
        let lib = try tempLib { root in
            try self.write(root.appendingPathComponent("agents/x.md"),
                "---\nname: x\ndescription: y use when needed\ntools: Read, mcp_mempalace_search\n---\n")
        }
        XCTAssertTrue(run(lib, "C003").contains { $0.ruleID == "C003" })
    }

    // MARK: - C004 hook scripts exist

    func testC004HookMissing() throws {
        let lib = try tempLib { root in
            try self.write(root.appendingPathComponent("settings.json"),
                "{\"hooks\":[{\"event\":\"Stop\",\"pattern\":\"**\",\"command\":\".claude/hooks/missing.sh\"}]}")
        }
        XCTAssertTrue(run(lib, "C004").contains { $0.ruleID == "C004" })
    }
    func testC004HookExists() throws {
        let lib = try tempLib { root in
            let hook = root.appendingPathComponent("hooks/present.sh")
            try self.write(hook, "#!/bin/sh\n")
            try self.write(root.appendingPathComponent("settings.json"),
                "{\"hooks\":[{\"event\":\"Stop\",\"pattern\":\"**\",\"command\":\".claude/hooks/present.sh\"}]}")
        }
        XCTAssertFalse(run(lib, "C004").contains { $0.ruleID == "C004" })
    }

    // MARK: - C005 skills refs exist

    func testC005MissingSkillRef() throws {
        let lib = try tempLib { root in
            try self.write(root.appendingPathComponent("agents/x.md"),
                "---\nname: x\ndescription: y use when needed\nskills:\n  - missing-skill\n---\n")
        }
        XCTAssertTrue(run(lib, "C005").contains { $0.ruleID == "C005" })
    }

    // MARK: - R001 legacy command + skill collision

    func testR001CollidingCommandAndSkill() throws {
        let lib = try tempLib { root in
            try self.write(root.appendingPathComponent("skills/dup/SKILL.md"),
                "---\nname: dup\ndescription: y use when needed\n---\n")
            try self.write(root.appendingPathComponent("commands/dup.md"), "legacy command body")
        }
        XCTAssertTrue(runR(lib).contains { $0.ruleID == "R001" })
    }

    // MARK: - R002 description overlap

    func testR002SimilarDescriptions() throws {
        let desc = "Investigates a question across many files in the repo. Use when reading 5+ files would burn context."
        let lib = try tempLib { root in
            try self.write(root.appendingPathComponent("skills/a/SKILL.md"),
                "---\nname: a\ndescription: \(desc)\n---\n")
            try self.write(root.appendingPathComponent("skills/b/SKILL.md"),
                "---\nname: b\ndescription: \(desc)\n---\n")
        }
        XCTAssertTrue(runR(lib).contains { $0.ruleID == "R002" })
    }

    // MARK: - R005 duplicate hook event+matcher

    func testR005DuplicateHooks() throws {
        let lib = try tempLib { root in
            try self.write(root.appendingPathComponent("settings.json"), """
            {
              "hooks": [
                {"event": "Stop", "pattern": "**", "command": "./a.sh"},
                {"event": "Stop", "pattern": "**", "command": "./b.sh"}
              ]
            }
            """)
        }
        XCTAssertTrue(runR(lib).contains { $0.ruleID == "R005" })
    }

    // MARK: - LibraryDiff dialect drift

    func testLibraryDiffSurfacesInitialPromptDifference() throws {
        let aRoot = try tempLib { root in
            try self.write(root.appendingPathComponent("agents/shared.md"),
                "---\nname: shared\ndescription: Shared agent. Use when needed.\nmodel: opus\n---\nbody\n")
        }.root
        let bRoot = try tempLib { root in
            try self.write(root.appendingPathComponent("agents/shared.md"),
                "---\nname: shared\ndescription: Shared agent. Use when needed.\nmodel: opus\ninitialPrompt: hello\nmemory: project\n---\nbody\n")
        }.root
        let aLib = try LibraryLoader.load(aRoot)
        let bLib = try LibraryLoader.load(bRoot)
        let diff = LibraryDiff.compute(aLib, bLib)
        XCTAssertEqual(diff.agents.changed.count, 1)
        let fields = diff.agents.changed[0].fieldDiffs.map { $0.field }
        XCTAssertTrue(fields.contains("initialPrompt"))
        XCTAssertTrue(fields.contains("memory"))
        let report = diff.textReport()
        XCTAssertTrue(report.contains("initialPrompt"))
    }

    // MARK: - Real-library lints (skipped if absent) — must not crash

    func testForgeLintsRun() throws {
        guard let path = ProcessInfo.processInfo.environment["ANVIL_FIXTURE_FORGE"] else {
            throw XCTSkip("ANVIL_FIXTURE_FORGE not set")
        }
        let url = URL(fileURLWithPath: path)
        try XCTSkipUnless(FileManager.default.fileExists(atPath: url.path), "fixture absent at \(url.path)")
        let lib = try LibraryLoader.load(url)
        let engine = RuleEngine(rules: RuleEngine.defaultRules)
        _ = engine.run(on: lib)
    }
}
