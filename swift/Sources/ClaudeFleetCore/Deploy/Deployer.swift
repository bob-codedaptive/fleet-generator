import Foundation

public enum DeployMode: String, Sendable {
    case mirror, additive, prompt
}

public enum DeployError: Error, Equatable {
    case sourceMissing(String)
    case unknownArtifact(String)
    case driftWithoutForce(artifact: String, sourceHash: String, targetHash: String)
    case conflictNeedsHumanResolution(artifact: String)
}

public struct DeployRecord: Equatable {
    public let key: String                 // "agents/<name>.md" or "skills/<name>"
    public let action: Action
    public let detail: String?

    public enum Action: String, Equatable {
        case copied
        case skippedExisting
        case skippedNoChange
        case driftWarning
        case conflict
    }
}

public struct DeployResult {
    public var records: [DeployRecord] = []
    public var manifest: AnvilManifest
}

/// Copy an agent or a skill from a source library to a target library and
/// record provenance + integrity hash in `.anvil-manifest.json`.
///
/// This deploy works at the artifact granularity. `sync` (in the CLI layer)
/// fans this out across every artifact in the source library.
public enum Deployer {
    public enum ArtifactKind: String { case agent, skill }

    /// Deploy a single artifact identified by kind + name.
    public static func deploy(
        kind: ArtifactKind,
        name: String,
        sourceLibraryRoot: URL,
        targetLibraryRoot: URL,
        mode: DeployMode = .additive,
        force: Bool = false,
        now: Date = Date()
    ) throws -> DeployResult {
        let fm = FileManager.default
        try ensureDir(targetLibraryRoot)
        var manifest = (try AnvilManifest.load(from: targetLibraryRoot)) ?? AnvilManifest()

        let (key, sourcePath, targetPath, isDirectory) = try locate(kind: kind, name: name, sourceRoot: sourceLibraryRoot, targetRoot: targetLibraryRoot)
        guard fm.fileExists(atPath: sourcePath.path) else {
            throw DeployError.sourceMissing(key)
        }

        let sourceHash = isDirectory
            ? try HashUtil.hashDirectory(at: sourcePath)
            : try HashUtil.hashFile(at: sourcePath)

        let targetExists = fm.fileExists(atPath: targetPath.path)
        var records: [DeployRecord] = []

        if targetExists {
            let targetHash = isDirectory
                ? try HashUtil.hashDirectory(at: targetPath)
                : try HashUtil.hashFile(at: targetPath)

            // No-change short-circuit: contents are byte-equal; just refresh manifest.
            if targetHash == sourceHash {
                manifest.artifacts[key] = AnvilManifest.ArtifactRecord(
                    sourceLibrary: sourceLibraryRoot.standardizedFileURL.path,
                    sourceHash: sourceHash,
                    deployedAt: iso8601(now),
                    anvilVersion: AnvilManifest.anvilVersion
                )
                try manifest.save(to: targetLibraryRoot)
                records.append(DeployRecord(key: key, action: .skippedNoChange, detail: nil))
                return DeployResult(records: records, manifest: manifest)
            }

            switch mode {
            case .additive:
                records.append(DeployRecord(key: key, action: .skippedExisting, detail: "target exists; additive mode"))
                return DeployResult(records: records, manifest: manifest)
            case .prompt:
                records.append(DeployRecord(key: key, action: .conflict, detail: "prompt mode requires interactive resolution"))
                throw DeployError.conflictNeedsHumanResolution(artifact: key)
            case .mirror:
                if let prior = manifest.artifacts[key], prior.sourceHash != targetHash, !force {
                    throw DeployError.driftWithoutForce(artifact: key, sourceHash: prior.sourceHash, targetHash: targetHash)
                }
                // mirror with no prior record OR (with prior record AND target unchanged from manifest) OR (force) → overwrite
                try removeIfPresent(targetPath)
                try copy(from: sourcePath, to: targetPath, isDirectory: isDirectory)
                records.append(DeployRecord(key: key, action: .copied, detail: "mirror overwrite"))
            }
        } else {
            try copy(from: sourcePath, to: targetPath, isDirectory: isDirectory)
            records.append(DeployRecord(key: key, action: .copied, detail: "new artifact"))
        }

        manifest.artifacts[key] = AnvilManifest.ArtifactRecord(
            sourceLibrary: sourceLibraryRoot.standardizedFileURL.path,
            sourceHash: sourceHash,
            deployedAt: iso8601(now),
            anvilVersion: AnvilManifest.anvilVersion
        )
        try manifest.save(to: targetLibraryRoot)
        return DeployResult(records: records, manifest: manifest)
    }

    /// Sync every agent and skill from source into target.
    public static func sync(
        sourceLibraryRoot: URL,
        targetLibraryRoot: URL,
        mode: DeployMode = .additive,
        force: Bool = false,
        now: Date = Date()
    ) throws -> DeployResult {
        try ensureDir(targetLibraryRoot)
        var manifest = (try AnvilManifest.load(from: targetLibraryRoot)) ?? AnvilManifest()
        var allRecords: [DeployRecord] = []

        let sourceLib = try LibraryLoader.load(sourceLibraryRoot)
        for agent in sourceLib.agents {
            let result = try deploy(
                kind: .agent, name: agent.frontmatter.name,
                sourceLibraryRoot: sourceLibraryRoot, targetLibraryRoot: targetLibraryRoot,
                mode: mode, force: force, now: now
            )
            allRecords.append(contentsOf: result.records)
            manifest = result.manifest
        }
        for skill in sourceLib.skills {
            let result = try deploy(
                kind: .skill, name: skill.frontmatter.name,
                sourceLibraryRoot: sourceLibraryRoot, targetLibraryRoot: targetLibraryRoot,
                mode: mode, force: force, now: now
            )
            allRecords.append(contentsOf: result.records)
            manifest = result.manifest
        }

        return DeployResult(records: allRecords, manifest: manifest)
    }

    /// Drift report: for every artifact in the manifest, recompute the
    /// target's current hash and compare to `source_hash` recorded at deploy.
    public struct DriftEntry: Equatable {
        public let key: String
        public let recordedSourceHash: String
        public let currentTargetHash: String?
        public let status: Status
        public enum Status: String { case clean, drifted, missing }
    }

    public static func driftReport(targetLibraryRoot: URL) throws -> [DriftEntry] {
        guard let manifest = try AnvilManifest.load(from: targetLibraryRoot) else { return [] }
        var out: [DriftEntry] = []
        for (key, record) in manifest.artifacts.sorted(by: { $0.key < $1.key }) {
            let (sourcePath, isDir) = try resolveTargetForKey(key, targetRoot: targetLibraryRoot)
            guard FileManager.default.fileExists(atPath: sourcePath.path) else {
                out.append(DriftEntry(key: key, recordedSourceHash: record.sourceHash, currentTargetHash: nil, status: .missing))
                continue
            }
            let currentHash = isDir
                ? try HashUtil.hashDirectory(at: sourcePath)
                : try HashUtil.hashFile(at: sourcePath)
            let status: DriftEntry.Status = (currentHash == record.sourceHash) ? .clean : .drifted
            out.append(DriftEntry(key: key, recordedSourceHash: record.sourceHash, currentTargetHash: currentHash, status: status))
        }
        return out
    }

    // MARK: - Helpers

    private static func locate(
        kind: ArtifactKind, name: String, sourceRoot: URL, targetRoot: URL
    ) throws -> (key: String, source: URL, target: URL, isDir: Bool) {
        switch kind {
        case .agent:
            let key = "agents/\(name).md"
            return (key, sourceRoot.appendingPathComponent(key), targetRoot.appendingPathComponent(key), false)
        case .skill:
            let key = "skills/\(name)"
            return (key, sourceRoot.appendingPathComponent(key), targetRoot.appendingPathComponent(key), true)
        }
    }

    private static func resolveTargetForKey(_ key: String, targetRoot: URL) throws -> (URL, Bool) {
        let path = targetRoot.appendingPathComponent(key)
        let isDir = key.hasPrefix("skills/")
        return (path, isDir)
    }

    private static func ensureDir(_ url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    private static func removeIfPresent(_ url: URL) throws {
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }

    private static func copy(from src: URL, to dst: URL, isDirectory: Bool) throws {
        let parent = dst.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true)
        try FileManager.default.copyItem(at: src, to: dst)
    }

    private static func iso8601(_ date: Date) -> String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f.string(from: date)
    }
}
