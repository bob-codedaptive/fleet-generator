import Foundation
import ArgumentParser
import ClaudeFleetCore

@main
struct Anvil: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "anvil",
        abstract: "Parse, lint, edit, and deploy Claude fleet (.claude/) libraries.",
        version: "0.1.0",
        subcommands: [Lint.self]
    )
}

struct Lint: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Lint a .claude/ library against Anthropic compliance rules."
    )

    @Argument(help: "Path to a .claude/ directory.")
    var path: String

    @Option(name: .long, help: "Restrict to specific rule IDs (repeatable).")
    var rule: [String] = []

    @Option(name: .long, help: "Filter to severity at or above (error|warning|info).")
    var severity: String?

    @Flag(name: .long, help: "Emit JSON instead of human-readable text.")
    var json: Bool = false

    func run() throws {
        let url = URL(fileURLWithPath: (path as NSString).expandingTildeInPath)
        let library: Library
        do {
            library = try LibraryLoader.load(url)
        } catch {
            FileHandle.standardError.write(Data("anvil: failed to load library at \(url.path): \(error)\n".utf8))
            throw ExitCode(2)
        }

        let ruleIDs: Set<String>? = rule.isEmpty ? nil : Set(rule)
        let minSev: Severity? = severity.flatMap { Severity(rawValue: $0.lowercased()) }

        let engine = RuleEngine(rules: RuleEngine.defaultRules)
        let findings = engine.run(on: library, ruleIDs: ruleIDs, minSeverity: minSev)

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(JSONReport(findings: findings))
            FileHandle.standardOutput.write(data)
            FileHandle.standardOutput.write(Data("\n".utf8))
        } else {
            printHumanReadable(findings: findings, library: library)
        }

        if findings.contains(where: { $0.severity == .error }) {
            throw ExitCode(1)
        }
    }

    private func printHumanReadable(findings: [Finding], library: Library) {
        let errors = findings.filter { $0.severity == .error }.count
        let warnings = findings.filter { $0.severity == .warning }.count
        let infos = findings.filter { $0.severity == .info }.count

        for f in findings {
            let sev = f.severity.rawValue.uppercased().padding(toLength: 7, withPad: " ", startingAt: 0)
            print("[\(f.ruleID)] \(sev) \(f.path): \(f.title)")
            if !f.detail.isEmpty {
                print("        \(f.detail)")
            }
            if let fix = f.suggestedFix {
                print("        fix: \(fix)")
            }
        }

        print("")
        print("Library: \(library.root.path)  (scope: \(library.scope.rawValue))")
        print("Agents: \(library.agents.count)  Skills: \(library.skills.count)  Hooks: \(library.hooks.count)  Commands: \(library.commands.count)  Rules: \(library.rules.count)")
        print("Findings: \(errors) error(s), \(warnings) warning(s), \(infos) info")
    }
}

private struct JSONReport: Codable {
    let findings: [Finding]
}
