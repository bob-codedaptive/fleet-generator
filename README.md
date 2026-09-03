# fleet-generator

Tools for building, curating, and deploying Claude Code fleet (`.claude/`) libraries.

- **`web/fleet-generator.html`** — single-file browser wizard that *generates* a fresh `.claude/` bundle (agents, skills, hooks, settings, install script). See `web/SPEC.md` and `web/GUIDE.html`. Sample output in `sample_out/`.

## Repo layout

```
fleet-generator/
├── web/                     # HTML wizard (generation)
│   ├── fleet-generator.html
│   ├── SPEC.md
│   ├── GUIDE.html
│   └── archive/
├── sample_out/              # example wizard output
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

## Anvil (removed 2026-08-16)

`swift/` held Anvil, a Swift CLI that parsed, linted, edited and deployed
`.claude/` libraries already on disk. It shared no code with the wizard —
the wizard generates a bundle, Anvil audited one — and had not been
touched in four months.

It is in the git history if it is wanted again:

    git log --all -- swift/
    git checkout <sha> -- swift/

Removed rather than kept because a second, stale tool in the same repo
reads as part of the wizard and is not.
