import Foundation
import ArgumentParser
import ClaudeFleetCore

@main
struct Anvil: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "anvil",
        abstract: "Parse, lint, edit, and deploy Claude fleet (.claude/) libraries.",
        version: "0.2.0",
        subcommands: [Lint.self, Ls.self, Show.self, Diff.self, Redundancy.self]
    )
}

// MARK: - lint

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
        let url = expand(path)
        let library = try loadOrExit(url)
        let ruleIDs: Set<String>? = rule.isEmpty ? nil : Set(rule)
        let minSev: Severity? = severity.flatMap { Severity(rawValue: $0.lowercased()) }

        let engine = RuleEngine(rules: RuleEngine.defaultRules)
        let findings = engine.run(on: library, ruleIDs: ruleIDs, minSeverity: minSev)

        if json {
            try emitJSON(findings)
        } else {
            printFindings(findings, library: library)
        }
        if findings.contains(where: { $0.severity == .error }) {
            throw ExitCode(1)
        }
    }
}

// MARK: - ls

struct Ls: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "List artifacts in a .claude/ library."
    )

    enum Kind: String, ExpressibleByArgument {
        case agents, skills, hooks, commands, all
    }

    @Argument(help: "Path to a .claude/ directory.")
    var path: String

    @Option(name: .long, help: "What to list: agents, skills, hooks, commands, all.")
    var type: Kind = .all

    func run() throws {
        let url = expand(path)
        let lib = try loadOrExit(url)

        if type == .agents || type == .all {
            print("agents (\(lib.agents.count)):")
            for a in lib.agents.sorted(by: { $0.frontmatter.name < $1.frontmatter.name }) {
                print("  \(a.frontmatter.name)  [model: \(a.frontmatter.model ?? "—")]")
            }
        }
        if type == .skills || type == .all {
            print("skills (\(lib.skills.count)):")
            for s in lib.skills.sorted(by: { $0.frontmatter.name < $1.frontmatter.name }) {
                print("  \(s.frontmatter.name)  [\(s.bodyLines) lines]")
            }
        }
        if type == .hooks || type == .all {
            print("hooks (\(lib.hooks.count)):")
            for h in lib.hooks {
                print("  \(h.event):\(h.matcher ?? "—")  ->  \(h.command)")
            }
        }
        if type == .commands || type == .all {
            print("commands (\(lib.commands.count)):")
            for c in lib.commands {
                print("  \(c.name)")
            }
        }
    }
}

// MARK: - show

struct Show: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Dump one agent or skill (frontmatter + body)."
    )

    @Argument(help: "Path of the form <library>/<agent-or-skill-name>.")
    var target: String

    func run() throws {
        let (libRoot, name) = try splitTarget(target)
        let lib = try loadOrExit(libRoot)
        if let a = lib.agents.first(where: { $0.frontmatter.name == name }) {
            print("# Agent: \(a.frontmatter.name)")
            print("Path: \(a.path.path)")
            print("---")
            print(a.rawYAML)
            print("---")
            print(a.body)
            return
        }
        if let s = lib.skills.first(where: { $0.frontmatter.name == name }) {
            print("# Skill: \(s.frontmatter.name)")
            print("Path: \(s.skillMD.path)")
            print("---")
            print(s.rawYAML)
            print("---")
            print(s.body)
            return
        }
        FileHandle.standardError.write(Data("anvil: no agent or skill named '\(name)' in \(libRoot.path)\n".utf8))
        throw ExitCode(2)
    }
}

// MARK: - diff

struct Diff: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Diff two .claude/ libraries."
    )

    @Argument(help: "Library A path.")
    var a: String

    @Argument(help: "Library B path.")
    var b: String

    func run() throws {
        let aLib = try loadOrExit(expand(a))
        let bLib = try loadOrExit(expand(b))
        let report = LibraryDiff.compute(aLib, bLib).textReport()
        print(report)
    }
}

// MARK: - redundancy

struct Redundancy: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Run only the redundancy / dialect-drift detectors (R001–R005)."
    )

    @Argument(help: "Path to a .claude/ directory.")
    var path: String

    @Flag(name: .long, help: "Emit JSON instead of human-readable text.")
    var json: Bool = false

    func run() throws {
        let lib = try loadOrExit(expand(path))
        let engine = RuleEngine(rules: RuleEngine.redundancyOnly)
        let findings = engine.run(on: lib).filter { $0.ruleID.hasPrefix("R") }
        if json {
            try emitJSON(findings)
        } else {
            printFindings(findings, library: lib)
        }
    }
}

// MARK: - Shared helpers

func expand(_ path: String) -> URL {
    URL(fileURLWithPath: (path as NSString).expandingTildeInPath)
}

func loadOrExit(_ url: URL) throws -> Library {
    do {
        return try LibraryLoader.load(url)
    } catch {
        FileHandle.standardError.write(Data("anvil: failed to load library at \(url.path): \(error)\n".utf8))
        throw ExitCode(2)
    }
}

func splitTarget(_ raw: String) throws -> (URL, String) {
    let url = expand(raw)
    let last = url.lastPathComponent
    let parent = url.deletingLastPathComponent()
    if parent.lastPathComponent == "agents" || parent.lastPathComponent == "skills" {
        return (parent.deletingLastPathComponent(), (last as NSString).deletingPathExtension)
    }
    return (parent, (last as NSString).deletingPathExtension)
}

func emitJSON(_ findings: [Finding]) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(JSONReport(findings: findings))
    FileHandle.standardOutput.write(data)
    FileHandle.standardOutput.write(Data("\n".utf8))
}

func printFindings(_ findings: [Finding], library: Library) {
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

private struct JSONReport: Codable {
    let findings: [Finding]
}
