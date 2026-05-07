import XCTest
@testable import ClaudeFleetCore

final class LintRuleTests: XCTestCase {
    private func temp(_ build: (URL) throws -> Void) throws -> Library {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("anvil-lint-\(UUID().uuidString)")
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

    // S001 — missing SKILL.md (loader-emitted)
    func testS001Bad() throws {
        let lib = try temp { root in
            try FileManager.default.createDirectory(at: root.appendingPathComponent("skills/orphan"), withIntermediateDirectories: true)
        }
        XCTAssertTrue(run(lib, "S001").contains { $0.ruleID == "S001" && $0.severity == .error })
    }
    func testS001Good() throws {
        let lib = try temp { root in
            try self.write(root.appendingPathComponent("skills/ok/SKILL.md"), "---\nname: ok\ndescription: ok use when needed\n---\n")
        }
        XCTAssertFalse(run(lib, "S001").contains { $0.ruleID == "S001" })
    }

    // S002 — frontmatter parses (loader-emitted)
    func testS002Bad() throws {
        let lib = try temp { root in
            try self.write(root.appendingPathComponent("agents/broken.md"), "---\nname: broken\ndescription: [unclosed\n---\nbody\n")
        }
        XCTAssertTrue(run(lib, "S002").contains { $0.ruleID == "S002" && $0.severity == .error })
    }

    // S003 — name regex + reserved
    func testS003BadName() throws {
        let lib = try temp { root in
            try self.write(root.appendingPathComponent("skills/Bad_Name/SKILL.md"), "---\nname: Bad_Name\ndescription: x use when needed\n---\n")
        }
        let findings = run(lib, "S003")
        XCTAssertTrue(findings.contains { $0.ruleID == "S003" && $0.title.contains("violates") })
    }
    func testS003ReservedName() throws {
        let lib = try temp { root in
            try self.write(root.appendingPathComponent("skills/anthropic-helper/SKILL.md"), "---\nname: anthropic-helper\ndescription: x use when needed\n---\n")
        }
        let findings = run(lib, "S003")
        XCTAssertTrue(findings.contains { $0.ruleID == "S003" && $0.title.contains("reserved") })
    }
    func testS003Good() throws {
        let lib = try temp { root in
            try self.write(root.appendingPathComponent("skills/processing-pdfs/SKILL.md"), "---\nname: processing-pdfs\ndescription: process pdfs use when needed\n---\n")
        }
        XCTAssertFalse(run(lib, "S003").contains { $0.ruleID == "S003" })
    }

    // S004 — description present, ≤1024, no XML
    func testS004MissingDescription() throws {
        let lib = try temp { root in
            try self.write(root.appendingPathComponent("skills/empty/SKILL.md"), "---\nname: empty\ndescription: ''\n---\n")
        }
        let findings = run(lib, "S004")
        XCTAssertTrue(findings.contains { $0.ruleID == "S004" && $0.title.contains("missing") })
    }
    func testS004XMLInDescription() throws {
        let lib = try temp { root in
            try self.write(root.appendingPathComponent("skills/has-xml/SKILL.md"), "---\nname: has-xml\ndescription: do <thing> with files use when relevant\n---\n")
        }
        let findings = run(lib, "S004")
        XCTAssertTrue(findings.contains { $0.ruleID == "S004" && $0.title.contains("XML") })
    }
    func testS004TooLong() throws {
        let long = String(repeating: "x", count: 1025)
        let lib = try temp { root in
            try self.write(root.appendingPathComponent("skills/wordy/SKILL.md"), "---\nname: wordy\ndescription: \(long)\n---\n")
        }
        let findings = run(lib, "S004")
        XCTAssertTrue(findings.contains { $0.ruleID == "S004" && $0.title.contains("1024") })
    }

    // A001 — agent name + description present
    func testA001MissingDescription() throws {
        let lib = try temp { root in
            try self.write(root.appendingPathComponent("agents/nodescr.md"), "---\nname: nodescr\n---\nbody\n")
        }
        let findings = run(lib, "A001")
        XCTAssertTrue(findings.contains { $0.ruleID == "A001" && $0.title.contains("description") })
    }
    func testA001Good() throws {
        let lib = try temp { root in
            try self.write(root.appendingPathComponent("agents/ok.md"), "---\nname: ok\ndescription: An agent. Use when relevant.\n---\nbody\n")
        }
        XCTAssertFalse(run(lib, "A001").contains { $0.ruleID == "A001" })
    }

    // Integration — RuleEngine combines load findings + rule findings, sorted
    func testEngineSortsFindings() throws {
        let lib = try temp { root in
            try self.write(root.appendingPathComponent("agents/nodescr.md"), "---\nname: nodescr\n---\nbody\n")
            try self.write(root.appendingPathComponent("skills/Bad_Name/SKILL.md"), "---\nname: Bad_Name\ndescription: x use when needed\n---\n")
            try FileManager.default.createDirectory(at: root.appendingPathComponent("skills/orphan"), withIntermediateDirectories: true)
        }
        let engine = RuleEngine(rules: RuleEngine.defaultRules)
        let findings = engine.run(on: lib)
        XCTAssertGreaterThanOrEqual(findings.count, 3)
        XCTAssertTrue(findings.allSatisfy { $0.severity == .error })
    }
}
