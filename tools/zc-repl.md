# zc-repl

`zc-repl` runs Zen C a line at a time. An expression prints its value; a statement, a function or a struct joins the session, and later lines can use it:

```text
$ zc-repl
Zen C REPL (v0.5.1)
Type 'exit' or 'quit' to leave.
Type :help for commands.
zenc >>> let x = 5;
zenc >>> x * 2
10
zenc >>> fn square(n: int) -> int { return n * n; }
zenc >>> square(x)
25
```

A line with an open `{` or `(` continues on the next one.

| Option | What it does |
| :--- | :--- |
| `-c <line>` | Runs one line and exits: `zc-repl -c '1 + 2'`. |
| `-h`, `--help` | Lists the options. |

## Requirements

Each line compiles the session again and runs it, with the C compiler of the system (`cc`, or `gcc` on Windows; see [Requirements](https://zenc-lang-ce.github.io/docs/install/#requirements)). `:run`, `:time`, `:type`, `:c` and `:vars` call `zc`, so keep `zc-repl` next to it.

## Commands

| Command | What it does |
| :--- | :--- |
| `:help` | Lists the commands and the keys. |
| `:quit` | Exits. `exit`, `quit` and Ctrl+D too. |
| `:clear` | Clears the screen. |
| `:history` | Shows the lines of the session, numbered. |
| `:undo` | Removes the last line from the session. |
| `:delete <n>` | Removes line `n`. |
| `:edit [n]` | Edits line `n` (the last one, without `n`) in `$EDITOR`. |
| `:reset` | Empties the session. |
| `:vars`, `:funcs`, `:structs` | Lists the variables, functions or structs of the session. |
| `:imports` | Lists the imports of the session. |
| `:show <name>` | Shows the declaration of a function or struct. |
| `:type <expr>` | Shows the type of an expression. |
| `:doc <name>` | Shows the documentation of a symbol. |
| `:c <code>` | Shows the C of the session with `code` added. |
| `:time <expr>` | Runs an expression 1000 times and shows how long it took. |
| `:watch <expr>` | Prints the value of an expression after each line. `:watch` alone lists them. |
| `:unwatch <n>` | Removes watch `n`. |
| `:run` | Runs the whole session as a program. |
| `:save <file>` | Saves the session to a `.zc` file. |
| `:load <file>` | Loads a `.zc` file into the session. |
| `:reload` | Loads the plugins of the session again. |
| `:plot <array>` | Draws a bar chart of the values of an array: `:plot v`. |
| `! <cmd>` | Runs a shell command: `! ls`. |

## Keys

| Key | What it does |
| :--- | :--- |
| Up, Down | Previous and next line of the history. |
| Tab | Completes a name. |
| Ctrl+A, Ctrl+E | Start and end of the line. |
| Ctrl+U, Ctrl+K | Deletes up to the start or the end of the line. |
| Ctrl+L | Clears the screen. |

The session is saved to `~/.zenc_history` on exit, and the next start loads it again: its variables and functions are still there. `:reset` empties it.
