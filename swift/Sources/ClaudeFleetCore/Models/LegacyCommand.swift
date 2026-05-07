import Foundation

/// A `.claude/commands/<name>.md` file. Legacy form — equivalent to a skill at
/// `.claude/skills/<name>/SKILL.md`. If both exist with the same name, the
/// skill wins (per Anthropic docs).
public struct LegacyCommand: Sendable {
    public let path: URL
    public let name: String
    public let body: String

    public init(path: URL, name: String, body: String) {
        self.path = path
        self.name = name
        self.body = body
    }
}
