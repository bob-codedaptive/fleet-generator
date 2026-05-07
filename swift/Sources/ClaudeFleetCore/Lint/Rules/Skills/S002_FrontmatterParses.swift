import Foundation

/// S002 — YAML frontmatter parses. Same pattern as S001: emitted by the
/// loader during parse, so this rule is a no-op pass-through.
public struct S002_FrontmatterParses: LintRule {
    public static let id = "S002"
    public static let severity: Severity = .error
    public static let title = "YAML frontmatter parses"
    public init() {}
    public func check(_ library: Library) -> [Finding] { [] }
}
