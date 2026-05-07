import Foundation

public protocol LintRule {
    static var id: String { get }
    static var severity: Severity { get }
    static var title: String { get }
    func check(_ library: Library) -> [Finding]
}

public extension LintRule {
    var id: String { Self.id }
    var severity: Severity { Self.severity }
    var title: String { Self.title }
}
