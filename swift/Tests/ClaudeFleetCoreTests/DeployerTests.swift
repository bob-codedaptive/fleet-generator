import XCTest
@testable import ClaudeFleetCore

final class DeployerTests: XCTestCase {
    private var sourceRoot: URL!
    private var targetRoot: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let base = FileManager.default.temporaryDirectory.appendingPathComponent("anvil-deploy-\(UUID().uuidString)")
        sourceRoot = base.appendingPathComponent("source/.claude")
        targetRoot = base.appendingPathComponent("target/.claude")
        try FileManager.default.createDirectory(at: sourceRoot, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: targetRoot, withIntermediateDirectories: true)
    }

    private func write(_ url: URL, _ s: String) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try s.write(to: url, atomically: true, encoding: .utf8)
    }

    private func makeAgent(_ name: String, in root: URL, body: String = "agent body\n") throws {
        try write(root.appendingPathComponent("agents/\(name).md"),
                  "---\nname: \(name)\ndescription: An agent. Use when needed.\nmodel: opus\n---\n\(body)")
    }

    private func makeSkill(_ name: String, in root: URL, supporting: [String: String] = [:]) throws {
        try write(root.appendingPathComponent("skills/\(name)/SKILL.md"),
                  "---\nname: \(name)\ndescription: A skill. Use when relevant.\n---\nSKILL body\n")
        for (relPath, contents) in supporting {
            try write(root.appendingPathComponent("skills/\(name)/\(relPath)"), contents)
        }
    }

    func testDeployAgentNewArtifact() throws {
        try makeAgent("calvin", in: sourceRoot)
        let result = try Deployer.deploy(
            kind: .agent, name: "calvin",
            sourceLibraryRoot: sourceRoot, targetLibraryRoot: targetRoot
        )
        XCTAssertEqual(result.records.first?.action, .copied)
        XCTAssertTrue(FileManager.default.fileExists(atPath: targetRoot.appendingPathComponent("agents/calvin.md").path))
        XCTAssertNotNil(result.manifest.artifacts["agents/calvin.md"])
    }

    func testReDeployIsNoChange() throws {
        try makeAgent("calvin", in: sourceRoot)
        _ = try Deployer.deploy(kind: .agent, name: "calvin",
                                sourceLibraryRoot: sourceRoot, targetLibraryRoot: targetRoot)
        let again = try Deployer.deploy(kind: .agent, name: "calvin",
                                        sourceLibraryRoot: sourceRoot, targetLibraryRoot: targetRoot)
        XCTAssertEqual(again.records.first?.action, .skippedNoChange)
    }

    func testAdditiveSkipsExistingDifferent() throws {
        try makeAgent("calvin", in: sourceRoot)
        _ = try Deployer.deploy(kind: .agent, name: "calvin",
                                sourceLibraryRoot: sourceRoot, targetLibraryRoot: targetRoot)
        // mutate target locally
        let targetFile = targetRoot.appendingPathComponent("agents/calvin.md")
        let local = (try String(contentsOf: targetFile, encoding: .utf8)) + "\n# locally edited\n"
        try local.write(to: targetFile, atomically: true, encoding: .utf8)

        // additive should skip since target differs from source
        let result = try Deployer.deploy(kind: .agent, name: "calvin",
                                         sourceLibraryRoot: sourceRoot, targetLibraryRoot: targetRoot,
                                         mode: .additive)
        XCTAssertEqual(result.records.first?.action, .skippedExisting)
        // target retains local edit
        let after = try String(contentsOf: targetFile, encoding: .utf8)
        XCTAssertTrue(after.contains("locally edited"))
    }

    func testMirrorRefusesDriftedTargetWithoutForce() throws {
        try makeAgent("calvin", in: sourceRoot)
        _ = try Deployer.deploy(kind: .agent, name: "calvin",
                                sourceLibraryRoot: sourceRoot, targetLibraryRoot: targetRoot)
        // Local edit causes drift between target and manifest.source_hash
        let targetFile = targetRoot.appendingPathComponent("agents/calvin.md")
        try (try String(contentsOf: targetFile, encoding: .utf8) + "\n# drift\n")
            .write(to: targetFile, atomically: true, encoding: .utf8)

        // Source also changed
        try makeAgent("calvin", in: sourceRoot, body: "new agent body\n")

        XCTAssertThrowsError(try Deployer.deploy(
            kind: .agent, name: "calvin",
            sourceLibraryRoot: sourceRoot, targetLibraryRoot: targetRoot,
            mode: .mirror, force: false
        )) { err in
            guard case DeployError.driftWithoutForce = err else {
                return XCTFail("expected driftWithoutForce, got \(err)")
            }
        }
    }

    func testMirrorWithForceOverwrites() throws {
        try makeAgent("calvin", in: sourceRoot)
        _ = try Deployer.deploy(kind: .agent, name: "calvin",
                                sourceLibraryRoot: sourceRoot, targetLibraryRoot: targetRoot)
        let targetFile = targetRoot.appendingPathComponent("agents/calvin.md")
        try "drifted local\n".write(to: targetFile, atomically: true, encoding: .utf8)
        try makeAgent("calvin", in: sourceRoot, body: "fresh body\n")

        let result = try Deployer.deploy(kind: .agent, name: "calvin",
                                         sourceLibraryRoot: sourceRoot, targetLibraryRoot: targetRoot,
                                         mode: .mirror, force: true)
        XCTAssertEqual(result.records.first?.action, .copied)
        let now = try String(contentsOf: targetFile, encoding: .utf8)
        XCTAssertTrue(now.contains("fresh body"))
    }

    func testDeploySkillCopiesSupportingFiles() throws {
        try makeSkill("research", in: sourceRoot, supporting: ["references/notes.md": "notes\n"])
        let result = try Deployer.deploy(kind: .skill, name: "research",
                                         sourceLibraryRoot: sourceRoot, targetLibraryRoot: targetRoot)
        XCTAssertEqual(result.records.first?.action, .copied)
        XCTAssertTrue(FileManager.default.fileExists(atPath: targetRoot.appendingPathComponent("skills/research/SKILL.md").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: targetRoot.appendingPathComponent("skills/research/references/notes.md").path))
    }

    func testSyncCopiesEverything() throws {
        try makeAgent("a", in: sourceRoot)
        try makeAgent("b", in: sourceRoot)
        try makeSkill("s1", in: sourceRoot)
        try makeSkill("s2", in: sourceRoot)
        let result = try Deployer.sync(sourceLibraryRoot: sourceRoot, targetLibraryRoot: targetRoot)
        XCTAssertEqual(result.records.filter { $0.action == .copied }.count, 4)
        XCTAssertNotNil(result.manifest.artifacts["agents/a.md"])
        XCTAssertNotNil(result.manifest.artifacts["skills/s1"])
    }

    func testManifestPersistedToDisk() throws {
        try makeAgent("calvin", in: sourceRoot)
        _ = try Deployer.deploy(kind: .agent, name: "calvin",
                                sourceLibraryRoot: sourceRoot, targetLibraryRoot: targetRoot)
        let manifest = try AnvilManifest.load(from: targetRoot)
        XCTAssertNotNil(manifest)
        XCTAssertNotNil(manifest?.artifacts["agents/calvin.md"])
        XCTAssertEqual(manifest?.version, AnvilManifest.currentVersion)
    }

    func testDriftReportFlagsLocalEdits() throws {
        try makeAgent("calvin", in: sourceRoot)
        _ = try Deployer.deploy(kind: .agent, name: "calvin",
                                sourceLibraryRoot: sourceRoot, targetLibraryRoot: targetRoot)
        let targetFile = targetRoot.appendingPathComponent("agents/calvin.md")
        try (try String(contentsOf: targetFile, encoding: .utf8) + "\n# drift\n")
            .write(to: targetFile, atomically: true, encoding: .utf8)
        let report = try Deployer.driftReport(targetLibraryRoot: targetRoot)
        XCTAssertEqual(report.first?.status, .drifted)
    }

    func testDriftReportCleanWhenNothingChanged() throws {
        try makeAgent("calvin", in: sourceRoot)
        _ = try Deployer.deploy(kind: .agent, name: "calvin",
                                sourceLibraryRoot: sourceRoot, targetLibraryRoot: targetRoot)
        let report = try Deployer.driftReport(targetLibraryRoot: targetRoot)
        XCTAssertEqual(report.first?.status, .clean)
    }

    func testDriftReportFlagsMissingArtifact() throws {
        try makeAgent("calvin", in: sourceRoot)
        _ = try Deployer.deploy(kind: .agent, name: "calvin",
                                sourceLibraryRoot: sourceRoot, targetLibraryRoot: targetRoot)
        try FileManager.default.removeItem(at: targetRoot.appendingPathComponent("agents/calvin.md"))
        let report = try Deployer.driftReport(targetLibraryRoot: targetRoot)
        XCTAssertEqual(report.first?.status, .missing)
    }

    func testEndToEndPlanAcceptance() throws {
        // Plan acceptance: deploy `deep-research` skill from source to fresh
        // target → manifest entry created. Re-deploy → no-op. Hand-edit
        // target → drift warning.
        try makeSkill("deep-research", in: sourceRoot)
        let r1 = try Deployer.deploy(kind: .skill, name: "deep-research",
                                     sourceLibraryRoot: sourceRoot, targetLibraryRoot: targetRoot)
        XCTAssertEqual(r1.records.first?.action, .copied)
        let r2 = try Deployer.deploy(kind: .skill, name: "deep-research",
                                     sourceLibraryRoot: sourceRoot, targetLibraryRoot: targetRoot)
        XCTAssertEqual(r2.records.first?.action, .skippedNoChange)
        // Hand-edit target
        let skillMD = targetRoot.appendingPathComponent("skills/deep-research/SKILL.md")
        try (try String(contentsOf: skillMD, encoding: .utf8) + "\n# local change\n")
            .write(to: skillMD, atomically: true, encoding: .utf8)
        let report = try Deployer.driftReport(targetLibraryRoot: targetRoot)
        XCTAssertEqual(report.first?.status, .drifted)
    }
}
