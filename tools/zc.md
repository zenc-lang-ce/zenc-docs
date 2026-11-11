# zc

`zc` is the compiler. It translates a Zen C program to C and calls a C compiler to build it (see [Requirements](https://zenc-lang-ce.github.io/docs/install/#requirements)).

```bash
zc <command> [options] <file> [<files>...] [<args>...]
```

The command goes first, then the options, in any order with the files. `zc --help` lists the most used options, and `zc help <command>` explains one command.

## Commands

| Command | What it does |
| :--- | :--- |
| `zc build app.zc` | Builds the executable `app` (`app.exe` on Windows). `zc app.zc` does the same. |
| `zc run app.zc [args]` | Builds the program, runs it with `args` and deletes the executable. `zc` exits with the program's exit code. |
| `zc check app.zc` | Checks the program, types included, without writing C or building it. |
| `zc transpile app.zc` | Writes the C of the program to `app.c`, without building it. |
| `zc --version` | Prints the version. |
| `zc --paths` | Prints the directories where `zc` looks for imports. |

`zc run` passes the program every argument after the file that `zc` does not take as its own. After `--`, every argument goes to the program, even one that looks like an option of `zc`:

```bash
zc run app.zc input.txt         # the program gets input.txt
zc run app.zc -- -v --help      # the program gets -v and --help
```

More files after the first one are part of the program: `.zc` files are compiled with it, and C files, objects and libraries (`.c`, `.cpp`, `.m`, `.mm`, `.o`, `.a`, `.so`, `.dylib`) go to the C compiler:

```bash
zc build main.zc parser.zc vendor/sqlite3.c -o app
```

## Output

| Option | What it does |
| :--- | :--- |
| `-o <file>` | The name of the executable or, with `zc transpile`, of the C file. |
| `--emit-c` | Keeps the C file next to the executable. Without it, `zc build` and `zc run` delete it. |
| `-q`, `--quiet` | Prints only errors, and passes `-w` to the C compiler. |
| `-v`, `--verbose` | Prints each phase of the compilation. |
| `--json` | Prints diagnostics as JSON, one object per line: `{"file":"app.zc","line":3,"col":18,"level":"error","message":"..."}`. |

## The C compiler

`zc` uses `gcc` unless told otherwise. Every option it does not know goes to the C compiler, so `-Wall`, `-march=native` or `-fsanitize=address` reach it as they are.

| Option | What it does |
| :--- | :--- |
| `--cc <compiler>` | The C compiler: `clang`, `tcc`, `zig` (runs `zig cc`), a path... |
| `-O<level>`, `-O <level>` | The optimization level of the C compiler. |
| `--release` | `-O3`, and no `#line` directives in the C. |
| `-I <dir>` | Looks for imports and C headers in `dir`. |
| `-L <dir>`, `-l <library>` | Library search path and library to link. |
| `-D <name>[=<value>]` | Defines a macro for the C compiler, and the name for [`@cfg`](https://zenc-lang-ce.github.io/docs/tour/12-advanced/). |
| `-shared` | Builds a shared library (adds `-fPIC`). |
| `-S`, `-E` | Assembly or preprocessed C, as the C compiler writes them. |
| `--no-suppress-warnings` | Shows the C compiler's warnings about the generated C, which `zc` turns off by default. |
| `--filcc` | Builds with Fil-C: a copy next to the standard library, or `filcc` in the `PATH`. |

A program can also set these in its source, with build directives: `//> link: -lm`, `//> include: ./include`, `//> pkg-config: gtk+-3.0`... See [Build Directives](https://zenc-lang-ce.github.io/docs/tour/12-advanced/).

### Debugging

The generated C carries `#line` directives, so a debugger shows your `.zc` files. To build with debug information, give the C compiler `-g3` and turn optimizations off:

```bash
zc build app.zc -o app -g3 -O0
```

[Editors](https://zenc-lang-ce.github.io/docs/editors/#debugging) explains how to debug from VS Code.

## Diagnostics

| Option | What it does |
| :--- | :--- |
| `-W<category>`, `-Wno-<category>` | Turns a category of warnings on or off: `unused`, `safety`, `logic`, `conversion`, `style` (on by default), `interop`, `pedantic`, or `all`. `-W` options with other names go to the C compiler. |
| `--warn-errors`, `-Werror` | Warnings are errors. |

[Diagnostics](https://zenc-lang-ce.github.io/docs/tour/16-diagnostics/) describes the categories.

## Targets

| Option | What it does |
| :--- | :--- |
| `--cpp` | Writes C++ and builds it with `g++`. |
| `--cuda` | Writes CUDA and builds it with `nvcc`. |
| `--objc` | Writes Objective-C (`clang` on macOS, `gcc` elsewhere). |
| `--freestanding` | For code that runs without an operating system: passes `-ffreestanding` to the C compiler, does not link `libm`, and defines `freestanding` for `@cfg`. |
| `--misra` | Writes C that follows MISRA C:2012, and checks the program against its rules. See [MISRA Rules](https://zenc-lang-ce.github.io/docs/tour/17-misra-rules/). |
| `--profile <name>` | `c11` (the default), `misra-c2012` (the same as `--misra`), or `hosted`: C shaped like MISRA's, from a program that may use the host's libraries. |

[Interop](https://zenc-lang-ce.github.io/docs/tour/14-interop/) explains how to call C++, CUDA and Objective-C code.

### Other backends

`--backend <name>` writes the program in another form. `c`, `cpp`, `cuda` and `objc` build it as above; the others only write a file, with `zc transpile`:

| Backend | Writes |
| :--- | :--- |
| `json` | The syntax tree as JSON (`--json-pretty` indents it). |
| `ast-dump` | The syntax tree as text. |
| `dot` | The syntax tree as a Graphviz graph. |
| `lisp` | The program in Lisp. |

```bash
zc transpile app.zc --backend json --json-pretty    # writes app.json
```

`--backend-opt <option>` passes an option to the backend. `json` and `ast-dump` take `full-content` (also `--backend-full-content`), which includes the text of `raw` blocks.

## Configuration file

`zc` reads `zenc.json` in `ZC_ROOT` or, without it, in the `share/zenc` of the installation, and then `.zenc.json` and `zenc.json` in the current directory. They list the C functions and types that the `interop` warnings should accept without a declaration:

```json
{
  "c_functions": ["SDL_Init", "SDL_Quit"],
  "c_types": ["SDL_Window"]
}
```

## Environment

| Variable | What it does |
| :--- | :--- |
| `ZC_ROOT` | Where the standard library is, instead of looking for it next to `zc`. |
