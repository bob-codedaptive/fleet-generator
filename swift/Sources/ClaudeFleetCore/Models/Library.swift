import Foundation

public struct Library {
    public let root: URL
    public let scope: Scope
    public var agents: [Agent]
    public var skills: [Skill]
    public var hooks: [Hook]
    public var settings: Settings?
    public var rules: [RuleDoc]
    public var commands: [LegacyCommand]
    public var loadFindings: [Finding]   // parser-discovered issues (S001/S002)

    public init(
        root: URL,
        scope: Scope = .unknown,
        agents: [Agent] = [],
        skills: [Skill] = [],
        hooks: [Hook] = [],
        settings: Settings? = nil,
        rules: [RuleDoc] = [],
        commands: [LegacyCommand] = [],
        loadFindings: [Finding] = []
    ) {
        self.root = root
        self.scope = scope
        self.agents = agents
        self.skills = skills
        self.hooks = hooks
        self.settings = settings
        self.rules = rules
        self.commands = commands
        self.loadFindings = loadFindings
    }
}
