import XCTest
@testable import ClaudeFleetCore

final class FrontmatterMutatorTests: XCTestCase {
    private func tempFile(_ contents: String, name: String = "agent.md") throws -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("anvil-mut-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let url = dir.appendingPathComponent(name)
        try contents.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    func testSimpleScalarReplaceMinimalDiff() throws {
        let original = """
        ---
        name: calvin
        description: An agent. Use when needed.
        model: opus
        status: active
        updated: 2026-05-07
        ---
        body line 1
        body line 2
        """
        let updated = try FrontmatterMutator.setValue("2026-05-08", forKey: "updated", in: original)
        let originalLines = original.components(separatedBy: "\n")
        let updatedLines = updated.components(separatedBy: "\n")
        XCTAssertEqual(originalLines.count, updatedLines.count, "should be a 1-for-1 line replacement")
        var diffs = 0
        for (o, u) in zip(originalLines, updatedLines) where o != u { diffs += 1 }
        XCTAssertEqual(diffs, 1, "exactly one line should differ")
        XCTAssertTrue(updated.contains("updated: 2026-05-08"))
        XCTAssertFalse(updated.contains("updated: 2026-05-07"))
    }

    func testAddNewKey() throws {
        let original = """
        ---
        name: calvin
        description: An agent. Use when needed.
        ---
        body
        """
        let updated = try FrontmatterMutator.setValue("active", forKey: "status", in: original)
        XCTAssertTrue(updated.contains("status: active"))
        XCTAssertTrue(updated.contains("name: calvin"))
        XCTAssertTrue(updated.contains("body"))
    }

    func testQuotingForReservedAndSpecial() {
        XCTAssertEqual(FrontmatterMutator.formatScalar("yes"), "'yes'")
        XCTAssertEqual(FrontmatterMutator.formatScalar("true"), "'true'")
        XCTAssertEqual(FrontmatterMutator.formatScalar(""), "''")
        XCTAssertEqual(FrontmatterMutator.formatScalar("hello: world"), "'hello: world'")
        XCTAssertEqual(FrontmatterMutator.formatScalar("normal"), "normal")
        XCTAssertEqual(FrontmatterMutator.formatScalar("kebab-name"), "kebab-name")
        XCTAssertEqual(FrontmatterMutator.formatScalar("2026-05-08"), "2026-05-08")
    }

    func testReplaceBlockScalar() throws {
        let original = """
        ---
        name: calvin
        description: >-
          Architecture reviewer. Long form description that
          spans multiple lines for readability.
        model: opus
        ---
        body
        """
        let updated = try FrontmatterMutator.setValue("Short.", forKey: "description", in: original)
        XCTAssertTrue(updated.contains("description: Short."))
        XCTAssertFalse(updated.contains("Architecture reviewer"))
        XCTAssertTrue(updated.contains("name: calvin"))
        XCTAssertTrue(updated.contains("model: opus"))
        XCTAssertTrue(updated.contains("body"))
    }

    func testRoundTripModelEqualityForKnownFields() throws {
        let original = """
        ---
        name: calvin
        description: An agent. Use when needed.
        tools: Read, Glob, Grep
        model: opus
        skills:
          - mission-scoping
          - blast-radius
        status: active
        updated: 2026-05-07
        ---
        body
        """
        let url = try tempFile(original)
        let before = try FileManager.default.contentsOfDirectory(atPath: url.deletingLastPathComponent().path)
        XCTAssertNotNil(before)

        // Mutate then reload via the agent parser.
        try FrontmatterMutator.apply([("updated", "2026-05-08")], to: url)
        let after = try String(contentsOf: url, encoding: .utf8)
        let split = FrontmatterParser.split(after)
        let dict = try FrontmatterParser.parseDict(split.yamlString)
        XCTAssertEqual(dict["name"] as? String, "calvin")
        XCTAssertEqual(dict["model"] as? String, "opus")
        XCTAssertEqual(dict["skills"] as? [String], ["mission-scoping", "blast-radius"])
        // updated is parsed as a Date or String depending on YAML autodetection
        let updatedRaw = dict["updated"]
        if let s = updatedRaw as? String {
            XCTAssertEqual(s, "2026-05-08")
        } else if let d = updatedRaw as? Date {
            let f = ISO8601DateFormatter(); f.formatOptions = [.withFullDate]
            XCTAssertEqual(f.string(from: d), "2026-05-08")
        } else {
            XCTFail("updated field has unexpected type: \(String(describing: updatedRaw))")
        }
    }

    func testCalvinUpdatedAcceptanceMinimalDiff() throws {
        // Mirror the structure of forge/calvin.md, including the `>-` block
        // scalar description, to verify the acceptance check from the plan:
        //   `anvil edit calvin --set updated=2026-05-08` produces a minimal git diff.
        let original = """
        ---
        name: calvin
        description: >-
          Architecture reviewer. Read-only. Spawned for missions with non-trivial design choices — touching shared primitives, cross-system surfaces, or multi-quarter implications.
        tools: Read, Glob, Grep, Bash
        model: opus
        skills:
          - mission-scoping
          - blast-radius
          - source-of-truth
        status: active
        updated: 2026-05-07
        ---

        # Calvin — Architect

        Body content.
        """
        let url = try tempFile(original, name: "calvin.md")
        try FrontmatterMutator.apply([("updated", "2026-05-08")], to: url)
        let updated = try String(contentsOf: url, encoding: .utf8)

        // Compute a line-level diff: only the `updated:` line should change.
        let originalLines = original.components(separatedBy: "\n")
        let updatedLines = updated.components(separatedBy: "\n")
        XCTAssertEqual(originalLines.count, updatedLines.count, "line count should be unchanged")
        let differing = zip(originalLines, updatedLines).enumerated()
            .filter { $0.element.0 != $0.element.1 }
            .map { ($0.offset, $0.element.0, $0.element.1) }
        XCTAssertEqual(differing.count, 1, "exactly one line should differ; got: \(differing)")
        XCTAssertTrue(differing.first?.2.contains("updated: 2026-05-08") ?? false)
    }

    func testInvalidKey() {
        XCTAssertThrowsError(try FrontmatterMutator.setValue("x", forKey: "bad key!", in: "---\nname: x\n---\n"))
    }

    func testNoFrontmatterThrows() {
        XCTAssertThrowsError(try FrontmatterMutator.setValue("x", forKey: "name", in: "no fm here"))
    }
}
