# Zen C Documentation

Welcome to the official documentation repository for the **Zen C** programming language. This repository contains the technical specifications, language reference, and standard library documentation.

## Documentation Index

### Standard Library
The core of Zen C's power lies in its standard library. Detailed documentation for each module can be found in the [std/](std/) directory.

| Module | Description |
| :--- | :--- |
| **[vec](std/vec.md)** | Dynamic array implementation. |
| **[string](std/string.md)** | Modern, safe string handling. |
| **[net](std/net.md)** | High-level networking (TCP, HTTP). |
| **[cuda](std/cuda.md)** | First-class GPU programming support. |
| **[thread](std/thread.md)** | Concurrency and parallelism. |
| **[json](std/json.md)** | Built-in JSON serialization/deserialization. |

> [!NOTE]
> For a high-level overview of the library, see the **[Standard Library README](std/README.md)**.

### Technical Specifications
Deep dives into the compiler's internals and tooling protocols.

- **[Lexer Specification](lex.md)**: Detailed breakdown of Zen C's tokens and grammar rules.
- **[Plugins](plugins.md)**: Blocks of other languages in Zen C, and how to write a plugin.
- **[Install](install.md)**: Building and installing Zen C on Linux, macOS and Windows.
- **[Changelog](changelog.md)**: Every change in each release.
- **[Migrations](migrations/)**: What to change in your code for each release ([0.4.4 to 0.5](migrations/0-4-4-to-0-5.md)).

### Tools

Zen C comes as the compiler and four tools, installed next to it. **[Tools](tools/)** has a page for each one:

| Tool | What it does |
| :--- | :--- |
| [`zc`](tools/zc.md) | Compiles a program: builds it, runs it, checks it or translates it to C. |
| [`zc-format`](tools/zc-format.md) | Indents a source file. |
| [`zc-doc`](tools/zc-doc.md) | Writes the documentation of a file and its imports as Markdown. |
| [`zc-repl`](tools/zc-repl.md) | Runs Zen C a line at a time. |
| [`zc-lsp`](tools/zc-lsp.md) | The language server, for [editors](editors.md). |

## Reference (17 chapters)

| # | Chapter | Description |
|:---|:---|:---|
| 1 | [Variables & Constants](reference/01-variables-constants.md) | let, types, mutability |
| 2 | [Primitive Types](reference/02-primitive-types.md) | int, float, bool, char, etc. |
| 3 | [Aggregate Types](reference/03-aggregate-types.md) | Arrays, slices, tuples |
| 4 | [Functions & Lambdas](reference/04-functions-lambdas.md) | Functions, closures |
| 5 | [Control Flow](reference/05-control-flow.md) | if, while, for, match |
| 6 | [Operators](reference/06-operators.md) | Arithmetic, comparison, sugar operators |
| 7 | [Printing & F-strings](reference/07-printing-interpolation.md) | Output, string interpolation |
| 8 | [Memory & Lifetimes](reference/08-memory-management.md) | Ownership, borrowing |
| 9 | [OOP](reference/09-oop.md) | Traits, impl blocks, methods |
| 10 | [Generics](reference/10-generics.md) | Type-safe templates |
| 11 | [Concurrency](reference/11-concurrency.md) | Threads with `std/thread.zc` |
| 12 | [Advanced](reference/12-advanced.md) | Inline assembly, raw blocks |
| 13 | [Comptime](reference/13-comptime.md) | Compile-time evaluation and metaprogramming |
| 14 | [Interop](reference/14-interop.md) | C, C++, CUDA, Objective-C interop |
| 15 | [Unit Testing](reference/15-unit-testing-framework.md) | test, assert, expect |
| 16 | [Diagnostics](reference/16-diagnostics.md) | Compiler warnings, categories |
| 17 | [MISRA Rules](reference/17-misra-rules.md) | Safety rules, Zen-specific checks |

## Related Resources

- **[zenc](https://github.com/zenc-lang-ce/zenc)**: The core compiler source code.
- **[awesome-zenc](https://github.com/zenc-lang-ce/awesome-zenc)**: A collection of examples and Rosetta Code implementations.

## Contributing to Docs

Documentation is a community effort. If you find a typo, outdated information, or want to contribute a new guide, please open a documentation issue or pull request.

### Versions and branches

Each released minor version of Zen C has its own branch here, so the documentation of a release does not change when the next one changes the language:

- **`main`** documents the version in development, the next release (0.6 while 0.5 is the latest).
- **`release/X.Y`** (e.g. `release/0.5`) documents the released version X.Y and its patch releases (0.5.1, 0.5.2…). It is created from `main` when X.Y is released, and from then on it only receives fixes.

Which branch your pull request goes to:

- **New or changed behaviour** (a new feature, syntax or standard library function, something that works differently from the last release): `main`.
- **A fix to the documentation of a released version** (a typo, a wrong example, something the release does but the docs describe wrongly): `main`, and then the same commit cherry-picked onto `release/X.Y` (`git cherry-pick -x <commit>`). If the text has changed in `main` since the release, open a separate pull request against `release/X.Y`.
- **A patch release** (0.5.2): its changelog and any page it changes go to `release/0.5`, and the changelog entry also to `main`.

The website ([docs.zenc-lang.org](https://docs.zenc-lang.org)) publishes the latest release branch, `release/0.5`: pushes to `main` do not reach it.

When the compiler releases a new minor version X.Y, create `release/X.Y` from the commit of `main` that documents it, and `main` moves on to the next version. Then point the `branches` of `.github/workflows/sync-docs.yml` at `release/X.Y`, in both `main` and the new branch.

### Preview the website locally

The website ([zenc-lang-ce.github.io](https://github.com/zenc-lang-ce/zenc-lang-ce.github.io)) publishes these pages through `scripts/sync_to_site.sh`. To see your changes as they will look there, clone the website next to this repository and run:

```bash
make serve                          # WEB=../zenc-lang-ce.github.io by default
make serve WEB=../path/to/website   # if it is somewhere else
```

It serves the site at http://localhost:1111/docs/ and updates it about half a minute after you save a file. It needs Python 3, `rsync`, and Zola 0.18.0 or Docker. `make clean` removes the copy it works on (`.preview/`).
