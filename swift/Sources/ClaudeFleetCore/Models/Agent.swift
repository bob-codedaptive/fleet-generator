import Foundation

public struct HookEntry: Sendable, Equatable {
    public let event: String
    public let matcher: String?
    public let command: String

    public init(event: String, matcher: String?, command: String) {
        self.event = event
        self.matcher = matcher
        self.command = command
    }
}

public struct AgentFrontmatter {
    public var name: String
    public var description: String
    public var tools: String?
    public var disallowedTools: String?
    public var model: String?
    public var permissionMode: String?
    public var maxTurns: Int?
    public var skills: [String]?
    public var mcpServers: [String]?
    public var hooks: [HookEntry]?
    public var memory: String?
    public var background: Bool?
    public var effort: String?
    public var isolation: String?
    public var color: String?
    public var initialPrompt: String?
    public var status: String?
    public var updated: String?
    public var created: String?
    public var unknownKeys: [String: Any]

    public init(
        name: String,
        description: String,
        tools: String? = nil,
        disallowedTools: String? = nil,
        model: String? = nil,
        permissionMode: String? = nil,
        maxTurns: Int? = nil,
        skills: [String]? = nil,
        mcpServers: [String]? = nil,
        hooks: [HookEntry]? = nil,
        memory: String? = nil,
        background: Bool? = nil,
        effort: String? = nil,
        isolation: String? = nil,
        color: String? = nil,
        initialPrompt: String? = nil,
        status: String? = nil,
        updated: String? = nil,
        created: String? = nil,
        unknownKeys: [String: Any] = [:]
    ) {
        self.name = name
        self.description = description
        self.tools = tools
        self.disallowedTools = disallowedTools
        self.model = model
        self.permissionMode = permissionMode
        self.maxTurns = maxTurns
        self.skills = skills
        self.mcpServers = mcpServers
        self.hooks = hooks
        self.memory = memory
        self.background = background
        self.effort = effort
        self.isolation = isolation
        self.color = color
        self.initialPrompt = initialPrompt
        self.status = status
        self.updated = updated
        self.created = created
        self.unknownKeys = unknownKeys
    }
}

public struct Agent {
    public let path: URL
    public var frontmatter: AgentFrontmatter
    public var body: String
    public var rawYAML: String   // original YAML string, for v1 round-trip via re-emit

    public init(path: URL, frontmatter: AgentFrontmatter, body: String, rawYAML: String) {
        self.path = path
        self.frontmatter = frontmatter
        self.body = body
        self.rawYAML = rawYAML
    }
}
