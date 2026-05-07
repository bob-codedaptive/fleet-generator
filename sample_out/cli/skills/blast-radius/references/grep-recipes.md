# Grep Recipes by Language

## TypeScript / JavaScript

```bash
# All references to a symbol
grep -rn "\\bSymbolName\\b" src/ tests/ --include="*.ts" --include="*.tsx" --include="*.js"

# Imports specifically
grep -rn "import.*SymbolName" src/

# JSDoc and comments
grep -rn "SymbolName" src/ --include="*.md"
```

## Python

```bash
grep -rn "\\bsymbol_name\\b" src/ tests/ --include="*.py"
grep -rn "from .* import.*symbol_name" src/
```

## Swift

```bash
grep -rn "\\bSymbolName\\b" Sources/ Tests/ --include="*.swift"
```

## Go

```bash
grep -rn "\\bSymbolName\\b" . --include="*.go"
```

## Tips

- For short / common names, use word boundaries (`\\b`)
- Cast a wide net first; narrow once you have the picture
- For renamed symbols, grep BOTH old and new names
- Don't forget docs and configs (`*.md`, `*.yaml`, `*.json`)
