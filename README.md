# fleet-generator

Tools for setting up and configuring coding harnesses.

## Status

Early scaffolding. Nothing functional yet.

## Layout

```
fleet-generator/
├── src/fleet_generator/   # Python package
├── web/                   # HTML interface
├── pyproject.toml         # project config
└── .gitignore
```

## Development

Requires Python 3.11+.

```bash
python -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
```
