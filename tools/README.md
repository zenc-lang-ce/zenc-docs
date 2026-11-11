# Tools

Zen C comes as the compiler, `zc`, and four standalone tools installed next to it (see [Install](https://zenc-lang-ce.github.io/docs/install/)):

| Tool | What it does |
| :--- | :--- |
| [`zc`](https://zenc-lang-ce.github.io/docs/tools/zc/) | Compiles a program: builds it, runs it, checks it or translates it to C. |
| [`zc-format`](https://zenc-lang-ce.github.io/docs/tools/zc-format/) | Indents a source file. |
| [`zc-doc`](https://zenc-lang-ce.github.io/docs/tools/zc-doc/) | Writes the documentation of a file and its imports as Markdown. |
| [`zc-repl`](https://zenc-lang-ce.github.io/docs/tools/zc-repl/) | Runs Zen C a line at a time. |
| [`zc-lsp`](https://zenc-lang-ce.github.io/docs/tools/zc-lsp/) | The language server, for [editors](https://zenc-lang-ce.github.io/docs/editors/). |

With the portable executables, each name ends in `.com`: `zc.com`, `zc-lsp.com`...

`zc format`, `zc doc`, `zc repl` and `zc lsp` still launch the tools, with a note that they are deprecated. They look for the tool next to `zc` (also with `.com` or `.exe`), then in the `PATH`, and pass it the rest of the arguments: `zc format app.zc` runs `zc-format app.zc`.

## The standard library

Every tool finds the standard library the same way: `std.zc` and `std/` in the directory of the executable or one of its parents, or in their `share/zenc`, where `make install` puts it. The environment variable `ZC_ROOT` names another directory, and wins over that search. `zc --paths` prints where `zc` looks for imports.
