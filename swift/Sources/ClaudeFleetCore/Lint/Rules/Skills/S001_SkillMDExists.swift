import Foundation

/// S001 — Each skill directory must contain `SKILL.md`.
/// LibraryLoader emits this finding directly when scanning the skills/ tree;
/// this rule is a no-op so that explicit `--rule S001` invocations still
/// surface the loader-emitted findings (RuleEngine prepends `loadFindings`).
public struct S001_SkillMDExists: LintRule {
    public static let id = "S001"
    public static let severity: Severity = .error
    public static let title = "SKILL.md exists in skill directory"
    public init() {}
    public func check(_ library: Library) -> [Finding] { [] }
}
