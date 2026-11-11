# Plugins

A plugin adds a kind of block to Zen C. In `name! { ... }`, `zc` hands the text between the braces to the plugin while it compiles, and the plugin writes the C that takes the block's place: a small language, a table, generated code.

```zc
import plugin "plugins/lisp" as lisp

fn main() {
    lisp! {
        (defun square (x) (* x x))
        (print (square 10))
    }
}
```

A plugin is a shared library (`.so`, `.dll` on Windows), usually written in Zen C, that `zc` loads when a program imports it.

## Use a plugin

```zc
import plugin "<path>" [as <name>]
```

The block takes the name after `as`, or else the plugin's own name. A block can be a statement or an expression, depending on what the plugin writes: `let n = words! { one two three };`. It ends at the `}` that closes its `{`, so the braces inside it must be balanced.

`zc` adds `.so` (`.dll` on Windows) to the path, and looks for the file:

1. With a path that starts with `./` or `../`, next to the file that imports it.
2. Otherwise, from the current directory.
3. By its name, in `share/zenc/plugins` of the prefix `zc` was built for (`/usr/local/share/zenc/plugins` by default), where `make install` puts the plugins of the repository.

When it cannot find it, the compilation stops:

```text
error: Could not load plugin 'plugins/lisp' (tried built-ins and dynamic loading)
```

`zc` does not compile a plugin: build it first (see [Build it](#build-it)), and again after each change.

### The plugins of the repository

The [`plugins/`](https://github.com/zenc-lang-ce/zenc/tree/main/plugins) directory of the repository has five:

| Plugin | Block |
| :--- | :--- |
| `lisp` | Lisp: `(defun square (x) (* x x))`, `(print (square 10))`. |
| `forth` | Forth: `10 20 + .` |
| `sql` | `CREATE TABLE` and `INSERT`, as C structs and arrays. |
| `brainfuck` | Brainfuck. |
| `befunge` | Befunge. |

`zc.com`, the [portable executable](https://zenc-lang-ce.github.io/docs/install/), has them inside: `import plugin "plugins/lisp"` works anywhere. `make install` installs them in `share/zenc/plugins`. The archives of the releases do not include them: build them from a checkout of the repository, with `make`, or one by one:

```bash
zc build plugins/lisp.zc -shared -o plugins/lisp.so
```

## Write a plugin

A plugin imports `std/plugin.zc` and exports a function `z_plugin_init`, which returns its `ZPlugin`:

```zc
import "std/plugin.zc"

include <stdio.h>
include <ctype.h>

// Writes the text of the block, in capitals, as a call to puts.
fn upper_transpile(body: char*, api: ZApi*) {
    let out = api.out;
    fputs("puts(\"", out);
    let i = 0;
    while body[i] != 0 {
        let ch = body[i];
        if ch != '\n' && ch != '"' && ch != '\\' {
            fputc(toupper(ch), out);
        }
        i = i + 1;
    }
    fputs("\");", out);
}

let upper_plugin = ZPlugin {
    name: "upper",
    handler: upper_transpile,
    hover_handler: NULL
};

@export
fn z_plugin_init() -> ZPlugin* {
    return &upper_plugin;
}
```

```zc
import plugin "./upper"

fn main() {
    upper! { hello from a plugin }   // puts(" HELLO FROM A PLUGIN ");
}
```

### ZPlugin

| Field | What it is |
| :--- | :--- |
| `name` | The name of the plugin, and of its blocks when the import has no `as`. |
| `handler` | `fn(body: char*, api: ZApi*)`: gets the text of a block, and writes its C to `api.out`. `zc` calls it once for each block. |
| `hover_handler` | Optional, `NULL` without it: the text the editor shows over the block (see [Hover](#hover)). |

### ZApi

| Field | What it is |
| :--- | :--- |
| `out` | Where the C of the block goes, a `FILE*`: `fputs(..., api.out)`. |
| `hoist_out` | C that goes at the top level of the program, before the functions. |
| `filename`, `current_line` | The file and the line of the block. |
| `error`, `warn`, `note` | Report a problem in the block, with a `printf` format: `api.error(api, "unknown word '%s'", word)`. An error stops the compilation after the block. |
| `config` | `is_debug`, `verbose`, `target` (the operating system) and `cc` (the C compiler) of the compilation. |
| `user_data` | Free for the plugin. |

`report_error(msg)`, `report_warn(msg)` and `report_note(msg)` are the same without a format: `api.report_error("empty block")`.

> [!IMPORTANT]
> A function the plugin writes goes to `hoist_out`, not to `out`: in `out` it ends up inside the function that holds the block, and only GCC accepts nested functions.

This plugin uses both: the block is an expression, which calls a function it writes once at the top level, and an empty block is an error:

```zc
fn words_transpile(body: char*, api: ZApi*) {
    let count = 0;
    let in_word = false;
    let i = 0;
    while body[i] != 0 {
        let ch = body[i];
        let space = ch == ' ' || ch == '\n' || ch == '\t';
        if !space && !in_word {
            count = count + 1;
        }
        in_word = !space;
        i = i + 1;
    }
    if count == 0 {
        api.error(api, "words! needs at least one word");
    }
    fputs(f"static int words_{api.current_line}(void) {{ return {count}; }}\n", api.hoist_out);
    fputs(f"words_{api.current_line}()", api.out);
}
```

### Build it

```bash
zc build upper.zc -shared -o upper.so
```

### Hover

With a `hover_handler`, the [language server](https://zenc-lang-ce.github.io/docs/tools/zc-lsp/) asks the plugin what to show when the cursor is over its block. It gets the text of the block and the position of the cursor in it (line and column, from 0), and returns Markdown, or `NULL` for nothing:

```zc
fn upper_hover(_body: char*, _line: int, _col: int) -> char* {
    return "**upper!**: prints the block in capitals.";
}
```

[`plugins/brainfuck.zc`](https://github.com/zenc-lang-ce/zenc/blob/main/plugins/brainfuck.zc) explains each command of a Brainfuck block this way.
