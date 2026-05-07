import Foundation

/// Normalized hook entry. Both the canonical Anthropic map shape
/// (`{event: [{matcher, hooks: [{type, command}]}]}`) and the forge flat-array
/// shape (`[{event, pattern, command}]`) get loaded into this single form.
public struct Hook: Sendable, Equatable {
    public let event: String
    public let matcher: String?
    public let command: String
    public let type: String        // "command" by default
    public let shell: String?
    public let sourcePath: URL?    // settings.json origin

    public init(
        event: String,
        matcher: String?,
        command: String,
        type: String = "command",
        shell: String? = nil,
        sourcePath: URL? = nil
    ) {
        self.event = event
        self.matcher = matcher
        self.command = command
        self.type = type
        self.shell = shell
        self.sourcePath = sourcePath
    }
}
