import Foundation
import CryptoKit

public struct AnvilManifest: Codable, Equatable {
    public static let fileName = ".anvil-manifest.json"
    public static let currentVersion = 1
    public static let anvilVersion = "0.4.0"

    public var version: Int
    public var artifacts: [String: ArtifactRecord]

    public struct ArtifactRecord: Codable, Equatable {
        public var sourceLibrary: String
        public var sourceHash: String
        public var deployedAt: String
        public var anvilVersion: String

        enum CodingKeys: String, CodingKey {
            case sourceLibrary = "source_library"
            case sourceHash    = "source_hash"
            case deployedAt    = "deployed_at"
            case anvilVersion  = "anvil_version"
        }

        public init(sourceLibrary: String, sourceHash: String, deployedAt: String, anvilVersion: String) {
            self.sourceLibrary = sourceLibrary
            self.sourceHash = sourceHash
            self.deployedAt = deployedAt
            self.anvilVersion = anvilVersion
        }
    }

    public init(version: Int = currentVersion, artifacts: [String: ArtifactRecord] = [:]) {
        self.version = version
        self.artifacts = artifacts
    }

    /// Returns nil when no manifest file exists (a fresh target).
    public static func load(from libraryRoot: URL) throws -> AnvilManifest? {
        let path = libraryRoot.appendingPathComponent(fileName)
        guard FileManager.default.fileExists(atPath: path.path) else { return nil }
        let data = try Data(contentsOf: path)
        return try JSONDecoder().decode(AnvilManifest.self, from: data)
    }

    public func save(to libraryRoot: URL) throws {
        let path = libraryRoot.appendingPathComponent(Self.fileName)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(self)
        try data.write(to: path, options: .atomic)
    }
}

public enum HashUtil {
    /// SHA256 of a single file.
    public static func hashFile(at url: URL) throws -> String {
        let data = try Data(contentsOf: url)
        let digest = SHA256.hash(data: data)
        return "sha256:" + digest.map { String(format: "%02x", $0) }.joined()
    }

    /// SHA256 over the contents of every file in a directory tree, in sorted
    /// path order. Each file contributes "<rel-path>\n<bytes>\n" to the
    /// rolling hash, so renames change the digest.
    public static func hashDirectory(at root: URL) throws -> String {
        let fm = FileManager.default
        var paths: [URL] = []
        if let enumerator = fm.enumerator(at: root, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]) {
            for case let url as URL in enumerator {
                let isFile = (try? url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) ?? false
                if isFile { paths.append(url) }
            }
        }
        let rootPath = root.standardizedFileURL.path
        let rel = paths.compactMap { url -> (String, URL)? in
            let p = url.standardizedFileURL.path
            guard p.hasPrefix(rootPath) else { return nil }
            var r = String(p.dropFirst(rootPath.count))
            if r.hasPrefix("/") { r.removeFirst() }
            return (r, url)
        }.sorted { $0.0 < $1.0 }

        var hasher = SHA256()
        for (relPath, url) in rel {
            hasher.update(data: Data(relPath.utf8))
            hasher.update(data: Data([0x0a]))
            let body = try Data(contentsOf: url)
            hasher.update(data: body)
            hasher.update(data: Data([0x0a]))
        }
        let digest = hasher.finalize()
        return "sha256:" + digest.map { String(format: "%02x", $0) }.joined()
    }
}
