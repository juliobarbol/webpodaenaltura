# Hallazgos — grupo `incontextenglish` + `game1claude`

Auditoría del uso de Claude Code de Julio Barrientos Bolbochan.
Fecha de corte: **2026-08-10**.

Fuentes:

- `auditoria/pagina1-sesiones.tsv` (13 filas corresponden a estos dos repos).
- Clones con historial completo en `/workspace/juliobarbol/incontextenglish` y
  `/workspace/juliobarbol/game1claude`.
- Los commits llevan trailer `Claude-Session: https://claude.ai/code/session_…`,
  lo que permite atribuir cada commit a su sesión. Se usa eso en todo el informe.

**Nota metodológica:** no tengo transcripciones de las sesiones. Todo lo que
afirmo sale de (a) las columnas `estado`, `categoria`, `pendiente`, `out_tokens`
y `cache_read` del TSV, y (b) el historial de git y los cuerpos de los commits.
Donde infiero, lo digo.

**Corrección previa sobre los datos de entrada:** `sesiones-todas.tsv` **no
contiene ninguna fila** de estos dos repos (su columna `repos` sólo tiene
`presupuesto-ar`, `stockmerger/stockvendedor`, `pruevacero` y `ArborRisk`), y los
dos volcados `mcp-…list_sessions-*.txt` cubren 2026-06-27 a 2026-07-24, con cero
menciones a `incontextenglish` o `game1claude`. La única fuente de sesiones útil
para este grupo es `pagina1-sesiones.tsv`.

---

## 1. El "agujero" de `game1claude`: no existe. El trabajo se borró a propósito

### 1.1 La premisa de partida era un artefacto de medición

El brief dice «sólo 3 commits en main, 6 ramas, 2 mergeadas, CLAUDE.md de 197
líneas». **Los tres números están mal, y todos por la misma causa.**

`main` tiene **31 commits**, no 3:

```
$ git rev-list --count origin/main
31
```

Lo que sí tiene 3 commits es **la rama por defecto del repo en GitHub**, que
nunca se cambió:

```
$ git symbolic-ref refs/remotes/origin/HEAD
refs/remotes/origin/claude/game1-precision-platformer-sc1bqy

$ git rev-list --count origin/claude/game1-precision-platformer-sc1bqy
3
```

Esa rama es la **primera** que abrió Claude, el 2026-07-27 (`1c49fc2`, `38d156d`,
`cf5f569`). Y su `CLAUDE.md` mide exactamente **197 líneas** — el número del
brief. Es la guía de FILO, el juego, borrado hace dos días:

```
$ git show origin/claude/game1-precision-platformer-sc1bqy:CLAUDE.md | head -4
# FILO — Guía del proyecto (para Claude Code)

> Juego de **plataformas de precisión** (PWA, se juega en el celu y en la
> compu). Esta guía es el mapa: leela antes de tocar el `index.html`.
```

**Hallazgo estructural: la rama por defecto de `juliobarbol/game1claude` en
GitHub apunta a una rama de trabajo abandonada, con un producto que ya no
existe.** Consecuencias reales, no teóricas:

- Cualquiera que entre al repo en GitHub ve un juego de plataformas, no el curso
  de inglés.
- Toda herramienta que lea "la rama por defecto" (la propia auditoría lo hizo)
  reporta datos de un proyecto muerto.
- El `wrangler.jsonc` de esa rama declara `"name": "filo"` mientras `main`
  declara `"name": "game1claude"`. Un push a la rama por defecto desplegaría al
  Worker equivocado.

### 1.2 Commits colgados fuera de `main`: **uno**, y es de un bot

```
$ git log --all --not origin/main --oneline
cb8955e (origin/update_worker_name_to_game1claude) Update wrangler config name to game1claude
```

Autor: `cloudflare-workers-and-pages[bot]`, 2026-07-28. Quedó obsoleto: Claude
hizo el mismo cambio a mano el 2026-08-08 en `e7b878a` («El worker se llama
game1claude, no filo»). Trabajo duplicado, pero de 1 línea.

De las 6 ramas, **5 están totalmente contenidas en `main`** (0 commits por
delante). La rama `claude/vicky-repo-requirements-hur214` es **bit a bit idéntica
a `main`** (`21768cb`), señal de que se fast-forwardeó main a la rama en vez de
mergear.

### 1.3 Lo que realmente pasó: 5.472 líneas escritas y borradas en 12 días

Las dos sesiones enormes del brief son las del **juego**:

| Sesión | Fecha | `out_tokens` | `cache_read` | Commits |
|---|---|---|---|---|
| `ZBRK` — "Juego de plataformas con precisión" | 2026-07-27 | 293.637 | 54.407.875 | 6 |
| `KKuN` — "Continuamos con el encadenado" | 2026-07-27 | 167.320 | 36.075.428 | 9 |
| **Total juego** | | **460.957** | **90.483.303** | **15** |

Esos 15 commits suman **+5.472 / −472 líneas** (medido con `git show --numstat`
commit por commit). El más grande, `1c49fc2`, mete el juego entero en un solo
archivo de 2.779 líneas.

El 2026-08-08, la sesión `wPuLJ` ("Eliminar juego FILO", 16.976 out tokens) lo
borró todo:

```
$ git show --stat a5401e6
a5401e6 Borrar FILO: el repo queda solo con el curso de inglés

 CLAUDE.md                  |  385 ------
 docs/encadenado.md         |  135 ---
 juego/index.html           | 2877 ---------------------------------
 juego/sw.js                |   54 -
 test/_bot.cjs              |  212 ----
 test/fisica.test.cjs       |  156 ---
 test/modos.test.cjs        |  400 ----
 test/pwa.test.cjs          |  158 ---
 test/solver.test.cjs       |  146 ---
 tools/trace.cjs            |  107 --
 …
  (52 líneas añadidas, 4.995 borradas)
```

Y el cuerpo del commit lo dice sin vueltas: *«El juego no sigue.»*

**El número que importa:** de los **769.132 tokens de salida** que consumieron
las 6 sesiones de `game1claude`, **460.957 (59,9 %)** produjeron código que hoy
no existe. De los **147.019.493 tokens de cache read**, **90.483.303 (61,5 %)**.

Esto **no es un fallo de proceso de Claude**: el juego se hizo, funcionó, se
desplegó, y el dueño decidió cambiar de producto. Es un fallo de **encuadre**: se
gastaron dos sesiones de escala industrial en algo que no tenía compromiso de
producto detrás. El síntoma temprano estaba a la vista — `fb0b51c` («Nota de
diseño: encadenar tramos (pendiente)») es una nota de diseño escrita por Claude
para sí mismo dentro de la misma sesión, es decir: el alcance ya no entraba.

### 1.4 El repo cambió de propósito sin dejar rastro donde importa

Cronología reconstruida:

| Fecha | Commit | Qué pasó |
|---|---|---|
| 2026-07-27 | `1c49fc2` | Nace FILO, juego de plataformas |
| 2026-07-27/28 | `38d156d`…`b1aa47d` | 14 commits más de juego (mundos 4 y 5, fantasma, maratón) |
| 2026-08-08 | `9f04903` | Aparece el curso de inglés en el mismo repo |
| 2026-08-08 | `4037ea6` | Merge: «el juego nuevo va a `juego/`, la raíz sigue siendo el curso» |
| 2026-08-08 | `a5401e6` | Se borra el juego entero |
| 2026-08-09 | `21768cb` | «La Parte 1 completa: las 12 clases armadas» |

**Y hoy `main` no tiene `CLAUDE.md` en la raíz:**

```
$ git ls-tree origin/main --name-only | grep -i claude
(nada)
```

La única guía vive en `curso/CLAUDE.md` (362 líneas). Claude Code carga
automáticamente el `CLAUDE.md` del directorio de trabajo y sus padres; un
`CLAUDE.md` en un subdirectorio se carga sólo cuando se tocan archivos de ahí.
**Una sesión nueva que arranque en la raíz del repo no recibe ninguna guía**, y
lo primero que ve son `index.html`, `test/` y un `wrangler.jsonc`. Sumado a que
la rama por defecto es la del juego, un agente nuevo tiene todas las papeletas
para reconstruir contexto equivocado.

Tampoco hay **ninguna** configuración de Claude Code en `game1claude`:

```
$ for b in <todas las ramas>; do git ls-tree -r --name-only $b | grep -c '^\.claude/'; done
0 0 0 0 0 0 0 0
```

Cero comandos, cero hooks, cero `settings.json` — contra los 3 comandos + hook
`PostToolUse` + hook `SessionStart` que sí tiene `incontextenglish`.

### 1.5 Trazabilidad rota en el tramo más caro de `main`

Los 3 commits del 2026-08-09 (`61269d2`, `dbad37f`, `21768cb`) **no llevan
trailer `Claude-Session`**, a diferencia de los otros 27. Son
**+4.037 / −441 líneas** — el 2026-08-09 es el día más productivo del repo y es
el único que no se puede atribuir a una sesión con certeza. Por la rama
(`claude/vicky-repo-requirements-hur214`) y la fecha corresponden a la sesión
`6zRZA5` ("Requisitos de Vicky para el repo", 2026-08-08, 122.474 out tokens),
pero es inferencia, no dato.

---

## 2. Alucinación desde la documentación — CONFIRMADO, y el archivo culpable sigue igual

### 2.1 El caso

Sesión **"Texto cortado en línea amarilla"** (`1bGbD`, 2026-08-02,
`incontextenglish`, 39.048 out tokens / 19.561.381 cache read). Cierre registrado
en el TSV:

> `testimonios nunca se construyó; memoria vino de ejemplo en publicar.md`

**El archivo culpable es `.claude/commands/publicar.md`.** Lo creó el commit
`05ffb75` (2026-08-02 00:16 UTC, sesión `01QVfoFpj3nXyHDFwWWPEd7S`), es decir
**horas antes** de la sesión que se confundió. Fragmento textual, paso 4:

```markdown
4. Commit en castellano, en imperativo, describiendo el cambio de cara al sitio
   (no el archivo tocado). Ejemplo: «Suma la sección de testimonios».
```

Ese `Ejemplo:` es lo único que menciona testimonios en todo el repo el
2026-08-02. Claude lo leyó como un hecho del sitio y no como una plantilla de
redacción.

### 2.2 Por qué el ejemplo era especialmente tramposo

1. **Está en un slash command**, o sea: se inyecta en el contexto cada vez que se
   corre `/publicar`, sin el marco de "esto es documentación de referencia".
2. **Nombra una feature concreta y plausible** ("la sección de testimonios") en
   un sitio que tiene home, cursos, sobre mí — una sección de testimonios encaja
   perfecto.
3. **Está en imperativo y en el mismo registro que los commits reales**, o sea
   indistinguible de una entrada de changelog.
4. La ironía final: **la sección se construyó de verdad 4 días después**, y el
   commit se llamó casi palabra por palabra igual que el ejemplo —
   `6a63a2b` (2026-08-06): **«Sumar la sección de testimonios a la home»**.

### 2.3 El archivo NO se corrigió

Ocho días y 23 commits después, el texto sigue idéntico:

```
$ git show origin/main:.claude/commands/publicar.md | sed -n '14,15p'
4. Commit en castellano, en imperativo, describiendo el cambio de cara al sitio
   (no el archivo tocado). Ejemplo: «Suma la sección de testimonios».
```

`git log --oneline -- .claude/commands/publicar.md` → un solo commit, `05ffb75`.
**Se identificó la causa raíz y no se arregló.** Hoy el ejemplo ya es verdadero
por casualidad, así que dejó de ser peligroso *para ese caso*; el patrón sigue
armado para el próximo.

### 2.4 Barrido de trampas equivalentes en los dos repos

Busqué en todos los `.md`, `CLAUDE.md`, `README.md` y `.claude/commands/` de las
14 ramas de ambos repos: (a) texto de ejemplo que nombra features, (b) rutas
citadas que no existen en el árbol, (c) cifras verificables.

**Resultado honesto: sólo hay UN caso más de la misma familia, y ninguno más en
`game1claude`.**

**Trampa #2 — un directorio que nunca existió.** `contenido/README.md` de
`incontextenglish` (commit `5a20066`, 2026-08-02):

> «**Borradores de páginas o de código de `public/`**: van en
> `contenido/borradores/`, respetando la ruta que van a tener.»

Está escrito en presente y con backticks, como si el directorio existiera. No
existe en ninguna rama:

```
$ for b in <las 8 ramas>; do git ls-tree -r --name-only $b | grep -c '^contenido/borradores'; done
0 0 0 0 0 0 0 0
```

Es el mismo mecanismo que `publicar.md`: prosa aspiracional escrita en indicativo
presente, leída después como inventario.

**Lo que NO encontré, y lo digo para no inflar el hallazgo:**

- El `CLAUDE.md` de FILO (385 líneas en su versión final, `a5401e6^`) **no tiene
  ni una sola aparición de "ejemplo", "por ejemplo", "supongamos" o similares**.
  Cero trampas de este tipo en `game1claude`.
- Validé una por una todas las rutas con backticks de `curso/CLAUDE.md` y
  `curso/ESQUEMA.md` contra el árbol de `main`: **todas existen** (los "faltantes"
  del script son referencias relativas tipo `clase.html` o plantillas tipo
  `data/<id>.js`).
- Validé las cifras verificables de `incontextenglish`, y **todas dan bien hoy**:
  «hay ocho links a WhatsApp con el mismo `href`» → 8 en `public/index.html`;
  «Testimonios: la sección ya está (`#testimonios`, tres citas)» → 3
  `class="testimonio"`; «el `<em>` del titular del hero» → existe, en el
  `data-en-html` de la línea 90.

El riesgo latente sí está: `curso/CLAUDE.md` de `game1claude` cierra con seis
párrafos «**Etapa N (hecha):**» que son afirmaciones de estado sin fecha ni
commit. Hoy son ciertas (verifiqué: 12 archivos de clase en `curso/data/`,
`n1p1u01`–`u10` más los checkpoints `n1p1c01`/`c02`). Es exactamente la clase de
texto que envejece mal.

---

## 3. Trabajo bloqueado por terceros (Victoria / Vicky)

**4 de las 13 sesiones del grupo (31 %) terminan esperando a Victoria.** Ninguna
otra sesión del TSV completo menciona a Victoria o Vicky.

| Sesión | Fecha | Repo | Estado | Qué espera | Días abierta al 10/8 |
|---|---|---|---|---|---|
| `gY3Bh` — Auditoría de seguridad y desarrollo web | 08-09 | incontextenglish | BLOCKED / `need_input` | «Victoria aprobar privacidad; testear filas nuevas tras deploy» | 1 |
| `6zRZA5` — Requisitos de Vicky para el repo | 08-08 | game1claude | REVIEW_READY | «12 clases + 3 libros + apéndice abiertos» | 2 |
| `eXRQB` — Posicionamiento en búsquedas de Google | 08-07 | incontextenglish | REVIEW_READY | «9 ítems para Victoria + 2 tareas de setup» | 3 |
| `2nSqSC` — Testimonios de Victoria | 08-06 | incontextenglish | REVIEW_READY | — (**resuelto**: aprobó 46 preguntas y corrigió 4) | cerrada |

### 3.1 El bloqueo tiene consecuencia material: 2 ramas sin mergear

**Las dos ramas sin mergear de `incontextenglish` son exactamente las dos
sesiones bloqueadas por Victoria.** No es coincidencia: `CLAUDE.md` dice
explícitamente *«Fusionar a `main` es otra cosa, porque eso sí publica. Salvo que
el dueño haya dicho lo contrario, preguntá antes de fusionar.»*

```
$ for b in …; do git rev-list --left-right --count origin/main...$b; done
claude/google-search-positioning-dchi0j:  0  1   ← sin mergear
claude/web-security-audit-9q6dys:         0  1   ← sin mergear
(las otras 4: 0 por delante, contenidas en main)
```

- **`fd1a041`** (2026-08-07, sesión `eXRQB`) — 10 archivos, +1.376 líneas: 4
  páginas nuevas (`/examenes/` + IELTS + TOEFL + Cambridge), JSON-LD `@graph`,
  sitemap con `lastmod`. **3 días sin publicar.**
- **`d545c6a`** (2026-08-10 03:15, sesión `gY3Bh`) — 11 archivos: endurecimiento
  del endpoint (Origin obligatorio, rate limit 60/IP/min, cuerpos >2 KB
  rechazados), borrado de eventos a 12 meses, HSTS, CI en GitHub Actions,
  Dependabot, `SECURITY.md` y **`public/privacidad/`**. **La página de privacidad
  del sitio no está en producción.**

**En tokens: 119.815 de los 227.605 tokens de salida de `incontextenglish`
(52,6 %) están hoy en ramas sin publicar.**

### 3.2 La lista de bloqueos vive en el peor lugar posible

La sesión `eXRQB` hizo lo correcto — documentó los 9 ítems en una tabla dentro de
`CLAUDE.md` en vez de inventar respuestas:

> **Lo que está frenado esperando datos de Victoria** (7/8/2026). Nada de esto se
> puede inventar: una respuesta aproximada en el sitio es peor que la ausencia de
> la pregunta […]
>
> | Precios por modalidad y frecuencia | Cómo es la clase de prueba | Duración y
> frecuencia | Plataforma de videollamada | Política de cancelación | Simulacros
> y material | Títulos y certificaciones | Si se puede nombrar Córdoba |
> Permiso de más alumnos para testimonios |

**Pero esa tabla sólo existe en `fd1a041`, que está sin mergear.** O sea: la
lista de todo lo que está frenado esperando a Victoria es invisible para
cualquier sesión que arranque desde `main`. Cada sesión nueva vuelve a descubrir
los mismos huecos.

---

## 4. Retrabajo

### 4.1 El caso limpio: un revert completo a los 4 minutos 43 segundos

| Hora (UTC) | Commit | Qué |
|---|---|---|
| 2026-08-06 22:01:37 | `fa6079a` | «Testimonios: citas cortas, chapa del logro y carrusel en mobile» — 3 archivos, +86/−29 |
| 2026-08-06 22:06:20 | `55bbd0d` | «Volver los testimonios a las citas completas» — 2 archivos, +26/−79 |

Verificado que es un revert real, no una corrección parcial:

```
$ git diff --stat fa6079a^ 55bbd0d
 public/_headers | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)
```

Es decir: de todo `fa6079a`, **lo único que sobrevivió fue el cambio de
`_headers`**. `index.html` y `styles.css` volvieron byte por byte al estado
anterior. Motivo, del cuerpo de `55bbd0d`:

> «Decisión del dueño (6/8/2026): prefiere los testimonios como estaban, con el
> mensaje entero y no resumido a una frase.»

Y el mismo commit identifica que **el problema original era otro**: *«Queda en
pie el cambio de `_headers` […] Ese es el motivo real de que la sección se viera
como texto suelto en un navegador que ya había visitado el sitio.»* O sea: se
rediseñó una sección entera para arreglar un **bug de caché**.

### 4.2 Churn documental: el mismo hecho documentado 4 veces en 9 horas

Tema: **qué rama publica**.

| Hora (UTC) | Commit | Sesión | Título |
|---|---|---|---|
| 08-02 02:53 | `68ffa9e` | `…Ed7S` | Corrige la nota de deploys: Workers Builds publica cualquier rama |
| 08-02 03:15 | `2218964` | `…Ed7S` | Registra como decisión que Workers Builds publique cualquier rama |
| 08-02 11:21 | `f78b82e` | `1bGbD` | Explicar qué rama publica y quitar la nota que pedía no tocarlo |
| 08-02 11:31 | `0367654` | `1bGbD` | Documentar que ahora sólo main publica |

Cuatro commits, dos sesiones, un solo hecho, y la conclusión final es la
**contraria** de la inicial. Parte es aprendizaje legítimo (se cambió la config
de Cloudflare en el medio), pero `2218964` documenta como "decisión deliberada"
algo que 8 horas después se revierte.

### 4.3 Churn por archivo (14 ramas de `incontextenglish`)

```
17  CLAUDE.md
10  public/styles.css
 9  public/quiz.js
 8  scripts/shots.mjs
 7  public/index.html
```

**`CLAUDE.md` es de lejos el archivo más tocado del repo** — 17 veces en 26
commits, más que cualquier archivo de producto. Buena señal de que la
documentación se mantiene; mala señal de que el contexto no se estabiliza.

`quiz.js` (9 toques) concentra la corrección-de-la-corrección de producto:
`c63762d` (guardar progreso) → `200fb88` («**Corregir** la regla de nivel del
test: dejaba de contar en el primer tropiezo») → `48dff40` (distinguir salteadas)
→ `f27599a` (banco propuesto) → `7746221` (anotar que espera revisión) →
`a42620e` («**Corregir** la pregunta de C1») → `21a5154` (banco de 50). Siete
commits sobre la misma lógica en 4 días.

### 4.4 En `game1claude`

- `080d645` («Impulso: una técnica…») → `d4a6493` («**El impulso destapó un
  agujero** en el 21 espejado»), 220 líneas nuevas y su parche inmediato.
- `77839d2` (nube, etapa 4) → `3fb8058` («El botón de la nube era **imposible de
  encontrar**») → `c1e8837` («La nube se actualiza sola **en vez de preguntar
  siempre**»). Tres iteraciones de UX sobre la misma feature en un día, todas
  disparadas por uso real.
- `cb8955e` (bot, 07-28) vs `e7b878a` (Claude, 08-08): el mismo rename de Worker
  hecho dos veces con 11 días de diferencia porque la rama del bot nunca se
  mergeó ni se miró.

---

## 5. Loops de verificación manual (Julio trabaja sólo desde Android)

**Confirmación del dato de partida:** en los volcados crudos de sesiones
(`mcp-…list_sessions-*.txt`, 80 sesiones, junio–julio 2026), el campo `origin`
da **78 `android` y 2 `desktop_app` — 97,5 % desde el celular**.

No tengo transcripciones, así que no puedo contar "sesiones que terminan pidiendo
mirar el celular". Lo que sí tengo son **cinco evidencias directas del loop en el
propio repo**:

**5.1 — El loop está institucionalizado en la documentación.** Los tres artefactos
de proceso terminan en "mirá vos":

- `CLAUDE.md`: «**Mirá siempre `.shots/home-mobile.png`**: el sitio nació de un
  diseño de ancho fijo y las regresiones de layout aparecen casi siempre en
  mobile.»
- `.claude/commands/publicar.md`, paso 3: «**Mirá la captura mobile de lo que
  hayas tocado.**»
- `.claude/commands/revisar.md`, paso 3: «Mirá las capturas de `.shots/` —
  **siempre incluí `home-mobile.png` y `test-intro-mobile.png`**».

**5.2 — El punto ciego está admitido por escrito.** `CLAUDE.md`:

> «Las capturas se sacan **sin las tipografías de Google** (no hay salida a
> internet en el sandbox), así que sirven para layout, **no para juzgar la
> tipografía fina**.»

Es decir: el sistema de verificación automática declara explícitamente que hay
una clase de defecto que sólo Julio puede ver, y Julio la ve en un teléfono.

**5.3 — Un bug que sólo existía en el Android de Julio.** `07e10d0` (2026-08-02):

> «Con "reducir movimiento" activado (**o el ahorro de batería de Android**) la
> marquesina amarilla quedaba estática y recortada a los lados: había que
> arrastrarla para terminar de leer las frases.»

Ése es literalmente el "texto cortado en línea amarilla" que le da nombre a la
sesión `1bGbD`. No es reproducible en el sandbox: el reporte, el diagnóstico y la
validación pasaron todos por el celular.

**5.4 — Un rediseño entero disparado por lo que Julio vio en el teléfono.**
`fa6079a`: «En el teléfono las tres tarjetas apiladas eran un muro de texto…» —
y revertido a los 4 minutos (§4.1). Ida y vuelta completa por canal humano.

**5.5 — Verificación manual pendiente todavía hoy.** El `pendiente` de la sesión
`gY3Bh` (2026-08-09) es «**testear filas nuevas tras deploy**»: hay que desplegar
y después mirar a mano si D1 recibe eventos.

**En `game1claude` el loop es peor, porque no hay capturas.** La verificación es
`node test/curso.test.cjs` y `nube.test.cjs`, y `curso/CLAUDE.md` documenta dos
cosas que **sólo Julio puede hacer**:

- «El PDF sale del navegador: `imprimir.html` → Imprimir → destino **Guardar como
  PDF**.» Todo el capítulo de impresión (tema claro forzado,
  `print-color-adjust: exact`, `break-inside: avoid`) se valida imprimiendo a
  mano — desde un Android.
- «en el sandbox de Claude Code el navegador **no sale a internet**, así que ahí
  corre siempre así [modo DOBLE]». El camino real contra Supabase nunca lo
  ejerce Claude.

---

## 6. Decisiones colgadas (`need_input` con decisión real pendiente)

Cuatro sesiones del grupo quedaron en `need_input`. Tres tienen decisión real:

| Sesión | Fecha | Repo | Pregunta abierta | Días | Commits producidos |
|---|---|---|---|---|---|
| `RtEuwH` — Cloud Design export analysis | 08-03 | incontextenglish | «¿bajar PNGs originales a `contenido/` o proceder distinto?» | **7** | **0** |
| `oS3s2` — Syllabus Nivel 1 Parte 1 | 08-08 | game1claude | «¿undo recupera parte del borrador o todo?» | 2 | 12 |
| `gY3Bh` — Auditoría de seguridad | 08-09 | incontextenglish | Victoria: aprobar privacidad | 1 | 1 (sin mergear) |
| `p2CiZSf` — Optimización del repo (archivada) | 08-01 | incontextenglish | «Aprobar o denegar `AskUserQuestion`» | — | 0 (archivada) |

**El caso más caro es `RtEuwH`: 7 días abierta, 5.644 tokens de salida, cero
commits.** Y la pregunta sigue sin responder — `CLAUDE.md` de `main` todavía
dice:

> «**Las fotos son selfies** y ya están recortadas y convertidas. Los PNG
> originales **no están versionados**; vinieron del export de Claude Design.»

O sea: el material fuente del diseño del sitio existe sólo fuera de git, y la
sesión que iba a resolverlo se quedó esperando una respuesta de una línea.

`oS3s2` es distinto: **produjo 12 commits (+11.283/−3.386 líneas)** y todos
llegaron a `main`. La pregunta que quedó abierta es sobre comportamiento futuro,
no un bloqueo. Vale como ejemplo de `need_input` sano.

---

## 7. Correcciones concretas de `CLAUDE.md` — listas para pegar

### 7.1 `incontextenglish` — arreglar el ejemplo que causó la alucinación

**Archivo: `.claude/commands/publicar.md`, paso 4.** Reemplazar:

```markdown
4. Commit en castellano, en imperativo, describiendo el cambio de cara al sitio
   (no el archivo tocado). Ejemplo: «Suma la sección de testimonios».
```

por:

```markdown
4. Commit en castellano, en imperativo, describiendo el cambio de cara al sitio
   y no el archivo tocado. La forma es «Verbo + qué cambió para quien entra al
   sitio»; sacá el verbo y el objeto del `git diff` que acabás de leer, nunca de
   un ejemplo escrito acá.
```

**Justificación.** El ejemplo original nombraba una feature (`la sección de
testimonios`) que el 2026-08-02 no existía, y la sesión `1bGbD` de ese día lo
tomó como inventario del sitio; el TSV registra el diagnóstico literal
(«testimonios nunca se construyó; memoria vino de ejemplo en publicar.md»). El
archivo nunca se corrigió (`git log -- .claude/commands/publicar.md` → un solo
commit, `05ffb75`). Un slash command se inyecta en contexto sin marco de "esto es
un ejemplo", así que la regla es: **cero sustantivos de producto en los ejemplos
de un comando.**

### 7.2 `incontextenglish` — sección nueva en `CLAUDE.md`

Pegar **al final de la sección «Trampas conocidas»**:

```markdown
- **La documentación de este repo NO es inventario del sitio.** `CLAUDE.md`, los
  `README.md` y los comandos de `.claude/commands/` describen intenciones, reglas
  y ejemplos de redacción. **Antes de afirmar que algo existe en el sitio —una
  sección, una página, un archivo, una carpeta— comprobalo en el árbol**
  (`Grep`/`Glob` sobre `public/`, o `git ls-files`). Ya pasó una vez: el
  2/8/2026 una sesión dio por hecho que la home tenía sección de testimonios
  porque `.claude/commands/publicar.md` la usaba como ejemplo de mensaje de
  commit. La sección recién se construyó el 6/8/2026.
- **Al escribir documentación, marcá el tiempo verbal.** Lo que existe va en
  presente y con la ruta real entre backticks. Lo que se piensa hacer va con
  «pendiente:» o «cuando haga falta:» adelante. Nunca describas en indicativo
  presente una carpeta que todavía no creaste.
```

**Justificación.** Cubre las dos trampas encontradas: el ejemplo de
`publicar.md` (§2.1) y `contenido/borradores/`, que `contenido/README.md`
describe en presente y no existe en ninguna de las 8 ramas (§2.4). Es la regla
más barata de todo el informe: dos párrafos que cierran una clase entera de
error.

### 7.3 `incontextenglish` — hacer visible lo que está frenado

Pegar **al final de `CLAUDE.md`**, reemplazando la sección «Pendientes de
contenido»:

```markdown
## Bloqueado esperando a Victoria

Esta lista es la fuente de verdad y vive en `main` a propósito: si vive sólo en
una rama sin mergear, cada sesión nueva vuelve a descubrir los mismos huecos.
Actualizala en el mismo commit en que aparece o se resuelve un bloqueo.

**Nada de esto se inventa ni se aproxima.** Una respuesta a ojo en el sitio es
peor que la ausencia de la pregunta: la lee alguien que después llega a la clase
con otra expectativa. Si falta un dato, la página no lo menciona y el hueco se
anota acá.

| Desde | Pendiente | Qué desbloquea |
|---|---|---|
| 3/8/2026 | ¿Los PNG originales del export de Claude Design van a `contenido/`? | Poder rehacer las fotos sin volver a exportar |
| 7/8/2026 | Precios por modalidad y frecuencia | La página de precios |
| 7/8/2026 | Clase de prueba: duración, si es sin cargo | El botón está en toda cabecera y no se explica |
| 7/8/2026 | Duración y frecuencia de las clases | FAQ y páginas de curso |
| 7/8/2026 | Plataforma de videollamada | FAQ |
| 7/8/2026 | Política de cancelación / reprogramación | FAQ |
| 7/8/2026 | ¿Trabaja con simulacros? ¿Con qué material? | Páginas de examen |
| 7/8/2026 | Títulos y certificaciones, nombre exacto | `Person` del JSON-LD y «Sobre mí» |
| 7/8/2026 | ¿Se puede nombrar Córdoba? | Búsquedas locales |
| 7/8/2026 | Permiso de más alumnos para testimonios | Más testimonios en la home |
| 9/8/2026 | Aprobar el texto de `public/privacidad/` | Publicar la rama de seguridad |

## Ramas esperando decisión

Este repo **no mergea solo**: `CLAUDE.md` pide preguntar antes de fusionar, así
que las ramas aprobadas se quedan quietas si nadie avisa. **Al empezar una
sesión, corré esto y decime qué encontrás antes de abrir una rama nueva:**

```bash
git fetch --all --prune
git branch -r --format='%(refname:short)' | grep -v 'origin/main$' | grep -v HEAD |
  while read b; do echo "$b: $(git rev-list --count origin/main..$b) commits sin publicar"; done
```

Una rama con más de 3 días sin mergear es un problema a levantar, no un estado
normal. Al 10/8/2026 hay dos: `claude/google-search-positioning-dchi0j`
(4 páginas de exámenes, +1.376 líneas, desde el 7/8) y
`claude/web-security-audit-9q6dys` (endurecimiento del endpoint y la página de
privacidad, desde el 10/8).
```

**Justificación.** El 52,6 % de los tokens de salida del repo (119.815 de
227.605) está en dos ramas sin publicar, y la tabla de bloqueos que la sesión
`eXRQB` escribió correctamente **está dentro de una de esas ramas** (`fd1a041`),
o sea invisible desde `main` (§3.2). Es el bug de proceso más caro del grupo:
documentación de bloqueos bloqueada por el bloqueo que documenta.

### 7.4 `incontextenglish` — el límite de lo que Claude puede verificar

Pegar en `CLAUDE.md`, **justo después del bloque de `npm run shots`**:

```markdown
### Lo que las capturas NO ven, y por eso te lo pido a vos

El dueño trabaja **desde Android**, casi siempre desde el celular. Eso define qué
se puede cerrar en la sesión y qué no:

- **Layout y errores de JS**: los cubre `npm run shots`. No hace falta molestar.
- **Tipografía fina y color**: las capturas salen sin las tipografías de Google
  (el sandbox no sale a internet). Si el cambio es de tipografía o de contraste,
  decilo explícitamente y no lo des por bueno.
- **Preferencias del sistema Android** —«reducir movimiento», ahorro de batería,
  tamaño de fuente del sistema, gestos de scroll— **no se reproducen acá**.
  Cualquier cosa animada (la marquesina, el carrusel, el scroll-snap) hay que
  probarla en el teléfono. El 2/8/2026 la marquesina amarilla quedaba cortada
  sólo con el ahorro de batería activado.
- **Caché del navegador**: si algo «se ve mal» y el código está bien, mirá
  `public/_headers` antes de rediseñar nada. El 6/8/2026 se rediseñó la sección
  de testimonios entera y se revirtió a los cinco minutos: el problema real era
  que `styles.css` se cacheaba una hora.

**Cuando necesites que mire algo en el celular, pedí una sola cosa concreta y
decí qué mirar** («abrí la home y decime si la marquesina se lee entera»), no
«fijate si está bien». Y agrupá los pedidos al final del turno: cada ida y vuelta
cuesta una sesión.
```

**Justificación.** Cubre §5 entero y §4.1. El caso del rediseño-por-caché
(`fa6079a`/`55bbd0d`, 86 líneas escritas y tiradas en 4m43s) es evitable con una
sola línea de checklist.

### 7.5 `game1claude` — crear `CLAUDE.md` en la raíz (hoy no existe)

**Archivo nuevo: `/CLAUDE.md` en `main`.** Contenido completo, listo para pegar:

```markdown
# CLAUDE.md

Guía de este repositorio para Claude Code. Leela antes de tocar nada.

## Lo primero: este repo cambió de producto

`juliobarbol/game1claude` **hoy es un curso de inglés**, y nada más.

Entre el 27/7 y el 28/7/2026 este repo alojó **FILO**, un juego de plataformas
de precisión (15 niveles, PWA). El 8/8/2026 el juego se borró entero
(`a5401e6`: 4.995 líneas), y con él su `CLAUDE.md`, `juego/`, `tools/`, `docs/`
y sus cinco archivos de test. **No lo revivas, no lo referencies y no te
sorprendas si algo del historial lo menciona.** Si alguna vez hiciera falta:
`git checkout e2690b8 -- juego test tools docs CLAUDE.md`.

Restos legítimos del juego que **no se tocan**:
- El nombre del Worker es `game1claude` (no `filo`); ver `wrangler.jsonc`.
- El proyecto de Supabase se sigue llamando `filo`. Es sólo el nombre del
  proyecto y ahí vive la tabla de borradores del curso.
- **La rama por defecto del repo en GitHub sigue siendo
  `claude/game1-precision-platformer-sc1bqy`**, que es el juego viejo. Si ves esa
  rama, no es el proyecto. La rama que vale, y la única que publica, es `main`.

## Dónde está la guía de verdad

El detalle de cómo está armado el curso —arquitectura, esquema de datos, reglas
pedagógicas, editor, nube, impresión— está en **[`curso/CLAUDE.md`](curso/CLAUDE.md)
(362 líneas)**. **Leelo antes de tocar cualquier cosa de `curso/`.** Este archivo
es sólo el mapa de entrada; ése es el manual.

Ver también `curso/ESQUEMA.md` (el contrato de un archivo de clase) y
`curso/nivel-1/parte-1/syllabus.md` (la fuente de verdad del diseño del curso).

## Cómo verificar

```bash
node test/curso.test.cjs                                          # datos y esquema
NODE_PATH=/opt/node22/lib/node_modules node test/curso.test.cjs   # + navegador real
NODE_PATH=/opt/node22/lib/node_modules node test/nube.test.cjs    # borradores compartidos
```

**No hay capturas de pantalla automáticas en este repo.** Eso significa que hay
cosas que sólo puede comprobar el dueño, que trabaja **desde Android**:

- **La impresión y el PDF.** Salen del navegador (`curso/imprimir.html` →
  Imprimir → Guardar como PDF). La hoja `@media print` no la ve ningún test.
- **La nube contra Supabase de verdad.** En el sandbox no hay salida a internet,
  así que `nube.test.cjs` corre siempre en modo DOBLE. El modo REAL lo corre él.
- **Cualquier cosa táctil o de tamaño de fuente del sistema.**

Cuando necesites que mire algo, pedí **una** cosa concreta y decí qué mirar.

## Reglas de git

- **Sólo `main` publica.** Cada push a `main` dispara el deploy en Cloudflare
  Workers (Worker `game1claude`), sin build.
- **Todo commit lleva el trailer `Claude-Session`.** Los tres commits del
  9/8/2026 (`61269d2`, `dbad37f`, `21768cb`, +4.037 líneas entre los tres) se
  pushearon sin él y ya no se puede saber con certeza de qué sesión salieron.
- **Antes de abrir una rama nueva, mirá si hay alguna sin mergear:**
  `git branch -r | grep -v main` y `git rev-list --count origin/main..<rama>`.
  El 8/8/2026 se rehízo a mano un rename de Worker que ya estaba hecho en
  `update_worker_name_to_game1claude` desde el 28/7, porque nadie miró esa rama.

## Lo que NO es inventario

`curso/CLAUDE.md` cierra con una lista de «Etapa N (hecha)». **Es una nota
histórica, no un inventario del código.** Antes de dar por existente una clase,
una caja o una pantalla, comprobalo en el árbol (`curso/data/indice.js` y
`ls curso/data/`). Lo mismo vale para cualquier «ejemplo» que encuentres en la
documentación: un ejemplo nombra cosas que pueden no existir.
```

**Justificación, punto por punto.**

- **Existir.** `git ls-tree origin/main --name-only | grep -i claude` → nada. La
  única guía está en `curso/`, que Claude Code no carga cuando la sesión arranca
  en la raíz. El repo estuvo 2 días (y 4.037 líneas) sin guía de raíz.
- **La advertencia sobre el juego.** El repo se llama `game1claude`, la rama por
  defecto en GitHub es la del juego, y `README.md` de `main` explica cómo
  recuperar FILO del historial. Tres señales convergentes hacia el producto
  equivocado, para un agente que arranca sin contexto.
- **La sección de verificación manual.** `game1claude` no tiene `.claude/`
  (verificado en las 8 ramas: 0 archivos) ni sistema de capturas, y su
  `curso/CLAUDE.md` documenta dos caminos —impresión y Supabase real— que ningún
  test cubre.
- **Los trailers.** 3 de 31 commits los perdieron, y son justo los del día más
  productivo.
- **Las ramas sin mergear.** `cb8955e` vs `e7b878a`: el mismo trabajo hecho dos
  veces con 11 días de diferencia.

### 7.6 `game1claude` — acción fuera de `CLAUDE.md` (la más importante del informe)

**Cambiar la rama por defecto del repo en GitHub de
`claude/game1-precision-platformer-sc1bqy` a `main`.**

```bash
gh repo edit juliobarbol/game1claude --default-branch main
gh api -X DELETE repos/juliobarbol/game1claude/git/refs/heads/update_worker_name_to_game1claude
```

**Justificación.** Es la causa raíz de todos los números equivocados del brief
(«3 commits en main», «2 mergeadas», «CLAUDE.md de 197 líneas» — los tres son
lecturas de esa rama abandonada). Mientras siga así, la portada del repo en
GitHub muestra un juego borrado, cualquier herramienta que lea la rama por
defecto reporta mal, y un `git clone` sin `-b main` entrega FILO con su
`CLAUDE.md` de 197 líneas y un `wrangler.jsonc` que apunta al Worker `filo`.

### 7.7 `game1claude` — poner un piso de configuración

El repo no tiene **ningún** archivo bajo `.claude/` en ninguna de sus 8 ramas,
mientras `incontextenglish` tiene 3 slash commands, un hook `SessionStart` y un
hook `PostToolUse` que corre el validador después de cada edición. Dado que
`game1claude` sí tiene tests rápidos, el equivalente mínimo es un
`.claude/settings.json` con:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [{ "type": "command", "command": "node test/curso.test.cjs 2>&1 || true" }]
      }
    ]
  }
}
```

**Justificación.** `curso/CLAUDE.md` afirma que la validación es una sola y que
el editor y el test la comparten. Correrla sola después de cada edición convierte
esa afirmación en garantía, y es exactamente lo que ya funciona en el otro repo.

---

## Anexo — patrones que busqué y NO encontré

Para que el informe no invente simetrías:

- **No hay commits colgados en ramas sin mergear en `game1claude`**, más allá de
  un commit de bot de 1 línea. La hipótesis del brief («¿el trabajo quedó en
  ramas sin mergear?») es falsa; la respuesta correcta es «se hizo, se mergeó, se
  desplegó y después se borró a propósito».
- **No hay alucinaciones desde la documentación en `game1claude`.** Ni en el
  `CLAUDE.md` de FILO (0 apariciones de «ejemplo» en 385 líneas) ni en
  `curso/CLAUDE.md` / `curso/ESQUEMA.md`, cuyas rutas verifiqué una por una
  contra el árbol de `main`.
- **No hay cifras desactualizadas en la documentación de `incontextenglish`**:
  «ocho links a WhatsApp», «tres citas» de testimonios y el `<em>` del hero dan
  todos exactos hoy.
- **No hay sesiones de estos repos en `sesiones-todas.tsv`** ni en los volcados
  crudos; sólo en `pagina1-sesiones.tsv`. Si la auditoría necesita cobertura
  completa, falta una página del listado.
- **No pude contar sesiones que terminan pidiendo verificación en el celular**,
  porque no hay transcripciones. Lo que hay son cinco evidencias indirectas
  (§5), no un conteo.
