+++
title = "3. Tipos Agregados"
weight = 3
+++

# 3. Tipos Agregados {#3-tipos-agregados}


#### Arrays
Arrays de tamanho fixo com semântica de valores.
```zc
def SIZE = 5;
let ints: int[SIZE] = [1, 2, 3, 4, 5];
let zeros: [int; SIZE]; // Inicialização-Zero
```
```c
#define SIZE 5
int ints[SIZE] = {1, 2, 3, 4, 5};
int zeros[SIZE] = {0};
```

#### Tuplas
Agrupa múltiplos valores juntos, acessa elementos por índice.
```zc
let pair = (1, "Hello");
let x = pair.0;  // 1
let s = pair.1;  // "Hello"
```
```c
typedef struct { int v0; const char *v1; } Tuple_int_string;

Tuple_int_string pair = {1, "Hello"};
int x = pair.v0;          // 1
const char *s = pair.v1;  // "Hello"
```

**Retorno Múltiplo de Valores**

Funções podem retornar tuplas para fornecer múltiplos resultados:
```zc
fn add_and_subtract(a: int, b: int) -> (int, int) {
    return (a + b, a - b);
}

let result = add_and_subtract(3, 2);
let sum = result.0;   // 5
let diff = result.1;  // 1
```
```c
typedef struct { int v0; int v1; } Tuple_int_int;

Tuple_int_int add_and_subtract(int a, int b) {
    return (Tuple_int_int){a + b, a - b};
}

Tuple_int_int result = add_and_subtract(3, 2);
int sum  = result.v0;  // 5
int diff = result.v1;  // 1
```

**Desestruturação**

Tuplas podem ser desestruturadas diretamente em variáveis:
```zc
let (sum, diff) = add_and_subtract(3, 2);
// sum = 5, diff = 1
```
```c
Tuple_int_int tmp = add_and_subtract(3, 2);
int sum = tmp.v0;
int diff = tmp.v1;
// sum = 5, diff = 1
```

Desestruturação tipada permite anotações de tipo explícitas:
```zc
let (a: string, b: u8) = ("hello", 42);
let (x, y: i32) = (1, 2);  // Misto: x inferido, y explícito
```
```c
const char *a = "hello";
uint8_t b = 42;
int x = 1;
int32_t y = 2;
```

#### Structs

Estruturas de dados com campos de bit opcionais.
```zc
struct Point {
    x: int;
    y: int;
}

// Inicialização de Struct
let p = Point { x: 10, y: 20 };

// Bitfields
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

// Inicialização de Struct
Point p = { .x = 10, .y = 20 };

// Bitfields
typedef struct {
    uint8_t valid : 1;
    uint8_t mode : 3;
} Flags;
```

{% alert(type="note") %}
Structs usam [Semântica de Move](@/docs/tour/08-memory-management.pt.md#semantica-de-recursos-move-by-default) por padrão. Campos podem ser acessados via `.` mesmo em ponteiros (Auto-Dereferência).
{% end %}

#### Structs Opacos

Você pode definir um struct como `opaque` para restringir acesso aos seus campos exclusivamente ao módulo que o define, enquanto ainda permite que o struct seja alocado na pilha com tamanho conhecido.
```zc
// Em user.zc
opaque struct User {
    id: int;
    name: string;
}

fn new_user(name: string) -> User {
    return User{id: 1, name: name}; // OK: Dentro do módulo
}

// Em main.zc
import "user.zc";

fn main() {
    let u = new_user("Alice");
    // let id = u.id; // Erro: Acesso ao campo privado 'id' não permitido
}
```
```c
// Em user.h
typedef struct {
    int id;
    const char *name;
} User;

User new_user(const char *name);

// Em user.c
User new_user(const char *name) {
    return (User){ .id = 1, .name = name };
}

// Em main.c
#include "user.h"

int main(void) {
    User u = new_user("Alice");
    // -- Erro de compilação do Zen C! --
    // int id = u.id; // O Zen C se recusaria a transpilar isto e daria um erro.
}
```

#### Enums

Unions etiquetadas (tipos Sum) capazes de armazenar dados.
```zc
enum Shape {
    Circle(float),      // Armazena o raio
    Rect(float, float), // Armazena largura e altura
    Point               // Sem dados
}
```
```c
typedef enum { Shape_Circle_Tag, Shape_Rect_Tag, Shape_Point_Tag } Shape_Tag;

typedef struct { float v0; float v1; } Tuple_float_float;

typedef struct {
    Shape_Tag tag;
    union {
        float Circle;
        Tuple_float_float Rect;
    } data;
} Shape;

Shape Shape_Circle(float v) {
    return (Shape){ .tag = Shape_Circle_Tag, .data.Circle = v };
}

Shape Shape_Rect(float v0, float v1) {
    return (Shape){ .tag = Shape_Rect_Tag, .data.Rect = { v0, v1 } };
}

Shape Shape_Point(void) {
    return (Shape){ .tag = Shape_Point_Tag };
}
```

#### Unions

Unions C padrão (acesso inseguro).
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

#### Vetores SIMD
Tipos de vetores SIMD nativos usando extensões de vetores do GCC/Clang. Anote um struct com `@vector(N)` para definir um vetor de N elementos.
```zc
import "std/simd.zc";

fn main() {
    let a = f32x4{v: 1.0};              // Broadcast: {1.0, 1.0, 1.0, 1.0}
    let b = f32x4{1.0, 2.0, 3.0, 4.0};  // Inicialização por elemento
    let c = a + b;                       // Adição por elemento
    let x = c[0];                        // Acesso ao elemento (float)
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
Operadores aritméticos (`+`, `-`, `*`, `/`) e bitwise (`&`, `|`, `^`) funcionam por elemento. Veja [`std/simd.zc`](../std/simd.zc) para os tipos predefinidos.

#### Aliases de Tipos
Cria um novo nome para um tipo existente.
```zc
alias ID = int;
alias PointMap = Map<string, Point>
alias OpFunc = fn(int, int) -> int
```
```c
typedef int ID;
typedef struct Map_string_Point PointMap;
typedef struct { void *func; void *ctx; void (*drop)(void *); } z_closure_T;
typedef z_closure_T OpFunc;
```
> **Nota:** O ponto e vírgula final é opcional para aliases de tipo.

#### Aliases Opacos de Tipos

Você pode definir um alias como `opaque` para criar um novo tipo que é distinto de seu tipo subjacente fora do módulo que o define. Isso fornece forte encapsulamento e segurança de tipos sem o overhead de runtime de um struct wrapper.

```zc
// Em library.zc
opaque alias Handle = int;

fn make_handle(v: int) -> Handle {
    return v; // Conversão implícita permitida dentro do módulo
}

// Em main.zc
import "library.zc";

fn main() {
    let h: Handle = make_handle(42);
    // let i: int = h; // Erro: validação de tipo falhou
    // let h2: Handle = 10; // Erro: validação de tipo falhou
}
```
```c
// Em library.h
typedef int Handle;

Handle make_handle(int v);

// Em library.c
Handle make_handle(int v) {
    return v;
}

// Em main.c
#include "library.h"

int main(void) {
    Handle h = make_handle(42);
    // -- Erro de compilação do Zen C! --
    // int i = h;       // O Zen C se recusaria a transpilar isto e daria um erro.
    // Handle h2 = 10;  // O Zen C se recusaria a transpilar isto e daria um erro.
}
```
