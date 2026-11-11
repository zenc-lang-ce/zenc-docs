# zc-format

`zc-format` indents Zen C source. It reads a file, or the standard input without one, and prints the result:

```bash
zc-format app.zc                  # prints app.zc indented
zc-format < app.zc                # the same, from the standard input
zc-format app.zc > tmp && mv tmp app.zc
```

It does not change the file: redirect its output to write it back.

## What it changes

Only the indentation at the start of each line: four spaces for each `{` that is still open, one level less on a line that starts with `}`. It leaves the rest of each line as it is, and does not touch the inside of strings, characters or `/* */` comments. Lines with only spaces become empty.

```zc
fn main() {
  let p = Point { x: 1,
                  y: 2 };
}
```

becomes

```zc
fn main() {
    let p = Point { x: 1,
        y: 2 };
}
```

`(` and `[` do not indent: a call split over several lines gets the indentation of its block.

## In CI

`--check` prints nothing, and exits with 1 when the file would change:

```bash
for f in $(git ls-files '*.zc'); do
    zc-format --check "$f" || echo "not formatted: $f"
done
```

## In an editor

The language server formats with the same rules (**Format Document** in VS Code): see [zc-lsp](https://zenc-lang-ce.github.io/docs/tools/zc-lsp/).
