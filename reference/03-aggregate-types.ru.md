+++
title = "3. Составные типы"
weight = 3
+++

# 3. Составные типы {#3-sostavnye-tipy}


#### Массивы
Массивы фиксированного размера с семантикой значения.
```zc
def SIZE = 5;
let ints: int[SIZE] = [1, 2, 3, 4, 5];
let zeros: [int; SIZE]; // Инициализировано нулями
```
```c
#define SIZE 5
int ints[SIZE] = {1, 2, 3, 4, 5};
int zeros[SIZE] = {0};
```

#### Кортежи
Группируйте несколько значений вместе, получайте доступ к элементам по индексу.
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

**Множественные возвращаемые значения**

Функции могут возвращать кортежи для предоставления нескольких результатов:
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

**Деструктуризация**

Кортежи могут быть деструктурированы прямо в переменные:
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

Типизированная деструктуризация позволяет указывать явные аннотации типов:
```zc
let (a: string, b: u8) = ("hello", 42);
let (x, y: i32) = (1, 2);  // Смешанный: x выводится, y явный
```
```c
const char *a = "hello";
uint8_t b = 42;
int x = 1;
int32_t y = 2;
```

#### Структуры
Структуры данных с опциональными битовыми полями.
```zc
struct Point {
    x: int;
    y: int;
}

// Инициализация структуры
let p = Point { x: 10, y: 20 };

// Битфилды
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

// Инициализация структуры
Point p = { .x = 10, .y = 20 };

// Битфилды
typedef struct {
    uint8_t valid : 1;
    uint8_t mode : 3;
} Flags;
```

{% alert(type="note") %}
Структуры используют [Move Semantics](@/docs/tour/08-memory-management.ru.md#semantika-resursov-move-po-umolchaniiu) по умолчанию. Доступ к полям можно получить через `.` даже на указателях (Auto-Dereference).
{% end %}

#### Непрозрачные структуры
Вы можете определить структуру как `opaque`, чтобы ограничить доступ к её полям только определяющим модулем, при этом позволяя структуре размещаться на стеке (размер известен).

```zc
// В user.zc
opaque struct User {
    id: int;
    name: string;
}

fn new_user(name: string) -> User {
    return User{id: 1, name: name}; // ОК: внутри модуля
}

// В main.zc
import "user.zc";

fn main() {
    let u = new_user("Alice");
    // let id = u.id; // Ошибка: нет доступа к приватному полю 'id'
}
```
```c
// В user.h
typedef struct {
    int id;
    const char *name;
} User;

User new_user(const char *name);

// В user.c
User new_user(const char *name) {
    return (User){ .id = 1, .name = name };
}

// В main.c
#include "user.h"

int main(void) {
    User u = new_user("Alice");
    int id = u.id; // Компилируется: в C нет приватных полей
}
```

#### Перечисления
Теговые объединения (Sum types), способные содержать данные.
```zc
enum Shape {
    Circle(float),      // Держит радиус
    Rect(float, float), // Держит ширину, высоту
    Point               // Нет данных
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

#### Объединения
Стандартные C объединения (небезопасно).
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

#### SIMD-векторы
Нативные SIMD-векторные типы с использованием расширений GCC/Clang. Аннотируйте структуру с помощью `@vector(N)` для определения вектора из N элементов.
```zc
import "std/simd.zc";

fn main() {
    let a = f32x4{v: 1.0};              // Широковещание: {1.0, 1.0, 1.0, 1.0}
    let b = f32x4{1.0, 2.0, 3.0, 4.0};  // Поэлементная инициализация
    let c = a + b;                       // Поэлементное сложение
    let x = c[0];                        // Доступ к элементу (float)
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
Арифметические (`+`, `-`, `*`, `/`) и побитовые (`&`, `|`, `^`) операторы работают поэлементно. См. [`std/simd.zc`](../std/simd.zc) для предопределённых типов.

#### Псевдонимы типов
Создайте новое имя для существующего типа.
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
> **Примечание:** Завершающая точка с запятой необязательна для псевдонимов типов.

#### Непрозрачные псевдонимы типов
Вы можете определить псевдоним типа как `opaque`, чтобы создать новый тип, который отличается от своего базового типа вне определяющего модуля. Это обеспечивает сильную инкапсуляцию и безопасность типов без накладных расходов времени выполнения структуры-оболочки.

```zc
// В library.zc
opaque alias Handle = int;

fn make_handle(v: int) -> Handle {
    return v; // Неявное преобразование разрешено внутри модуля
}

// В main.zc
import "library.zc";

fn main() {
    let h: Handle = make_handle(42);
    // let i: int = h; // Ошибка: проверка типа не прошла
    // let h2: Handle = 10; // Ошибка: проверка типа не прошла
}
```
```c
// В library.h
typedef struct { int value; } Handle;

Handle make_handle(int v);

// В library.c
Handle make_handle(int v) {
    return (Handle){ v };
}

// В main.c
#include "library.h"

int main(void) {
    Handle h = make_handle(42);
    // int i = h;       // Ошибка: несовместимые типы
    // Handle h2 = 10;  // Ошибка: несовместимые типы
}
```
