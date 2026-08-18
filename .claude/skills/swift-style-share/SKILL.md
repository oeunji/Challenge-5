---
name: swift-style-share
description: Use when writing, reviewing, or refactoring Swift code in this project — covers naming, indentation, closures, comments, and constant-organization conventions from the StyleShare Swift Style Guide.
---

# Swift Style Share

## Overview

Coding conventions for Swift in this project, following [StyleShare's Swift Style Guide](https://github.com/StyleShare/swift-style-guide) (CC-BY-4.0). Anything not covered here falls back to Apple's [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines) and [SE-0005](https://github.com/apple/swift-evolution/blob/master/proposals/0005-objective-c-name-translation.md).

## When to Use

Writing new Swift code, reviewing or refactoring existing Swift code, or settling a style question in this repo.

## Quick Reference

| Area | Rule |
|---|---|
| Indent | 2 spaces, never tabs |
| Colon `:` | space after only — `let x: Int`, not `let x : Int` |
| Line length | max 99 characters |
| Imports | system frameworks first, blank line, then third-party alphabetized |
| Class / struct / enum / protocol names | UpperCamelCase, no prefix |
| Function / variable / constant names | lowerCamelCase — never `MAX_LINES`, never a `get`-prefixed function |
| Enum cases | lowerCamelCase — `.success`, not `.Success` |
| Acronyms | lowercase when leading (`urlString`), uppercase otherwise (`userID`, not `userId`) |
| Closures | no parens around params, no `Void` return type, omit inferrable types, omit the label when it's the only/last closure |
| Collections | `[T]` / `[T: U]` — never `Array<T>` / `Dictionary<T, U>` |
| Struct construction | native initializer (`CGRect(x:y:width:height:)`) — never `CGRectMake` |
| `self` | always explicit inside a class/struct |
| Classes | mark `final` unless designed for subclassing |
| Protocol conformance | adopt in a separate `// MARK: - ProtocolName` extension, not the primary declaration |
| Comments | `///` for doc comments; `// MARK:` to divide sections, with a blank line above and below |

## Full Reference

See `style-guide.md` in this skill for every rule with good/bad code examples — delegate method naming, action-method naming (`did`/`will`/`should`), multi-closure line-wrapping, `guard let` / `if let` wrapping, and the `Metric`/`Font`/`Color` enum pattern for grouping related constants.
