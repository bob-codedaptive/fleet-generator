import Foundation

public struct RuleEngine {
    public let rules: [any LintRule]

    public init(rules: [any LintRule]) {
        self.rules = rules
    }

    /// Runs all (filtered) rules against the library, prepends any
    /// load-time findings (S001 missing SKILL.md, S002 parse failures)
    /// already accumulated by the loader.
    public func run(
        on library: Library,
        ruleIDs: Set<String>? = nil,
        minSeverity: Severity? = nil
    ) -> [Finding] {
        var all: [Finding] = library.loadFindings
        for rule in rules {
            if let ids = ruleIDs, !ids.contains(type(of: rule).id) { continue }
            all.append(contentsOf: rule.check(library))
        }
        if let min = minSeverity {
            all = all.filter { $0.severity <= min }
        }
        return all.sorted { lhs, rhs in
            if lhs.severity != rhs.severity { return lhs.severity < rhs.severity }
            if lhs.path != rhs.path { return lhs.path < rhs.path }
            return lhs.ruleID < rhs.ruleID
        }
    }

    /// All rules built into ClaudeFleetCore. Phase A includes the 5 starter
    /// rules. Phases B onwards extend this list.
    public static let defaultRules: [any LintRule] = [
        S001_SkillMDExists(),
        S002_FrontmatterParses(),
        S003_SkillNameValid(),
        S004_DescriptionValid(),
        A001_NameAndDescriptionPresent(),
    ]
}
