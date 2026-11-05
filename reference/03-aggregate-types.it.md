+++
title = "3. Tipi Aggregati"
weight = 3
+++

# 3. Tipi Aggregati {#3-tipi-aggregati}


#### Array
Array a lunghezza fissa con valori arbitrari.
```zc
def GRANDEZZA = 5;
let interi: int[GRANDEZZA] = [1, 2, 3, 4, 5];
let zeri: [int; GRANDEZZA]; // Inizializzato a zero
```
```c
#define GRANDEZZA 5
int interi[GRANDEZZA] = {1, 2, 3, 4, 5};
int zeri[GRANDEZZA] = {0};
```

#### Tuple
Valori molteplici raggruppati assieme, accesso agli elementi indicizzato.
```zc
let paio = (1, "Ciao!");
let x = paio.0;  // 1
let s = paio.1;  // "Ciao!"
```
```c
typedef struct { int v0; const char *v1; } Tuple_int_string;

Tuple_int_string paio = {1, "Ciao!"};
int x = paio.v0;          // 1
const char *s = paio.v1;  // "Ciao!"
```

**Molteplici Valori di Ritorno**

Le funzioni posso restituire delle tuple per fornire diversi risultati:
```zc
fn somma_e_differenza(a: int, b: int) -> (int, int) {
    return (a + b, a - b);
}

let risultato = somma_e_differenza(3, 2);
let somma = risultato.0;   // 5
let differenza = risultato.1;  // 1
```
```c
typedef struct { int v0; int v1; } Tuple_int_int;

Tuple_int_int somma_e_differenza(int a, int b) {
    return (Tuple_int_int){a + b, a - b};
}

Tuple_int_int risultato = somma_e_differenza(3, 2);
int somma      = risultato.v0;  // 5
int differenza = risultato.v1;  // 1
```

**Separazione**

Le tuple possono essere separate direttamente in variabili singole.
```zc
let (somma, differenza) = somma_e_differenza(3, 2);
// somma = 5, differenza = 1
```
```c
Tuple_int_int tmp = somma_e_differenza(3, 2);
int somma = tmp.v0;
int differenza = tmp.v1;
// somma = 5, differenza = 1
```

La separazione delle tuple tipizzata permette annotazioni di tipo esplicite:
```zc
let (a: string, b: u8) = ("hello", 42);
let (x, y: i32) = (1, 2);  // Misto: x inferito, y esplicito
```
```c
const char *a = "hello";
uint8_t b = 42;
int x = 1;
int32_t y = 2;
```

#### Structs
Strutture dati con campi di bit opzionali.
```zc
struct Punto {
    x: int;
    y: int;
}

// Inizializzazione struct
let p = Punto { x: 10, y: 20 };

// Campi di bit
struct Flags {
    valido: U8 : 1;
    modalità:  U8 : 3;
}
```
```c
typedef struct {
    int x;
    int y;
} Punto;

// Inizializzazione struct
Punto p = { .x = 10, .y = 20 };

// Campi di bit
typedef struct {
    uint8_t valido : 1;
    uint8_t modalità : 3;
} Flags;
```

{% alert(type="note") %}
Gli struct usano le [Semantiche di Spostamento](@/docs/tour/08-memory-management.it.md#semantiche-delle-risorse-muovi-di-default) di default. I campi di uno struct possono essere acceduti via `.` anche sui puntatori (Dereferenza-Automatica).
{% end %}

#### Struct Opachi
Puoi definire uno struct come `opaque` (lett. _opaco_) per restringere l'accesso ai suoi campi al modulo che lo ha definito, permettendo comunque l'allocazione sullo stack dello struct (la grandezza è data).

```zc
// In utente.zc
opaque struct Utente {
    id: int;
    nome: string;
}

fn nuovo_utente(nome: string) -> Utente {
    return Utente{id: 1, nome: nome}; // OK: Dentro il modulo
}

// In main.zc
import "utente.zc";

fn main() {
    let u = nuovo_utente("Alice");
    // let id = u.id; // Error: Impossibile accedere al campo privato 'id'
}
```
```c
// In utente.h
typedef struct {
    int id;
    const char *nome;
} Utente;

Utente nuovo_utente(const char *nome);

// In utente.c
Utente nuovo_utente(const char *nome) {
    return (Utente){ .id = 1, .nome = nome };
}

// In main.c
#include "utente.h"

int main(void) {
    Utente u = nuovo_utente("Alice");
    int id = u.id; // Compila: il C non ha campi privati
}
```

#### Enum
Unioni taggate (tipi somma) capaci di contenere dati.
```zc
enum Forma {
    Cerchio(float),           // Contiene il raggio
    Rettangolo(float, float), // Contiene la larghezza e l'altezza
    Punto                     // Non contiene dati
}
```
```c
typedef enum { Forma_Cerchio, Forma_Rettangolo, Forma_Punto } Forma_Tag;

typedef struct {
    Forma_Tag tag;
    union {
        struct { float raggio; } Cerchio;
        struct { float larghezza, altezza; } Rettangolo;
    } data;
} Forma;
```

#### Unioni
Unioni standard C (accesso non sicuro).
```zc
union Dati {
    i: int;
    f: float;
}
```
```c
typedef union {
    int i;
    float f;
} Dati;
```

#### Vettori SIMD
Tipi di vettore SIMD nativi utilizzando le estensioni vettoriali di GCC/Clang. Annota uno struct con `@vector(N)` per definire un vettore di N elementi.
```zc
import "std/simd.zc";

fn main() {
    let a = f32x4{v: 1.0};              // Broadcast: {1.0, 1.0, 1.0, 1.0}
    let b = f32x4{1.0, 2.0, 3.0, 4.0};  // Inizializzazione per elemento
    let c = a + b;                       // Addizione per elemento
    let x = c[0];                        // Accesso all'elemento (float)
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
Gli operatori aritmetici (`+`, `-`, `*`, `/`) e bitwise (`&`, `|`, `^`) funzionano per elemento. Vedi [`std/simd.zc`](../std/simd.zc) per i tipi predefiniti.

#### Alias del tipo
Crea un alias per un tipo già esistente.
```zc
alias ID = int;
alias PuntoDellaMappa = Mappa<string, Punto>
alias OpFunc = fn(int, int) -> int
```
```c
typedef int ID;
typedef struct Mappa_string_Punto PuntoDellaMappa;
typedef int (*OpFunc)(int, int);
```
> **Nota:** Il punto e virgola finale è opzionale per gli alias di tipo.

#### Alias del tipo opachi
Puoi definire un alias del tipo come `opaque` (lett. _opaco_) per creare un nuovo tipo che si distingue dal suo tipo sottostante al di fuori del modulo che l'ha definito. Questo permette una forte incapsulamento e sicurezza dei tipi senza overhead extra durante l'esecuzione di un wrapper struct.

```zc
// In libreria.zc
opaque alias Handle = int;

fn crea_handle(v: int) -> Handle {
    return v; // Conversione implicita consentita all'interno del modulo
}

// In main.zc
import "libreria.zc";

fn main() {
    let h: Handle = crea_handle(42);
    // let i: int = h; // Errore: Validazione del tipo fallita
    // let h2: Handle = 10; // Errore: Validazione del tipo fallita
}
```
```c
// In libreria.h
typedef struct { int value; } Handle;

Handle crea_handle(int v);

// In libreria.c
Handle crea_handle(int v) {
    return (Handle){ v };
}

// In main.c
#include "libreria.h"

int main(void) {
    Handle h = crea_handle(42);
    // int i = h;       // Errore: tipi incompatibili
    // Handle h2 = 10;  // Errore: tipi incompatibili
}
```
