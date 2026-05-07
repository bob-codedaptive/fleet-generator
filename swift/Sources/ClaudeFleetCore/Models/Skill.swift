import Foundation

public struct SkillFrontmatter {
    public var name: String
    public var description: String
    public var whenToUse: String?
    public var argumentHint: String?
    public var arguments: String?
    public var disableModelInvocation: Bool?
    public var userInvocable: Bool?
    public var allowedTools: String?
    public var model: String?
    public var effort: String?
    public var context: String?
    public var agent: String?
    public var hooks: [HookEntry]?
    public var paths: [String]?
    public var shell: String?
    public var status: String?
    public var updated: String?
    public var created: String?
    public var tags: [String]?
    public var unknownKeys: [String: Any]

    public init(
        name: String,
        description: String,
        whenToUse: String? = nil,
        argumentHint: String? = nil,
        arguments: String? = nil,
        disableModelInvocation: Bool? = nil,
        userInvocable: Bool? = nil,
        allowedTools: String? = nil,
        model: String? = nil,
        effort: String? = nil,
        context: String? = nil,
        agent: String? = nil,
        hooks: [HookEntry]? = nil,
        paths: [String]? = nil,
        shell: String? = nil,
        status: String? = nil,
        updated: String? = nil,
        created: String? = nil,
        tags: [String]? = nil,
        unknownKeys: [String: Any] = [:]
    ) {
        self.name = name
        self.description = description
        self.whenToUse = whenToUse
        self.argumentHint = argumentHint
        self.arguments = arguments
        self.disableModelInvocation = disableModelInvocation
        self.userInvocable = userInvocable
        self.allowedTools = allowedTools
        self.model = model
        self.effort = effort
        self.context = context
        self.agent = agent
        self.hooks = hooks
        self.paths = paths
        self.shell = shell
        self.status = status
        self.updated = updated
        self.created = created
        self.tags = tags
        self.unknownKeys = unknownKeys
    }
}

public struct Skill {
    public let directory: URL
    public let skillMD: URL
    public var frontmatter: SkillFrontmatter
    public var body: String
    public var bodyLines: Int
    public var supportingFiles: [URL]
    public var rawYAML: String

    public init(
        directory: URL,
        skillMD: URL,
        frontmatter: SkillFrontmatter,
        body: String,
        bodyLines: Int,
        supportingFiles: [URL],
        rawYAML: String
    ) {
        self.directory = directory
        self.skillMD = skillMD
        self.frontmatter = frontmatter
        self.body = body
        self.bodyLines = bodyLines
        self.supportingFiles = supportingFiles
        self.rawYAML = rawYAML
    }
}
