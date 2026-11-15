+++
title = "4. Functions & Lambdas"
weight = 4
+++

# 4. Functions & Lambdas {#4-functions-lambdas}


#### Functions
```zc
fn add(a: int, b: int) -> int {
    return a + b;
}

// Named arguments supported in calls
add(a: 10, b: 20);
```

{% alert(type="note") %}
Named arguments must strictly follow the defined parameter order. `add(b: 20, a: 10)` is invalid.
{% end %}

#### Const Arguments
Function arguments can be marked as `const` to enforce read-only semantics. This is a type qualifier, not a manifest constant.

```zc
fn print_val(v: const int) {
    // v = 10; // Error: Cannot assign to const variable
    println(f"{v}");
}
```

#### Default Arguments
Functions can define default values for trailing arguments. These can be literals, expressions, or valid Zen C code (like struct constructors).
```zc
// Simple default value
import "std/io.zc"
fn increment(val: int, amount: int = 1) -> int {
    return val + amount;
}

// Expression default value (evaluated at call site)
fn offset(val: int, pad: int = 10 * 2) -> int {
    return val + pad;
}

// Struct default value
struct Config { debug: bool; }
fn init(cfg: Config = Config { debug: true }) {
    if cfg.debug { println("Debug Mode"); }
}

fn main() {
    increment(10);      // 11
    offset(5);          // 25
    init();             // Prints "Debug Mode"
}
```

#### Lambdas (Closures)
Anonymous functions that can capture their environment. In the block syntax the return type (`-> T`) can be left out: it is then the type of the `return` values when they all have the same one, and `void` otherwise. The arrow syntax always infers it.
```zc
let factor = 2;
let doubler = x => x * factor;  // Arrow syntax
let full = fn(x: int) -> int { return x * factor; }; // Block syntax
let inferred = fn(x: int) { return x * factor; };    // Block syntax, return type inferred

// Capture by Reference (Block Syntax)
let val = 10;
let modify = fn[&]() { val += 1; }; 
modify(); // val is now 11

// Capture by Reference (Arrow Syntax)
let modify_arrow = [&] x => val += x;
modify_arrow(5); // val is now 16

// Capture by Reference (Arrow Syntax with Multiple Arguments)
let sum_into = [&] (a, b) => val += (a + b);
sum_into(2, 2); // val is now 20

// Capture by Value (Default)
let original = 100;
let implicit = x => original + x;       // Implicit capture by value (no brackets)
let explicit = [=] x => original + x;   // Explicit capture by value

// A value capture is the closure's own copy: the body may change it, the closure
// keeps it between calls, and the original does not change.
let count = 0;
let next = fn() -> int { count += 1; return count; };
next(); next();                         // next() returns 1, then 2; count is still 0

```

#### Raw Function Pointers
Zen C supports raw C function pointers using the `fn*` syntax. This allows seamless interop with C libraries that expect function pointers without closure overhead.
```zc
// Function taking a raw function pointer
fn set_callback(cb: fn*(int)) {
    cb(42);
}

// Function returning a raw function pointer
fn get_callback() -> fn*(int) {
    return my_handler;
}

// Pointers to function pointers are supported (fn**)
let pptr: fn**(int) = &ptr;
```

#### Variadic Functions
Functions can accept a variable number of arguments using `...` and the `va_list` type.
```zc
fn log(lvl: int, fmt: char*, ...) {
    let ap: va_list;
    va_start(ap, fmt);
    vprintf(fmt, ap); // Use C stdio
    va_end(ap);
}
```
