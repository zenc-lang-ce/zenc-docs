# Install

Zen C comes as the compiler, `zc`, and its standalone tools (see [Tools](https://zenc-lang-ce.github.io/docs/tools/)):
- `zc-lsp`, the language server
- `zc-repl`, which runs Zen C a line at a time
- `zc-doc`, which writes the documentation of a file
- `zc-format`, which indents a file

`zc lsp`, `zc repl`, `zc doc` and `zc format` launch them, so keep them next to `zc`.

## Requirements

Zen C translates your program to C and calls a C compiler to build it, so it needs one on the system, whichever way you install it:

- **Linux:** GCC or Clang (`sudo apt install build-essential` on Debian and Ubuntu).
- **macOS:** Clang, from the Xcode command line tools (`xcode-select --install`).
- **Windows:** GCC from MinGW-w64, for example from [MSYS2](https://www.msys2.org/) (`pacman -S mingw-w64-ucrt-x86_64-gcc`) or [WinLibs](https://winlibs.com/), with its `bin` directory in your `PATH`.

`--cc` chooses another one: `zc run app.zc --cc clang`.

If you have no C compiler, or would rather not install one, download [`zc-boot.com`](#portable-executables-ape) from the [releases](https://github.com/zenc-lang-ce/zenc/releases) and run it in an empty directory. It downloads the [Cosmopolitan](https://github.com/jart/cosmopolitan) C compiler (`cosmocc`), which runs on Linux, macOS, Windows and the BSDs, together with `zc.com`, and leaves a `Makefile` and a `hello.zc` ready to build with them: `usr/bin/make`, then `out/hello.com`. The programs it builds are portable executables too.

## Download

The [releases page](https://github.com/zenc-lang-ce/zenc/releases) has every version of Zen C. Download the zip for your system, or the portable executables (APE), which run unchanged on Linux, macOS, Windows, FreeBSD, OpenBSD and NetBSD, on x86_64 and arm64.

### Native binaries

Each archive holds the native programs of one system: `zenc-<version>-linux-<arch>.tar.gz` for Linux (`x86_64`, `arm64`), and `zenc-<version>-macos-<arch>.zip` or `zenc-<version>-windows-x86_64.zip` for macOS (`x86_64`, `arm64`) and Windows. Each one has `zc`, the four tools, the standard library (`std.zc` and `std/`) and the license, in one directory.

Unpack it anywhere and add that directory to your `PATH`. `zc` finds the standard library next to itself, so keep the files together:

```bash
tar -xzf zenc-0.5.1-linux-x86_64.tar.gz
export PATH="$PWD/zenc-0.5.1-linux-x86_64:$PATH"
zc --version
```

On macOS, `unzip zenc-0.5.1-macos-arm64.zip` instead; on Windows, extract the zip and add its directory to the `Path` environment variable.

There is nothing else to set up. If you run `zc` through a symbolic link in another directory instead (`ln -s …/zc ~/bin/zc`), set `ZC_ROOT` to the unpacked directory: on macOS, `zc` does not follow the link to find its standard library.

> [!WARNING]
> `ZC_ROOT` wins over the standard library next to `zc`, and over the one inside `zc.com`. If you set it for an earlier version, update it or unset it when you install a new one.

The macOS binaries are not signed. If macOS refuses to open them, remove the quarantine flag of the directory:

```bash
xattr -dr com.apple.quarantine zenc-0.5.1-macos-arm64
```

The native binaries are built without the REPL JIT. To get it, build from source with libtcc.

### Portable executables (APE)

`zc.com`, `zc-lsp.com`, `zc-repl.com`, `zc-format.com` and `zc-doc.com` are [Actually Portable Executables](https://github.com/jart/cosmopolitan): the same file runs on all those systems and has the standard library inside. The release has `zc.com` on its own, for the compiler alone, and `zenc-<version>-ape.zip` with `zc.com` and the four tools:

```bash
unzip zenc-0.5.1-ape.zip -d zenc-ape
cd zenc-ape
./zc.com run hello.zc
```

If you download `zc.com` on its own on Linux or macOS, make it executable first: `chmod +x zc.com`.

> [!WARNING]
> On Windows, rename them to `zc.exe`, `zc-lsp.exe`, `zc-repl.exe`, `zc-format.exe` and `zc-doc.exe` before running them.

Keep the tools in the same directory as `zc.com` (`zc.exe` on Windows). In an editor, point the language server setting to `zc-lsp.com` (`zc-lsp.exe` on Windows).

`zc-boot.com` sets up a directory for a machine with no C compiler: run it in an empty directory and it downloads the [Cosmopolitan](https://github.com/jart/cosmopolitan) C compiler and `zc.com` into `./usr`, plus a `Makefile` and a `hello.zc` to start from.

The portable executables are built without the REPL JIT too.

## Build from source

The build produces `zc` and the four tools. Every platform needs:

- a C compiler: GCC or Clang (see [Requirements](#requirements));
- `git`, to get the source;
- optionally **libtcc**: with it the REPL runs code in process (JIT). Without it, the build leaves the JIT out.

Get the source:

```bash
git clone https://github.com/zenc-lang-ce/zenc.git
cd zenc
```

### Linux

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

### macOS

Install the Xcode command line tools, which provide Clang, `make` and `git`:

```bash
xcode-select --install
```

Then build and install as on Linux:

```bash
make
sudo make install
```

### Windows

Zen C builds natively on Windows (x86_64) with GCC from MinGW-w64 (see [Requirements](#requirements)). From the repository directory, run:

```cmd
build.bat
```

It builds `zc.exe`, `zc-lsp.exe`, `zc-format.exe`, `zc-repl.exe` and `zc-doc.exe`, and then the plugins (`set NO_PLUGINS=1` skips them). `zc.exe` finds the standard library by walking up from its own directory, so keep the executables in the repository directory and add it to your `PATH`, or set `ZC_ROOT` to the repository directory.

In a Unix-like environment (MSYS2, Cygwin, Git Bash) you can use `make` instead.

### Installing somewhere else

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

### Other ways to build

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
