import Foundation

/// A `.claude/rules/*.md` file (project-level rule documentation).
public struct RuleDoc: Sendable {
    public let path: URL
    public let body: String

    public init(path: URL, body: String) {
        self.path = path
        self.body = body
    }
}
