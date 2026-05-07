# fleet-generator

Tools for building, curating, and deploying Claude Code fleet (`.claude/`) libraries.

Two complementary tools live in this repo:

- **`web/fleet-generator.html`** — single-file browser wizard that *generates* a fresh `.claude/` bundle (agents, skills, hooks, settings, install script). See `web/SPEC.md` and `web/GUIDE.html`. Sample output in `sample_out/`.
- **`swift/` — Anvil** — a Swift CLI that *parses, lints, edits, and deploys* libraries already on disk. Where the wizard sets up a new fleet, Anvil keeps existing ones honest.

## Anvil — Swift CLI for Claude fleet curation

Anvil reads any `.claude/` directory tree into a typed model and runs Anthropic compliance checks against it. Built as `swift/Sources/ClaudeFleetCore/` (library) + `swift/Sources/anvil/` (executable). macOS 13+, Swift 5.9+.

### Build & test

```bash
cd swift
swift build
swift test
```

### CLI surface

```
anvil lint <path>                          # all rules; exit 1 on errors
anvil lint <path> --rule S004 --rule A002  # subset
anvil lint <path> --json                   # machine-readable
anvil lint <path> --severity warning       # filter

anvil ls <path> [--type agents|skills|hooks|commands|all]
anvil show <path>/<name>                   # dump one agent or skill
anvil diff <lib-a> <lib-b>                 # readable text diff
anvil redundancy <path>                    # R001–R005 only

anvil edit <library>/<name> --set key=value   # YAML frontmatter mutation
anvil edit ... --set k1=v1 --set k2=v2

anvil deploy <src-lib>/agents/<name> <target>   # copy with manifest
anvil deploy <src-lib>/skills/<name> <target> --mode mirror|additive|prompt --force
anvil sync <src-lib> <target> [--mode ...] [--force]

anvil manifest <target>                    # show .anvil-manifest.json
anvil manifest <target> --check            # detect drift; exit 1 if any
```

Exit codes: `0` clean, `1` lint errors / drift, `2` invalid input, `3` deploy conflict needing human resolution.

### Lint rule set

22 rules total — Skills (S001–S010), Agents (A001–A007), Cross-cutting (C001–C005), and a redundancy/dialect-drift analyzer (R001–R005). See [the Anthropic rule catalogue research artifact](#) for citations. The loader normalizes both observed `settings.json` hook shapes (the canonical event-keyed map and the forge-style flat array) into a single in-memory representation, so rules run shape-agnostic.

### Deploy semantics

`anvil deploy` records every successful copy in `<target>/.claude/.anvil-manifest.json`:

```json
{
  "version": 1,
  "artifacts": {
    "skills/deep-research": {
      "source_library": "/Users/.../forge/.claude",
      "source_hash": "sha256:…",
      "deployed_at": "2026-05-07T12:00:00Z",
      "anvil_version": "0.4.0"
    }
  }
}
```

`anvil manifest --check` recomputes the target's current hash and reports each artifact as *clean*, *drifted*, or *missing*. `mirror` mode refuses to overwrite a drifted target without `--force`, so manual edits don't get clobbered silently.

## Repo layout

```
fleet-generator/
├── web/                     # HTML wizard (generation)
│   ├── fleet-generator.html
│   ├── SPEC.md
│   ├── GUIDE.html
│   └── archive/
├── sample_out/              # example wizard output (also a fixture)
├── swift/                   # Anvil — Swift CLI (parse / lint / edit / deploy)
│   ├── Package.swift
│   ├── Sources/
│   │   ├── ClaudeFleetCore/ # library
│   │   └── anvil/           # executable
│   └── Tests/
├── src/fleet_generator/     # Python scaffold (reserved for future tooling)
├── pyproject.toml
└── README.md
```

## Development — Python side

Requires Python 3.11+ if you intend to use the Python scaffold (currently empty).

```bash
python -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
```
