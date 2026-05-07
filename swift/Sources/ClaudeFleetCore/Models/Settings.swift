import Foundation

public struct PermissionsBlock: Sendable, Equatable {
    public let allow: [String]
    public let deny: [String]
    public let ask: [String]

    public init(allow: [String] = [], deny: [String] = [], ask: [String] = []) {
        self.allow = allow
        self.deny = deny
        self.ask = ask
    }
}

public struct Settings: Sendable {
    public let path: URL
    public let permissions: PermissionsBlock?
    public let defaultAgent: String?
    public let cleanupPeriodDays: Int?
    public let disableSkillShellExecution: Bool?
    public let skillOverrides: [String: String]
    public let hooks: [Hook]
    public let rawJSON: String

    public init(
        path: URL,
        permissions: PermissionsBlock? = nil,
        defaultAgent: String? = nil,
        cleanupPeriodDays: Int? = nil,
        disableSkillShellExecution: Bool? = nil,
        skillOverrides: [String: String] = [:],
        hooks: [Hook] = [],
        rawJSON: String = ""
    ) {
        self.path = path
        self.permissions = permissions
        self.defaultAgent = defaultAgent
        self.cleanupPeriodDays = cleanupPeriodDays
        self.disableSkillShellExecution = disableSkillShellExecution
        self.skillOverrides = skillOverrides
        self.hooks = hooks
        self.rawJSON = rawJSON
    }
}
