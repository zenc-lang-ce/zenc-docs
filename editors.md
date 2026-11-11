# Editors

Zen C comes with a language server, `zc-lsp`, which any editor with an LSP client can use. The [VS Code extension](#vs-code) starts it for you; for other editors, see [Other editors](#other-editors).

`zc-lsp` is installed next to `zc` (see [Install](https://zenc-lang-ce.github.io/docs/install/)). With the portable executables, it is `zc-lsp.com`.

## VS Code

The **Zen C - CE** extension is on the [VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=zenc-lang-ce.zenc-lang) and on [Open VSX](https://open-vsx.org/extension/zenc-lang-ce/zenc-lang), for VSCodium, Cursor and other editors based on VS Code. Search for "Zen C" in the Extensions view, or run:

```bash
code --install-extension zenc-lang-ce.zenc-lang
```

The extension looks for `zc-lsp` in your `PATH`. If it is somewhere else, set `zenc-lang-ce.serverPath` to it; if the extension cannot find it, it asks where it is and saves the answer in that setting.

### Features

| Feature | What it does |
|---|---|
| Syntax highlighting | Keywords, types, functions, strings and comments, also before the language server starts. |
| Diagnostics | Errors and warnings as you type. |
| Completion | Variables, functions, struct fields, and methods after `.`. |
| Hover | The type or the signature of the symbol under the cursor, with its documentation. |
| Signature help | The parameters of the function being called, after `(`. |
| Go to definition and declaration | Jump to where a symbol is defined. |
| Find references | Every use of a symbol in the workspace. |
| Rename | Renames a symbol and its uses. |
| Outline and symbol search | The symbols of the file (Outline view, `Ctrl+Shift+O`) and of the workspace (`Ctrl+T`). |
| Semantic highlighting | Colors from the language server: variables, functions, structs, enums, types. |
| Formatting | Format Document, with `zc-format`'s rules. |
| Quick fixes | `var` → `let` and `const` → `def`, for code from older versions. |
| Breakpoints | Breakpoints in `.zc` files, for [debugging](#debugging). |

### Settings and commands

| Setting | Default | What it does |
|---|---|---|
| `zenc-lang-ce.serverPath` | empty | Path to `zc-lsp`. Empty: look it up in the `PATH`. |
| `zenc-lang-ce.server.enable` | `true` | Start the language server. Off: highlighting and editing support only. |
| `zenc-lang-ce.server.verbose` | `false` | Start the server with `--verbose`; its log goes to the "Zen C Language Server" output. |
| `zenc-lang-ce.trace.server` | `off` | Trace the messages between VS Code and the server: `off`, `messages` or `verbose`. |

The command palette has **Zen C: Restart Language Server**, for example after installing a new `zc-lsp`, and **Zen C: Show Language Server Output**, where its log and traces go.

### Debugging

A Zen C program compiled with debug information can be debugged as a C program: the generated C carries `#line` directives, so the debugger stops at lines of your `.zc` files and shows their variables.

> [!NOTE]
> `zc -g` turns on the `#line` directives, but does not pass `-g` to the C compiler yet ([#117](https://github.com/zenc-lang-ce/zenc/issues/117)). Use `-g3`, as below.

1. **Build with debug information.** Give the C compiler `-g3` (`zc` passes through the options it does not know) and turn optimizations off:

   ```bash
   zc build app.zc -o app -g3 -O0
   ```

2. **Install a debugger extension:** [CodeLLDB](https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb) on Linux and macOS, or [C/C++](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools) with GDB on Windows.

3. **Add a task that builds the current file**, in `.vscode/tasks.json`:

   ```json
   {
       "version": "2.0.0",
       "tasks": [
           {
               "label": "zc: build for debugging",
               "type": "shell",
               "command": "zc",
               "args": ["build", "${file}", "-o", "${fileDirname}/${fileBasenameNoExtension}", "-g3", "-O0"],
               "group": "build",
               "problemMatcher": []
           }
       ]
   }
   ```

4. **Add a launch configuration** that runs that task first, in `.vscode/launch.json`. With CodeLLDB:

   ```json
   {
       "version": "0.2.0",
       "configurations": [
           {
               "name": "Debug Zen C",
               "type": "lldb",
               "request": "launch",
               "program": "${fileDirname}/${fileBasenameNoExtension}",
               "cwd": "${workspaceFolder}",
               "preLaunchTask": "zc: build for debugging"
           }
       ]
   }
   ```

   On Windows, with C/C++ and the GDB of MinGW-w64:

   ```json
   {
       "name": "Debug Zen C",
       "type": "cppdbg",
       "request": "launch",
       "program": "${fileDirname}/${fileBasenameNoExtension}.exe",
       "cwd": "${workspaceFolder}",
       "MIMode": "gdb",
       "miDebuggerPath": "gdb.exe",
       "preLaunchTask": "zc: build for debugging"
   }
   ```

5. **Set a breakpoint** in a `.zc` file, open it and press **F5**.

The same works without VS Code: `lldb ./app` or `gdb ./app`, then `breakpoint set --file app.zc --line 4` (`break app.zc:4` in GDB).

## Other editors

Any editor with an LSP client can start `zc-lsp`: it talks LSP over standard input and output, and needs no arguments. Register the `.zc` extension as a language, then point the client to `zc-lsp`. [zc-lsp](https://zenc-lang-ce.github.io/docs/tools/zc-lsp/) explains what it does and how to configure it for a project.

### Neovim

In `init.lua`:

```lua
vim.filetype.add({ extension = { zc = "zenc" } })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "zenc",
  callback = function(args)
    vim.lsp.start({
      name = "zc-lsp",
      cmd = { "zc-lsp" },
      root_dir = vim.fs.root(args.buf, { ".git" }),
    })
  end,
})
```

### Helix

In `languages.toml` (in the Helix configuration directory, or `.helix/languages.toml` in a project):

```toml
[language-server.zc-lsp]
command = "zc-lsp"

[[language]]
name = "zenc"
scope = "source.zenc"
file-types = ["zc"]
roots = [".git"]
comment-token = "//"
indent = { tab-width = 4, unit = "    " }
language-servers = ["zc-lsp"]
```

`hx --health zenc` checks that Helix finds `zc-lsp`. There is no tree-sitter grammar for Zen C yet, so Helix shows the language server's features without syntax highlighting.
