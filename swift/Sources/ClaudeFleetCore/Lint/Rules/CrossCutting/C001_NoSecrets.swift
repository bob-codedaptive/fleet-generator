import Foundation

/// C001 — Detect committed secrets in agent bodies, skill bodies, and
/// settings.json. Conservative regex catalog: AWS access keys, GitHub
/// tokens, Anthropic / OpenAI keys, JWTs.
public struct C001_NoSecrets: LintRule {
    public static let id = "C001"
    public static let severity: Severity = .error
    public static let title = "No committed secrets"
    public init() {}

    private struct Pattern {
        let label: String
        let regex: NSRegularExpression
    }

    private static let patterns: [Pattern] = {
        let raw: [(String, String)] = [
            ("AWS access key",  #"AKIA[0-9A-Z]{16}"#),
            ("GitHub PAT",      #"ghp_[A-Za-z0-9]{36}"#),
            ("GitHub fine-grained PAT", #"github_pat_[A-Za-z0-9]{22}_[A-Za-z0-9]{59}"#),
            ("Anthropic key",   #"sk-ant-[A-Za-z0-9_\-]{20,}"#),
            ("OpenAI key",      #"sk-(?:proj-)?[A-Za-z0-9]{40,}"#),
            ("JWT",             #"eyJ[A-Za-z0-9_-]+\.eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+"#),
        ]
        return raw.compactMap { (label, p) -> Pattern? in
            guard let re = try? NSRegularExpression(pattern: p) else { return nil }
            return Pattern(label: label, regex: re)
        }
    }()

    public func check(_ library: Library) -> [Finding] {
        var out: [Finding] = []
        for agent in library.agents {
            out.append(contentsOf: scan(agent.body, path: agent.path))
        }
        for skill in library.skills {
            out.append(contentsOf: scan(skill.body, path: skill.skillMD))
        }
        if let s = library.settings {
            out.append(contentsOf: scan(s.rawJSON, path: s.path))
        }
        return out
    }

    private func scan(_ text: String, path: URL) -> [Finding] {
        var out: [Finding] = []
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        for p in Self.patterns {
            if p.regex.firstMatch(in: text, range: range) != nil {
                out.append(Finding(
                    ruleID: Self.id,
                    severity: Self.severity,
                    path: path,
                    title: "Possible committed secret (\(p.label))",
                    detail: "A token matching the \(p.label) pattern was found.",
                    suggestedFix: "Rotate the secret immediately and remove it from the file."
                ))
            }
        }
        return out
    }
}
