import XCTest
@testable import ClaudeFleetCore

final class LibraryLoaderTests: XCTestCase {
    /// Build an isolated `.claude/` tree on disk for one test.
    func makeTempLibrary(_ build: (URL) throws -> Void) throws -> URL {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("anvil-test-\(UUID().uuidString)")
            .appendingPathComponent(".claude")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        try build(root)
        return root
    }

    func writeFile(_ url: URL, _ contents: String) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try contents.write(to: url, atomically: true, encoding: .utf8)
    }

    func testLoadEmptyLibrary() throws {
        let root = try makeTempLibrary { _ in }
        let lib = try LibraryLoader.load(root)
        XCTAssertEqual(lib.agents.count, 0)
        XCTAssertEqual(lib.skills.count, 0)
        XCTAssertEqual(lib.hooks.count, 0)
        XCTAssertEqual(lib.scope, .project)
    }

    func testLoadAgentAndSkill() throws {
        let root = try makeTempLibrary { root in
            try self.writeFile(root.appendingPathComponent("agents/calvin.md"), """
            ---
            name: calvin
            description: Architecture reviewer.
            tools: Read, Grep
            model: opus
            skills:
              - mission-scoping
            ---
            body
            """)
            try self.writeFile(root.appendingPathComponent("skills/deep-research/SKILL.md"), """
            ---
            name: deep-research
            description: Investigates a question across many files. Use when reading 5+ files.
            ---
            body
            """)
        }
        let lib = try LibraryLoader.load(root)
        XCTAssertEqual(lib.agents.count, 1)
        XCTAssertEqual(lib.skills.count, 1)
        let agent = lib.agents[0]
        XCTAssertEqual(agent.frontmatter.name, "calvin")
        XCTAssertEqual(agent.frontmatter.tools, "Read, Grep")
        XCTAssertEqual(agent.frontmatter.skills, ["mission-scoping"])
    }

    func testLoadEmitsS001ForSkillDirMissingSKILLMD() throws {
        let root = try makeTempLibrary { root in
            try FileManager.default.createDirectory(at: root.appendingPathComponent("skills/orphan"), withIntermediateDirectories: true)
        }
        let lib = try LibraryLoader.load(root)
        XCTAssertTrue(lib.loadFindings.contains { $0.ruleID == "S001" })
    }

    func testLoadEmitsS002OnMalformedYAML() throws {
        let root = try makeTempLibrary { root in
            try self.writeFile(root.appendingPathComponent("agents/broken.md"), """
            ---
            name: broken
            description: [unclosed
            ---
            body
            """)
        }
        let lib = try LibraryLoader.load(root)
        XCTAssertTrue(lib.loadFindings.contains { $0.ruleID == "S002" })
    }

    // MARK: - Hook dialect normalization

    func testNormalizeHooksFlatArrayShape() throws {
        let root = try makeTempLibrary { root in
            let json = """
            {
              "hooks": [
                {"event": "Stop", "pattern": "**", "command": "./a.sh"},
                {"event": "PreToolUse", "pattern": "Bash(*)", "command": "./b.sh"}
              ]
            }
            """
            try self.writeFile(root.appendingPathComponent("settings.json"), json)
        }
        let lib = try LibraryLoader.load(root)
        XCTAssertEqual(lib.hooks.count, 2)
        XCTAssertEqual(lib.hooks[0].event, "Stop")
        XCTAssertEqual(lib.hooks[0].matcher, "**")
        XCTAssertEqual(lib.hooks[1].event, "PreToolUse")
    }

    func testNormalizeHooksCanonicalMapShape() throws {
        let root = try makeTempLibrary { root in
            let json = """
            {
              "hooks": {
                "SessionStart": [
                  {
                    "matcher": "compact",
                    "hooks": [{"type": "command", "command": "./on-compact.sh"}]
                  },
                  {
                    "hooks": [{"type": "command", "command": "./on-start.sh"}]
                  }
                ],
                "SubagentStart": [
                  {"hooks": [{"type": "command", "command": "./sub.sh"}]}
                ]
              }
            }
            """
            try self.writeFile(root.appendingPathComponent("settings.json"), json)
        }
        let lib = try LibraryLoader.load(root)
        XCTAssertEqual(lib.hooks.count, 3)
        let events = Set(lib.hooks.map { $0.event })
        XCTAssertEqual(events, ["SessionStart", "SubagentStart"])
        XCTAssertTrue(lib.hooks.contains { $0.matcher == "compact" })
    }

    // MARK: - Real-library smoke tests (skipped when fixture dirs absent)

    func testSmokeForge() throws {
        let url = URL(fileURLWithPath: "/Users/bob/devlop/forge/.claude")
        try XCTSkipUnless(FileManager.default.fileExists(atPath: url.path), "forge fixture absent")
        let lib = try LibraryLoader.load(url)
        XCTAssertGreaterThan(lib.agents.count, 0)
        XCTAssertGreaterThan(lib.skills.count, 0)
        XCTAssertGreaterThan(lib.hooks.count, 0)
        XCTAssertTrue(lib.loadFindings.filter { $0.ruleID == "S002" }.isEmpty,
                      "forge should have no parser failures")
    }

    func testSmokeSimpleMachinesDocs() throws {
        let url = URL(fileURLWithPath: "/Users/bob/dev_docs/simple-machines-docs/.claude")
        try XCTSkipUnless(FileManager.default.fileExists(atPath: url.path), "SM-docs fixture absent")
        let lib = try LibraryLoader.load(url)
        XCTAssertGreaterThan(lib.agents.count, 0)
        XCTAssertGreaterThan(lib.skills.count, 0)
        XCTAssertGreaterThan(lib.hooks.count, 0,
                             "SM-docs uses canonical map hook shape; loader should normalize")
        XCTAssertTrue(lib.loadFindings.filter { $0.ruleID == "S002" }.isEmpty,
                      "SM-docs should have no parser failures")
    }

    func testSmokeSampleOut() throws {
        let url = URL(fileURLWithPath: "/Users/bob/devlop/fleet-generator/sample_out/cli")
        try XCTSkipUnless(FileManager.default.fileExists(atPath: url.path), "sample_out absent")
        let lib = try LibraryLoader.load(url)
        XCTAssertGreaterThan(lib.agents.count, 0)
        XCTAssertGreaterThan(lib.skills.count, 0)
        XCTAssertTrue(lib.loadFindings.filter { $0.ruleID == "S002" }.isEmpty,
                      "sample_out should have no parser failures")
    }
}
