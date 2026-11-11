# zc-doc

`zc-doc` writes the documentation of a Zen C file as Markdown, on the standard output:

```bash
zc-doc geometry.zc > geometry.md
```

| Option | What it does |
| :--- | :--- |
| `--recursive-doc` | Documents the imported modules too, each one after a `# Module: <path>` heading. The default. |
| `--no-recursive-doc` | Documents only the file. |
| `-v`, `--verbose` | Prints each phase of the compilation. |
| `-h`, `--help` | Lists the options. |

## What it documents

Functions, structs and their fields, enums and their variants, constants, aliases, and the methods of each `impl`. Each one gets a heading, its comment, and its declaration as Zen C:

```zc
/// A point in the plane.
struct Point {
    /// Horizontal position.
    x: int,
    y: int,
}

// Adds two points.
fn add(a: Point, b: Point) -> Point {
    return Point { x: a.x + b.x, y: a.y + b.y };
}
```

gives

````markdown
## struct `Point`

A point in the plane.

```zc
struct Point {
    x: i32,
    y: i32,
}
```

### field `x`

Horizontal position.

## function `add`

Adds two points.

```zc
fn add(a: Point, b: Point) -> Point;
```
````

The comment of a declaration is every comment right before it, of any kind: `///`, `//`, `/* */` or `/** */`. `zc-doc` removes the comment marks and keeps the text as it is, so Markdown in a comment stays Markdown.

`zc-doc` does not check types: a type error does not stop it, but a syntax error does.
