+++
title = "3. Tipos Agregados"
weight = 3
+++

# 3. Tipos Agregados {#3-tipos-agregados}


#### Arrays
Arrays de tamaño fijo con semántica de valor.
```zc
def SIZE = 5;
let ints: int[SIZE] = [1, 2, 3, 4, 5];
let zeros: [int; SIZE]; // Inicializado a cero
```
```c
#define SIZE 5
int ints[SIZE] = {1, 2, 3, 4, 5};
int zeros[SIZE] = {0};
```

#### Tuplas
Agrupa múltiples valores, accede a los elementos por índice.
```zc
let pair = (1, "Hola");
let x = pair.0;  // 1
let s = pair.1;  // "Hola"
```
```c
typedef struct { int v0; const char *v1; } Tuple_int_string;

Tuple_int_string pair = {1, "Hola"};
int x = pair.v0;          // 1
const char *s = pair.v1;  // "Hola"
```

**Múltiples Valores de Retorno**

Las funciones pueden retornar tuplas para proporcionar múltiples resultados:
```zc
fn sumar_y_restar(a: int, b: int) -> (int, int) {
    return (a + b, a - b);
}

let resultado = sumar_y_restar(3, 2);
let suma = resultado.0;   // 5
let resta = resultado.1;  // 1
```
```c
typedef struct { int v0; int v1; } Tuple_int_int;

Tuple_int_int sumar_y_restar(int a, int b) {
    return (Tuple_int_int){a + b, a - b};
}

Tuple_int_int resultado = sumar_y_restar(3, 2);
int suma  = resultado.v0;  // 5
int resta = resultado.v1;  // 1
```

**Desestructuración**

Las tuplas pueden desestructurarse directamente en variables:
```zc
let (suma, resta) = sumar_y_restar(3, 2);
// suma = 5, resta = 1
```
```c
Tuple_int_int tmp = sumar_y_restar(3, 2);
int suma = tmp.v0;
int resta = tmp.v1;
// suma = 5, resta = 1
```

La desestructuración tipada permite anotaciones de tipo explícitas:
```zc
let (a: string, b: u8) = ("hello", 42);
let (x, y: i32) = (1, 2);  // Mixto: x inferido, y explícito
```
```c
const char *a = "hello";
uint8_t b = 42;
int x = 1;
int32_t y = 2;
```

#### Structs
Estructuras de datos con campos de bits opcionales.
```zc
struct Point {
    x: int;
    y: int;
}

// Inicialización de struct
let p = Point { x: 10, y: 20 };

// Campos de bits
struct Flags {
    valid: U8 : 1;
    mode:  U8 : 3;
}
```
```c
typedef struct {
    int x;
    int y;
} Point;

// Inicialización de struct
Point p = { .x = 10, .y = 20 };

// Campos de bits
typedef struct {
    uint8_t valid : 1;
    uint8_t mode : 3;
} Flags;
```

{% alert(type="note") %}
Los structs usan [Semántica de Movimiento](@/docs/tour/08-memory-management.es.md#semantica-de-recursos-movimiento-por-defecto) por defecto. Los campos se pueden acceder mediante `.` incluso en punteros (Auto-Dereferencia).
{% end %}

#### Structs Opacos
Puedes definir un struct como `opaque` para restringir el acceso a sus campos solo al módulo que lo define, permitiendo aún que el struct sea asignado en el stack (el tamaño es conocido).

```zc
// En user.zc
opaque struct User {
    id: int;
    name: string;
}

fn new_user(name: string) -> User {
    return User{id: 1, name: name}; // OK: Dentro del módulo
}

// En main.zc
import "user.zc";

fn main() {
    let u = new_user("Alice");
    // let id = u.id; // Error: No se puede acceder al campo privado 'id'
}
```
```c
// En user.h
typedef struct {
    int id;
    const char *name;
} User;

User new_user(const char *name);

// En user.c
User new_user(const char *name) {
    return (User){ .id = 1, .name = name };
}

// En main.c
#include "user.h"

int main(void) {
    User u = new_user("Alice");
    int id = u.id; // Compila: C no tiene campos privados
}
```

#### Enums
Uniones etiquetadas (Tipos suma) capaces de contener datos.
```zc
enum Shape {
    Circle(float),      // Contiene el radio
    Rect(float, float), // Contiene ancho y alto
    Point               // Sin datos
}
```
```c
typedef enum { Shape_Circle, Shape_Rect, Shape_Point } Shape_Tag;

typedef struct {
    Shape_Tag tag;
    union {
        struct { float radius; } Circle;
        struct { float width, height; } Rect;
    } data;
} Shape;
```

#### Uniones
Uniones estándar de C (acceso inseguro).
```zc
union Data {
    i: int;
    f: float;
}
```
```c
typedef union {
    int i;
    float f;
} Data;
```

#### Vectores SIMD
Tipos de vectores SIMD nativos utilizando extensiones de vectores de GCC/Clang. Anota un struct con `@vector(N)` para definir un vector de N elementos.
```zc
import "std/simd.zc";

fn main() {
    let a = f32x4{v: 1.0};              // Difusión: {1.0, 1.0, 1.0, 1.0}
    let b = f32x4{1.0, 2.0, 3.0, 4.0};  // Inicialización por elemento
    let c = a + b;                       // Suma por elementos
    let x = c[0];                        // Acceso a elementos (float)
}
```
```c
typedef float f32x4 __attribute__((vector_size(16)));

int main(void) {
    f32x4 a = {1.0f, 1.0f, 1.0f, 1.0f};
    f32x4 b = {1.0f, 2.0f, 3.0f, 4.0f};
    f32x4 c = a + b;
    float x = c[0];
}
```
Los operadores aritméticos (`+`, `-`, `*`, `/`) y bit a bit (`&`, `|`, `^`) funcionan por elementos. Consulta [`std/simd.zc`](../std/simd.zc) para los tipos predefinidos.

#### Alias de Tipos
Crea un nuevo nombre para un tipo existente.
```zc
alias ID = int;
alias PointMap = Map<string, Point>
alias OpFunc = fn(int, int) -> int
```
```c
typedef int ID;
typedef struct Map_string_Point PointMap;
typedef int (*OpFunc)(int, int);
```
> **Nota:** El punto y coma final es opcional para los alias de tipo.

#### Alias de Tipos Opacos
Puedes definir un alias de tipo como `opaque` para crear un nuevo tipo que sea distinto de su tipo subyacente fuera del módulo que lo define. Esto proporciona una fuerte encapsulación y seguridad de tipos sin la sobrecarga en tiempo de ejecución de un struct envoltorio.

```zc
// En library.zc
opaque alias Handle = int;

fn make_handle(v: int) -> Handle {
    return v; // Conversión implícita permitida dentro del módulo
}

// En main.zc
import "library.zc";

fn main() {
    let h: Handle = make_handle(42);
    // let i: int = h; // Error: Falló la validación de tipos
    // let h2: Handle = 10; // Error: Falló la validación de tipos
}
```
```c
// En library.h
typedef struct { int value; } Handle;

Handle make_handle(int v);

// En library.c
Handle make_handle(int v) {
    return (Handle){ v };
}

// En main.c
#include "library.h"

int main(void) {
    Handle h = make_handle(42);
    // int i = h;       // Error: tipos incompatibles
    // Handle h2 = 10;  // Error: tipos incompatibles
}
```
