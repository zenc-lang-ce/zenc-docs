# zc-lsp

`zc-lsp` is the language server of Zen C: it gives an editor diagnostics, completion, go to definition and the rest of the features below, through the [Language Server Protocol](https://microsoft.github.io/language-server-protocol/). The editor starts it and talks to it over standard input and output; you do not run it yourself.

## Set up your editor

| Editor | How |
| :--- | :--- |
| VS Code, VSCodium, Cursor | The **Zen C - CE** extension starts `zc-lsp` for you: see [VS Code](https://zenc-lang-ce.github.io/docs/editors/#vs-code). |
| Neovim, Helix | A few lines of configuration: see [Other editors](https://zenc-lang-ce.github.io/docs/editors/#other-editors). |
| Any other editor with an LSP client | Register the `.zc` extension as a language, and give the client the command `zc-lsp`, with no arguments, over stdio. |

The editor finds `zc-lsp` in the `PATH`, or where its settings say (`zenc-lang-ce.serverPath` in VS Code). Keep it next to `zc`: it finds the standard library the same way (see [Tools](https://zenc-lang-ce.github.io/docs/tools/#the-standard-library)).

## Features

| Feature | LSP request |
| :--- | :--- |
| Errors and warnings as you type | `textDocument/publishDiagnostics` |
| Completion of names, and of fields and methods after `.` | `textDocument/completion` |
| The type or signature of a symbol, with its documentation | `textDocument/hover` |
| The parameters of the function being called, after `(` | `textDocument/signatureHelp` |
| Go to definition and to declaration | `textDocument/definition`, `textDocument/declaration` |
| Every use of a symbol in the workspace | `textDocument/references` |
| Rename a symbol and its uses | `textDocument/rename` |
| The symbols of a file, and search in the workspace | `textDocument/documentSymbol`, `workspace/symbol` |
| Colors by meaning: variables, functions, types... | `textDocument/semanticTokens/full` |
| Format a file, with the rules of [`zc-format`](https://zenc-lang-ce.github.io/docs/tools/zc-format/) | `textDocument/formatting` |
| Quick fixes: `var` → `let` and `const` → `def`, for code from older versions | `textDocument/codeAction` |

The editor sends the whole file on each change.

## The workspace

The workspace is the folder the editor opens: the `rootUri` of the client, or its first workspace folder. On start, `zc-lsp` reads every `.zc` file in it, so references, rename and symbol search cover the files you have not opened. It skips:

- the directories `.git`, `node_modules`, `obj`, `vhdl` and `vivado`;
- what the `.gitignore` at the root of the workspace ignores;
- what `exclude` says in `zenc.server.json`.

## Project configuration

A file `zenc.server.json` at the root of the workspace configures the server for that project:

```json
{
  "include_paths": ["../libs", "third_party/include"],
  "exclude": ["generated/", "*.tmp.zc"],
  "use_gitignore": true
}
```

| Key | What it does |
| :--- | :--- |
| `include_paths` | More directories to look for imports in, like `zc -I`. A relative path starts at the root of the workspace. |
| `exclude` | Patterns of files and directories that the workspace scan skips, in `.gitignore` syntax and relative to the root: a name matches at any depth (`build/`), a path with `/` is anchored to the root (`/vendor`, `docs/old/`), a trailing `/` matches only directories, and `*`, `?` and a leading `**/` work as in `.gitignore`. |
| `use_gitignore` | `true` by default. `false` does not read the `.gitignore`, and `exclude` alone decides what is skipped. |

Every key is optional. The server reads the file when it starts: restart it after changing the file (**Zen C: Restart Language Server** in VS Code). Invalid JSON ignores the whole file, and an unknown key or a value of the wrong type ignores that key. In both cases the editor shows a warning.

## Limitations

Completion offers keywords by where the cursor is: `fn` and `struct` outside functions, `let` and `return` inside them, `break` and `continue` inside loops. The server works that out from the text, not from the program:

- It counts the `{` and `}` from the start of the file to the cursor, also those inside strings and comments: after `println("{")`, it takes the cursor for inside a block.
- "Inside a loop" means that a loop starts earlier in the function: `break` and `continue` are still offered after the loop ends.
- `else` is offered after any `}`, not only after an `if`.

## Troubleshooting

`zc-lsp --verbose` (or `-v`) writes a log to the standard error: the version, the configuration it loaded, the files it skipped and why. Without it, the server discards its standard error. In VS Code, turn on `zenc-lang-ce.server.verbose` and open **Zen C: Show Language Server Output**; other editors keep the server's standard error in their LSP log.

The server exits when the editor that started it does.
