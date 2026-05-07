import Foundation

public struct Finding: Sendable, Codable, Equatable {
    public let ruleID: String
    public let severity: Severity
    public let path: String
    public let line: Int?
    public let title: String
    public let detail: String
    public let suggestedFix: String?

    public init(
        ruleID: String,
        severity: Severity,
        path: URL,
        line: Int? = nil,
        title: String,
        detail: String,
        suggestedFix: String? = nil
    ) {
        self.ruleID = ruleID
        self.severity = severity
        self.path = path.path
        self.line = line
        self.title = title
        self.detail = detail
        self.suggestedFix = suggestedFix
    }
}
