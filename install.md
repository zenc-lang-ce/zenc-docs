# Install

Zen C is built from source. The build produces the compiler, `zc`, and its standalone tools: `zc-lsp` (language server), `zc-repl`, `zc-doc` and `zc-format`. `zc lsp`, `zc repl`, `zc doc` and `zc format` launch them, so keep them next to `zc`.

Every platform needs:

- a C compiler: GCC or Clang (Zen C programs are compiled with it too);
- `git`, to get the source;
- optionally **libtcc**: with it the REPL runs code in process (JIT). Without it, the build leaves the JIT out.

Get the source:

```bash
git clone https://github.com/zenc-lang-ce/zenc.git
cd zenc
```

## Linux

Install a compiler and `make`:

```bash
sudo apt install build-essential git      # Debian, Ubuntu
sudo dnf install gcc make git             # Fedora
sudo pacman -S base-devel git             # Arch
```

For the REPL JIT, also install libtcc (`libtcc-dev` on Debian and Ubuntu).

Build and install:

```bash
make
sudo make install
```

`make install` puts `zc` and the tools in `/usr/local/bin` and the standard library in `/usr/local/share/zenc`.

## macOS

Install the Xcode command line tools, which provide Clang, `make` and `git`:

```bash
xcode-select --install
```

Then build and install as on Linux:

```bash
make
sudo make install
```

## Windows

Zen C builds natively on Windows (x86_64) with GCC from MinGW-w64, for example from [MSYS2](https://www.msys2.org/) (`pacman -S mingw-w64-ucrt-x86_64-gcc`) or [WinLibs](https://winlibs.com/). Put its `bin` directory in your `PATH`, then run from the repository directory:

```cmd
build.bat
```

It builds `zc.exe`, `zc-lsp.exe`, `zc-format.exe`, `zc-repl.exe` and `zc-doc.exe`, and then the plugins (`set NO_PLUGINS=1` skips them). `zc.exe` finds the standard library by walking up from its own directory, so keep the executables in the repository directory and add it to your `PATH`, or set `ZC_ROOT` to the repository directory.

In a Unix-like environment (MSYS2, Cygwin, Git Bash) you can use `make` instead.

## Installing somewhere else

`PREFIX` (default `/usr/local`) sets where `make install` copies the files. The compiler also records it to find its standard library, so give the same `PREFIX` to the build and to the install, and run `make clean` first when you change it:

```bash
make clean
make PREFIX="$HOME/.local"
make install PREFIX="$HOME/.local"
```

`make uninstall` (with the same `PREFIX`) removes what `make install` copied.

If `zc` cannot find the standard library (`import "std/io.zc"` fails), set `ZC_ROOT` to the directory that contains `std/`:

```bash
export ZC_ROOT=/path/to/zenc
```

## Other ways to build

**CMake:**

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
sudo cmake --install build
```

The options `ZC_USE_JIT`, `ZC_NO_LSP`, `ZC_NO_REPL`, `ZC_NO_PLUGINS` and `ZC_NO_BACKENDS` turn features on or off (`-DZC_NO_REPL=ON`).

**Nix:** the repository is a flake. `nix build` builds `zc` into `./result`, and `nix develop` opens a shell with it.

**Portable executable (APE):** with the [Cosmopolitan](https://github.com/jart/cosmopolitan) toolchain (`cosmocc` in your `PATH`), `make ape` builds `out/bin/zc.com`, one binary with the standard library inside that runs on Linux, macOS, Windows and the BSDs, on x86_64 and aarch64:

```bash
make ape
sudo env "PATH=$PATH" make install-ape
```

**Smaller builds:** `make ZC_LSP=0 ZC_REPL=0` leaves out the language server and the REPL.

> [!WARNING]
> Zig works well as the C compiler of your programs (`zc run app.zc --cc zig`), but a compiler built with `zig cc` can be unstable. Build `zc` itself with GCC or Clang.

## Check the installation

```bash
zc --version
```

Write `hello.zc`:

```zc
import "std/io.zc"

fn main() {
    println("Hello, Zen C!");
}
```

and run it:

```bash
zc run hello.zc
```

To run the compiler's test suite from the repository: `make test`.
