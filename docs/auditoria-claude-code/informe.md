# Auditoría de uso de Claude Code — Julio Barrientos Bolbochan

**Período:** 18-may-2026 → 10-ago-2026 (84 días)
**Corpus:** 116 sesiones · 9 repositorios · 751 commits en `main` · 116 ramas `claude/*`
**Método:** metadatos de sesión (API de Claude Code Remote) cruzados con el historial
de git de cada repo y con el `CLAUDE.md` vigente. Cuatro sub-agentes en paralelo, uno
por grupo de repos, más un pase transversal sobre las 116 sesiones.

**Lo que esta auditoría NO pudo ver:** el transcript mensaje por mensaje de las
sesiones viejas. No existe herramienta que lo exponga y el contenedor es efímero. Todo
lo que sigue está inferido de metadatos + evidencia dura de git, nunca de la
conversación. Donde un patrón no se pudo verificar, se dice explícitamente.

**Corolario, aprendido a los golpes:** los datos muestran *qué* pasó, nunca *por qué*.
La primera versión de este informe leyó 18 ramas sin mergear como trabajo perdido;
Julio corrigió que fueron cierres deliberados. La sección 1 quedó reescrita y el
episodio se conserva acá porque ilustra exactamente el hallazgo que sobrevive: sin un
registro de la decisión, cualquiera —persona o modelo— deduce mal.

---

## Resumen ejecutivo

El problema no es la calidad de lo que Claude produce, ni —como creyó la primera
versión de este informe— trabajo perdido. Es que **las decisiones no quedan
registradas**: una rama que se descartó a propósito se ve idéntica a una que se olvidó,
y sesiones que cierran con una pregunta que nadie contesta.

| Dónde se traba | Magnitud |
| --- | --- |
| Ramas cerradas sin registro de por qué | **18 ramas** indistinguibles entre "descartada" y "olvidada" |
| Sesiones que cierran preguntando | **30 de 116** (26%), la mitad son cortesías vacías |
| `CLAUDE.md` desactualizados | 4 afirmaciones falsas en uno, mapa roto en 32/32 módulos en otro |
| Sesiones que se estiran sin criterio de cierre | **6 sesiones = 54%** del consumo total |
| Ramas por defecto mal apuntadas | **5 de 9 repos** (`webpodaenaltura` ya corregido) |

---

## 1. Las ramas cerradas sin registro

**18 de 116 ramas `claude/*` nunca se mergearon.** La primera versión de este informe
las llamó "trabajo perdido". **Eso era una inferencia equivocada** y Julio la corrigió:
en general no se mergearon porque *lo que él quería principalmente ya estaba resuelto*,
o porque *se arrepintió de la implementación*. Son cierres deliberados, no olvidos.

Esa corrección importa porque muestra el límite del método: los metadatos ven que una
rama no se mergeó, nunca **por qué**. La intención no está en los datos.

**Pero el problema no desaparece, cambia de forma y de tamaño.** Nada distingue una
rama que descartaste de una que se olvidó. El costo no es el trabajo — es que vos, y
cada sesión futura, tienen que volver a deducir cuál fue cuál. Esta auditoría lo dedujo
mal, que es precisamente la demostración del problema.

Se arregla con casi nada: borrar la rama, o dejarle una línea diciendo por qué no va.

### Estado verificable de las tres más citadas

Esto es lo que dice el código, sin interpretar intención:

| Rama / commit | Qué dice la evidencia |
| --- | --- |
| `c8cb419` — franja de marca del PDF duplicada al pie en multipágina | No está en `main`. La línea que genera la franja entró el 8-jun (`1f491a0`) y **ningún commit posterior la tocó**; tampoco hay otro que arregle lo mismo por otra vía. Si el defecto molestaba, sigue igual; si era un hallazgo lateral, está cerrado |
| `f5b7cf2` — reposición de stock y aging de deuda (126 líneas) | Ausente de `main`: `_clientAging` da 0 ocurrencias |
| `01ce8e6` — 3 skills (403 líneas) | Ausentes de `main`, que sólo tiene la skill `nuevo-tema-pdf` |

Las otras ramas sin mergear —`gastoscasa` (~694 líneas), `ArborRisk` (backup a Drive),
`incontextenglish` (exámenes y página de privacidad)— entran en la misma categoría:
ausentes de `main`, sin registro de si fue decisión o descuido.

**Las 3 skills son el único caso que conviene mirar aparte**, porque no son un cambio
de producto del que uno se arrepienta: son herramientas. Ver la sección 8.1. Dato
lateral: esa es la **única** sesión de `presupuesto-ar` iniciada desde la desktop app —
las otras 51 son desde Android.

### Lo que NO es un problema (verificado)

Tres alarmas que se investigaron y resultaron falsas:

- **`pruevacero` no tiene ramas abandonadas.** Las 7 están mergeadas.
- **En `stock*`, 4 de las 5 ramas huérfanas eran falsos positivos** — mismo contenido
  ya en `main`, verificado con `git patch-id --stable`.
- **`normalize()` y `schema.sql` nunca divergieron** entre `stockmerger` y
  `stockvendedor`, verificado en 6 cortes temporales. El miedo grande no se materializó.

---

## 2. El cierre por pregunta

**30 de 116 sesiones (26%) terminaron esperando algo tuyo.** Pero desagregado importa:

| Tipo | Cuántas | Ejemplo |
| --- | --- | --- |
| **Decisión real pendiente** | 10 | "¿coordenadas o Plus Code?", qué stack de analytics, Neon |
| **Cortesía de cierre** | **15** | "¿Seguimos con algo más?", "¿Querés que la limpie?" |
| Verificación en el celular | 3 | "¿Lográs entrar a Configuración → Estilo?" |
| Muertas esperando aprobar un `AskUserQuestion` | 2 | — |

**La mitad es ruido, y el ruido no es inocuo.** Las dos sesiones que dejaron
`ArborRisk` frío (19 y 20-jun) cerraron exactamente así — con una cortesía, no con un
bloqueo real. El proyecto no se abandonó por decisión: se enfrió porque la última
sesión terminó con una pregunta de compromiso.

Además, `ArborRisk` tiene **6 de 9 sesiones que no dejaron ni un commit** (ramas
fantasma).

---

## 3. Los `CLAUDE.md` se pudren y Claude les cree

Todos tus `CLAUDE.md` describen el código con números y rangos de línea. El código se
mueve; el archivo no. Resultado: Claude arranca cada sesión con datos falsos y gasta
tokens descubriéndolo.

**`presupuesto-ar`** — 4 afirmaciones falsas verificables:

| Dice | Realidad |
| --- | --- |
| "~8.000 líneas" | **19.374** |
| "CSS líneas 16–1711" | 21–3218 |
| "la app es inerte hasta rellenar `PUSH_WORKER_URL`" | relleno desde el 14-jun |
| `grep -n "===== js/" index.html` (su comando estrella) | devuelve `binary file matches` — le falta `-a` |

**`stockmerger` + `stockvendedor`** — el mapa de rangos de línea, que es la razón de ser
del archivo, está **roto en 22/22 módulos de merger y 10/10 del vendedor**. Desvío
promedio 749 líneas, máximo 1.835. Los rangos declarados hasta se pisan entre sí.
Además: 42,5% y 55,3% de esos dos archivos son líneas byte-idénticas entre sí, y hay
**1.807 líneas duplicadas en 15 archivos**.

**`pruevacero`** subestima su `index.html` 2,5× (dice 2.800 líneas, tiene 6.890).
**`gastoscasa`** lista como pendientes features que su propia rama sin mergear ya
implementó.

### El caso de alucinación, confirmado

En `incontextenglish`, el archivo `.claude/commands/publicar.md`, paso 4, trae:

> *Ejemplo: «Suma la sección de testimonios».*

Claude leyó el **ejemplo** y concluyó que la sección existía. La sesión "Texto cortado
en línea amarilla" (2-ago) se fue a verificar y descubrió que nunca se había
construido. **El archivo sigue idéntico 23 commits después.** Ironía final: la sección
se construyó de verdad el 6-ago, con un commit que se llama casi igual (`6a63a2b`).

El barrido encontró **una sola trampa más** (`contenido/borradores/`, descrito en
presente en `contenido/README.md`, no existe en ninguna rama) y ninguna en
`game1claude`.

---

## 4. Sesiones que se estiran sin criterio de cierre

Sólo 37 de 116 sesiones tienen datos de consumo. Sobre esas: **472,9 M de cache read
contra 2,3 M de output — ratio 205:1.**

**6 sesiones concentran el 54% del consumo total.** 15 concentran el 81%.

| Sesión | cache read |
| --- | --- |
| Juego de plataformas con precisión | 54,4 M |
| Funciones para mejorar la app (gastoscasa) | 44,4 M |
| Fase 1 rediseño del editor | 43,4 M |
| Syllabus Nivel 1 Parte 1 | 39,9 M |
| App security audit | 38,2 M |
| Continuamos con el encadenado | 36,1 M |

Qué tienen en común: **título de alcance abierto sin criterio de cierre**, están entre
las 8 de mayor output, 4 de 6 trabajan sobre `index.html` monolíticos, y —dato
importante— **ninguna terminó en `need_input`**. No se estiran por indecisión tuya: se
estiran por volumen.

La sesión de `gastoscasa` es el peor caso: **44,4 M de cache read, ratio 531:1, y su
resultado sigue sin mergear.** Máximo gasto, cero entrega.

Duración mediana de sesión: 3,5 h. **41% pasa las 6 h, 22% pasa las 12 h.**

---

## 5. Ramas por defecto mal apuntadas

**5 de 9 repos tienen la rama por defecto de GitHub apuntando a una rama `claude/*`**
en vez de a `main`:

| Repo | Default actual |
| --- | --- |
| `game1claude` | `claude/game1-precision-platformer-sc1bqy` |
| `ArborRisk` | `claude/arborisk-github-deploy-fsowc6` |
| `pruevacero` | `claude/pruebacero-player-analysis-7hu1mm` |
| `gastoscasa` | `claude/shared-expenses-app-xn21ue` |
| `webpodaenaltura` | **no tenía `main` en absoluto** — creada el 10-ago en `34ebd89` |

Esto no es cosmético. Cada sesión nueva aterriza en la rama equivocada, y cualquier
medición automática sale mal. De hecho **rompió esta misma auditoría**: mis dos primeros
números sobre `game1claude` y `pruevacero` estaban mal por medir contra `HEAD`. El
defecto auditado sesgó la auditoría.

Corolario en `game1claude`: el trabajo no se perdió, se borró a propósito (`a5401e6`,
8-ago, −4.995 líneas). Pero el saldo es que **el 59,9% de los tokens de salida de ese
repo (460.957 de 769.132) fue a código que hoy no existe.**

---

## 6. El costo del "sólo Android"

**112 de 116 sesiones desde Android** (2 desktop, 2 sin origen). No podés correr nada
local. Pero el costo real no es el que parecía:

- Sesiones que terminan pidiéndote mirar algo en el celular: **8 (7%)**. Menos de lo
  esperado, y **no hay patrón de loop de ida y vuelta**.
- El costo real es estructural: **80 de 116 sesiones (69%) cierran en `review_ready`, y
  49 de esas mencionan un deploy a producción en el resumen.** No hay staging. Se
  publica y se cierra.

Un caso concreto de lo que eso cuesta: el 30-jul Cloudflare se desconectó solo del repo
`presupuesto-ar` y estuvo **4 días sirviendo una versión vieja** (`87aaf03`), contra un
`CLAUDE.md` que afirma que "no hay ningún paso manual extra".

---

## 7. Familias de tareas repetidas

Asignación exclusiva, 116/116 sesiones:

| Familia | Sesiones | | Familia | Sesiones |
| --- | ---: | --- | --- | ---: |
| Features | 18 | | Contenido web | 7 |
| Diseño/UI | 16 | | Calendario | 6 |
| **Auditorías** | **13** | | Notificaciones | 4 |
| Deploy/Cloudflare | 10 | | Mapas | 4 |
| PDF | 9 | | Backup/sync | 4 |
| Stock | 9 | | WhatsApp | 3 |
| Meta-trabajo | 9 | | Accesos | 2 |

Las **13 auditorías**: 3 de seguridad, 4 de QA, 2 de estilos, 1 de logs, 1 de tests, 1
de inventario — y **una que fue escribir a mano el prompt de auditoría**
(`docs/prompt-auditoria.md`, que vive en un solo repo). En `presupuesto-ar` la
auditoría se reconstruyó desde cero **3 veces** (8-jun, 14-jul, 24-jul); la tercera
costó 139.452 tokens de salida y 38,2 M de cache read.

Escribir la misma auditoría tres veces es la definición de una skill que falta.

---

## 8. Propuestas

### 8.1 Skills

| Skill | Justificación | Estado |
| --- | --- | --- |
| **`/auditoria-app`** | 13 sesiones, reconstruida 3 veces en un repo | `docs/prompt-auditoria.md` ya existe — promoverlo a skill compartida |
| **`/deploy-y-verificar`** | 10 sesiones + 49 cierres con deploy + los 4 días sirviendo versión vieja | **Ya escrita** en `claude/cool-bohr-6riute`, sin mergear |
| **`/captura-visual`** | Sos sólo-Android; 8 sesiones te mandaron a mirar el celular | **Ya escrita** (`webapp-testing` + `app-shot.cjs`), sin mergear |
| **`/nueva-feature`** | 18 sesiones de features | **Ya escrita**, sin mergear |
| **`/cerrar-sesion`** | 15 cortesías vacías + 18 ramas colgadas | A crear |

**Tres de las cinco ya existen**, escritas el 13-jun en `claude/cool-bohr-6riute`
(`01ce8e6`, 403 líneas), y son la acción con mejor relación esfuerzo/resultado de toda
esta auditoría. Qué hace cada una:

- **`deploy-presupuesto`** (93 líneas) — convierte en procedimiento ejecutable el
  "Flujo de despliegue" que hoy está en prosa en el `CLAUDE.md`. Ataca lo que la propia
  skill llama *"el bug más caro de este proyecto"*: desplegar sin subir `CACHE_VERSION`
  en `sw.js`, con lo cual los celulares se quedan con la versión vieja cacheada. Sube
  la versión, valida que los archivos nuevos estén en `APP_SHELL` (si no, se rompe el
  offline), corre el chequeo de sintaxis del JS embebido y el test PWA, y define también
  cuándo **no** desplegar.
- **`nueva-feature`** (91 líneas) — las reglas no-negociables al sumar código: plata
  siempre en centavos (nunca floats de pesos), fechas en local y nunca UTC
  (`toISOString().slice(0,10)` corre el día en Argentina), escapado XSS, fotos en
  IndexedDB, JS global sin módulos. Incluye la tabla de qué hace cada sección de
  `index.html` y el recordatorio de revisar los **dos** bloques de CSS —`@media print`
  y pantalla— al tocar el layout del presupuesto. **Ojo:** arrastra el "~8.000 líneas"
  que la sección 3 marca como falso; corregirlo al levantarla.
- **`webapp-testing`** (70 líneas + `app-shot.cjs`, 149) — maneja la app en un navegador
  headless real: capturas, inspección del DOM, logs de consola, y la vista previa y el
  PDF en los **tres** modos (presupuesto, estimativo, riesgo). El script levanta el repo
  por HTTP, abre la app, le inyecta un setup JS para ponerla en el estado que se quiere,
  y captura. Es lo que evita tener que verificar todo desde el celular.

`/cerrar-sesion` es la que falta y la que ataca la causa raíz: obliga a terminar cada
sesión mergeando, o diciendo explícitamente por qué no se mergea y qué falta —
prohibido cerrar con "¿seguimos con algo más?".

### 8.2 Automatizaciones (Routines programadas)

| Automatización | Qué resuelve |
| --- | --- |
| **Barrido semanal de ramas sin mergear** en los 9 repos, con antigüedad, pidiendo una línea de decisión por cada una: va o se borra | Las 18 ramas sin registro. No para forzar el merge, sino para que quede escrito cuál se descartó y por qué |
| **Chequeo de deriva del `CLAUDE.md`**: comparar líneas y rangos declarados contra reales | Los 4 datos falsos, los 32 módulos con mapa roto |
| **Verificación post-deploy**: que Cloudflare esté sirviendo el commit esperado | Los 4 días sirviendo `87aaf03` |
| **Recordatorio de decisiones colgadas >7 días** | Las 10 decisiones reales abiertas |

### 8.3 Correcciones de `CLAUDE.md`

Transversal a todos los repos — la regla que evita que se pudran:

```markdown
## Cómo describir el código en este archivo

No escribas números de línea ni totales de líneas. Se desactualizan en días y
Claude les cree. Para ubicar algo, dá el comando que lo encuentra:

    grep -na "marcador" archivo.html

Cualquier dato que quede escrito acá tiene que poder verificarse con un comando
que también esté escrito acá.
```

Y la que evita la alucinación:

```markdown
## Ejemplos en la documentación

Los ejemplos de este archivo y de `.claude/commands/` son ilustrativos: describen
la FORMA de un pedido, no features que existan. No asumas que algo existe porque
aparece en un ejemplo. Verificalo en el código antes de darlo por hecho.
```

Las correcciones específicas por repo, redactadas listas para pegar, están en los
informes detallados:

- [`hallazgos-presupuesto-ar.md`](hallazgos-presupuesto-ar.md) — sección 6
- [`hallazgos-stock.md`](hallazgos-stock.md) — sección "Correcciones propuestas", C-1 y C-2
- [`hallazgos-english-game.md`](hallazgos-english-game.md) — sección 7 (4 bloques + un `CLAUDE.md` completo para `game1claude`)
- [`hallazgos-chicos-y-global.md`](hallazgos-chicos-y-global.md) — sección 4

---

## 9. Qué haría primero

Por relación esfuerzo/resultado:

1. **Levantar `claude/cool-bohr-6riute`** — te devuelve 3 skills ya escritas, incluida
   la de captura visual que ataca tu limitación de sólo-Android. Es tooling, no un
   cambio de producto: es el único de los 18 casos que casi seguro no fue un descarte
   deliberado. Al levantarlas, corregir el "~8.000 líneas" que `nueva-feature` arrastra.
2. **Poner `main` como rama por defecto** en los 4 repos que faltan. Es lo que hizo
   que esta misma auditoría midiera mal. En `webpodaenaltura` la rama ya se creó
   (10-ago, `34ebd89`); resta marcarla como default en GitHub.
3. **Arreglar `.claude/commands/publicar.md`** — el ejemplo que causó la alucinación,
   sigue ahí.
4. **Cerrar las 18 ramas con una línea cada una**: se mergea, o se borra diciendo por
   qué. Media hora, y a partir de ahí ninguna sesión futura vuelve a deducir mal.
5. Decidir sobre `c8cb419` con el dato de la sección 1: la franja duplicada del PDF
   multipágina sigue sin arreglarse en `main` por ninguna vía. Va o se borra.
6. Recién después, crear `/cerrar-sesion` y las Routines.

---

## Anexo — datos

- [`datos-sesiones.tsv`](datos-sesiones.tsv) — el corpus crudo de sesiones.
- Los cuatro informes detallados citados arriba, cada afirmación con hash de commit,
  rama, fecha y título de sesión.
