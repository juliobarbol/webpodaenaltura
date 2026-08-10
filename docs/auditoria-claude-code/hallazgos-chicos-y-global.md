# Auditoría — repos chicos + patrón global de las 116 sesiones

Fecha del relevamiento: 2026-08-10.
Alcance: **ArborRisk, pruevacero, gastoscasa, webpodaenaltura** (puntos 1-4) y
**todas las sesiones** de Julio entre 2026-05-18 y 2026-08-10 (punto 5).

## Fuentes y método

- Índice de sesiones del scratchpad (`sesiones-todas.tsv`, `pagina1-sesiones.tsv`) +
  volcado crudo de `list_sessions` (JSON con `created_at`, `updated_at`, `outcomes.branches`,
  `origin`, `post_turn_summary`, `external_metadata.usage`).
- Dataset unificado y deduplicado por `id`: **116 sesiones**
  (2026-05-18T15:12Z → 2026-08-10T03:34Z). Los TSV del scratchpad suman 115 porque
  la sesión en curso (`Auditoría de sesiones con sub-agentes`) figura sin categoría;
  acá se cuenta, y se aclara cuándo se la excluye.
  Dataset reproducible en `work/all.json` (script `work/build.py`).
- Git: `ls-remote` + `git branch -r --merged/--no-merged origin/main` +
  `rev-list --left-right --count` sobre los clones de
  `/workspace/juliobarbol/{ArborRisk,pruevacero,gastoscasa}` y `/home/user/webpodaenaltura`.
- **Limitación declarada**: el MCP de GitHub sólo tiene habilitado
  `juliobarbol/webpodaenaltura` en esta sesión, así que **no se pudo verificar el estado
  de los Pull Requests** (abiertos/cerrados/mergeados) de los otros tres repos. Todo lo
  que se afirma abajo sobre "mergeado / sin mergear" es **estado de ramas en git**, que
  es lo que determina qué código está realmente en producción.
- Los datos de uso (`output_tokens`, `cache_read_tokens`) **sólo existen para 37 de las
  116 sesiones** (la API no los devuelve para las más viejas, anteriores a ~2026-07-20).
  Todos los porcentajes de tokens están calculados sobre esas 37 y se aclara siempre.

---

# 1. pruevacero: la premisa del encargo es incorrecta

**El encargo decía: "8 ramas y sólo 2 mergeadas, la peor tasa de todos los repos".
Los datos de git dicen lo contrario: pruevacero es el repo con MEJOR tasa de merge de
los cuatro — 7 de 7 ramas `claude/*` están íntegramente mergeadas a `main`.**

Evidencia (`git ls-remote --heads` + `git branch -r --merged origin/main`):

| Rama remota | Commits por delante de `main` | ¿Ancestro de `main`? |
| --- | ---: | --- |
| `claude/player-position-menu-x1yw7g` | 0 | sí |
| `claude/prueba-cero-continuation-tftsnv` | 0 | sí |
| `claude/pruebacero-player-analysis-7hu1mm` | 0 | sí |
| `claude/pruebacero-qa-audit-u4ut2j` | 0 | sí |
| `claude/pruebacero-timer-feature-tvpfow` | 0 | sí |
| `claude/sport-shoe-icon-08miwp` | 0 | sí |
| `claude/tactical-board-animation-y42b4y` | 0 | sí |

`git branch -r --no-merged origin/main` devuelve **vacío**. Los SHA locales coinciden
uno a uno con `ls-remote` tras un `git fetch --all`, así que no es un clon desactualizado.
`main` tiene 126 commits, de los cuales **37 son merge commits** — es decir, el flujo
"rama de trabajo → merge a main → estampado del SW" se ejecutó 37 veces.

**Qué sí quedó colgado**: nada de código. Lo que quedó es **basura de ramas**: 7 ramas
`claude/*` mergeadas y nunca borradas. Es higiene, no trabajo perdido.

**Un problema real que sí existe en pruevacero** y que el propio `CLAUDE.md` documenta
(sección "PENDIENTE", línea ~157):

> "En GitHub la rama por defecto del repo sigue siendo la de trabajo
> `claude/pruebacero-player-analysis-7hu1mm` (la producción en Cloudflare ya apunta a
> `main`, eso está bien)."

Confirmado con git: `origin/HEAD → origin/claude/pruebacero-player-analysis-7hu1mm`.
Esa rama es de **2026-07-05** y está **113 commits detrás de `main`**. Cualquier sesión
nueva que clone el repo sin especificar rama arranca sobre código de hace un mes.
**Esto pasa en 3 de los 4 repos** (ver punto 3).

De dónde puede venir el "2 mergeadas" del encargo: no de git. Podría venir del conteo de
PRs con estado `merged` en GitHub — muchos de esos merges se hicieron por
`git merge` + `push` directo desde la sesión (el `CLAUDE.md` de pruevacero lo instruye
explícitamente: *"merge a `main` → push (publicar sin preguntar; PR solo si lo pide)"*),
así que no generan PR. No pude verificarlo por la restricción de acceso mencionada arriba.

**Sesiones que generaron esas ramas** (8 sesiones tocaron pruevacero):

| Fecha | Sesión | Rama declarada | Estado final |
| --- | --- | --- | --- |
| 2026-07-15 | Neon for future projects | `claude/neon-evaluation-77jbx2` | **fantasma** (nunca se pusheó) |
| 2026-07-13 | PruebaCero quality audit | `claude/pruebacero-qa-audit-u4ut2j` | mergeada |
| 2026-07-12 | Animated tactical board for training | `claude/tactical-board-animation-y42b4y` | mergeada |
| 2026-07-10 | Player position menu expansion | `main` (directo) | — |
| 2026-07-10 | Sport shoe app icon | `main` (directo) | — |
| 2026-07-09 | Prueba cero continuation | `main` (directo) | — |
| 2026-07-07 | Pruebacero timer feature | `claude/pruebacero-timer-feature-tvpfow` | mergeada |
| 2026-07-05 | Player analysis app planning | `claude/pruebacero-player-analysis-7hu1mm` | mergeada (y quedó como default branch) |

---

# 2. ArborRisk: no se abandonó — el trabajo quedó sin mergear

`main` termina el **2026-06-10** (`ad8e561`). Pero las dos últimas sesiones de trabajo
sobre el repo son posteriores y **su código existe, pusheado, sin mergear**:

| Rama | Fecha | Commits sobre `main` | Contenido |
| --- | --- | ---: | --- |
| `claude/arbor-risk-repo-optimization-eyfhy0` | 2026-06-19 | **+1** | `docs: flujo de trabajo autónomo y autorización permanente de deploy` (CLAUDE.md, +18/-1) |
| `claude/arborrisk-backup-sync-plan-82v2yx` | 2026-06-20 | **+2** | Fase 1: backup automático a Google Drive (`index.html` **+442/-58**, `sw.js`, `CLAUDE.md`) · Fase 2: `schema.sql` (148 líneas) + `docs/fase2-sync-supabase.md` (157 líneas) |

O sea: **una feature completa (backup a Drive) y el diseño de sync con Supabase nunca
llegaron a producción**. Ambas ramas tienen `merge-base` en `bfe5fcc` (2026-06-09) y están
**4 commits detrás** de `main` — se bifurcaron antes del trabajo de 2026-06-10, así que
mergearlas hoy requiere resolver conflictos en `CLAUDE.md` (la rama de 06-19 *borra* el
mapa de token-saving que `main` agregó el 06-10; son dos versiones divergentes del mismo
archivo).

**Por qué se cortó**: las dos sesiones terminaron en `need_input` con una **pregunta de
cortesía**, no con un merge:

- 2026-06-19 · *Arbor Risk repo workflow optimization* → `"¿Querés que la limpie?"`
- 2026-06-20 · *ArborRisk backup and real-time sync* → `"¿Querés que te genere también
  una versión del Excel (plantilla .xlsx lista para llenar con las personas)...?"`

Julio nunca contestó, la rama quedó ahí, y el repo no volvió a tocarse.

**Ironía documentada**: el commit sin mergear del 06-19 es justamente el que agrega a
`CLAUDE.md` la *"AUTORIZACIÓN PERMANENTE (deploy): el usuario autoriza de forma permanente
y explícita mergear la rama de trabajo a `main` y pushear `main` automáticamente al
terminar"*. Esa instrucción, que habría evitado exactamente este problema, **está atrapada
en la rama que no se mergeó**.

**Sobre las "9 sesiones" de ArborRisk**: el conteo es engañoso. En 4 de las 9, ArborRisk
es apenas un repo adjunto junto a otros (Neon evaluation, backup-sync, repo-optimization,
token-saving, GitHub deployment). Sesiones realmente centradas en ArborRisk: 5, todas
entre el 09 y el 20 de junio. Además, **6 de las 9 sesiones no dejaron ni un commit**
(rama declarada que nunca existió en el remoto):

| Sesión | Rama declarada | ¿Existe en el remoto? |
| --- | --- | --- |
| 2026-06-09 · New session | `claude/new-session-4y0sco` | **no** (murió esperando `AskUserQuestion`) |
| 2026-06-09 · ArborRisk GitHub and Cloudflare deployment | `claude/arborrisk-github-cloudflare-wldhir` | **no** (`failed`, `ede_diagnostic`, duró 1m12s) |
| 2026-06-09 · Test coverage analysis | `claude/test-coverage-analysis-p564a0` | **no** (terminó pidiendo confirmación para escribir los tests; nunca se escribieron) |
| 2026-06-09 · Claude skills directory setup | `claude/skills-directory-setup-lppeaw` | **no** (guardó la skill en `~/.claude/skills/`, fuera del repo → **se perdió con el contenedor**) |
| 2026-06-10 · Token-saving system setup | `claude/token-saving-system-bwuw8e` | **no** |
| 2026-07-15 · Neon for future projects | `claude/neon-evaluation-77jbx2` | **no** (evaluación que sólo vive en el resumen de la sesión) |

Conclusión del punto 2: **ArborRisk no se abandonó por decisión; se enfrió porque las dos
últimas sesiones terminaron preguntando en vez de mergeando**, y porque más de la mitad de
sus sesiones fueron análisis/setup que no dejaron rastro en el repo.

---

# 3. Retrabajo y ramas abandonadas en los cuatro repos

## 3.1 Cuadro consolidado

| Repo | Ramas remotas | `claude/*` | Mergeadas | Sin mergear | Commits huérfanos | Default branch en GitHub |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| ArborRisk | 4 | 3 | 1 | **2** | **+3** | `claude/arborisk-github-deploy-fsowc6` ❌ |
| pruevacero | 8 | 7 | **7** | 0 | 0 | `claude/pruebacero-player-analysis-7hu1mm` ❌ (113 commits atrás) |
| gastoscasa | 3 | 2 | 1 | **1** | **+6** | `claude/shared-expenses-app-xn21ue` ❌ |
| webpodaenaltura | **1** | 1 | — | — | — | `claude/cloudflare-workers-token-6fzwce` ❌ (**no existe `main`**) |

**Ninguno de los cuatro repos tiene `main` como rama por defecto en GitHub.** En los tres
que tienen `main`, la default es una rama de trabajo vieja; en webpodaenaltura `main`
directamente **no existe** (`ls-remote --heads` devuelve una sola ref). Esto es sistémico y
es la causa mecánica más probable de que sesiones nuevas arranquen sobre código viejo.

## 3.2 gastoscasa — el caso más caro

`claude/app-feature-improvements-q8yuzu` está **6 commits por delante de `main`** y
**0 detrás** (mergea limpio, sin conflictos):

```
687b747 feat: totales por etiqueta en el resumen
929e1ae feat: gastos fijos con día, dueño y cuotas, y carga automática del mes
2760add feat: balance entre cualquier cantidad de personas y registrar pagos
5d3525f feat: los límites ahora avisan y proyectan el cierre del mes
5a52257 feat: buscador en el historial y repetir un gasto
b09c388 feat: navegación entre meses y fecha editable en los gastos
```

`index.html` en `main` = **2.893 líneas**; en la rama = **3.587**. Son **~694 líneas de
producto terminado que no están publicadas** — seis features enteras.

Esas seis features salieron de **una sola sesión**: 2026-07-29 · *Funciones para mejorar
la app*, cerrada como `review_ready` con detalle *"pagos entre personas wired; splits,
push notifs, config code remain"*. Es la **segunda sesión más cara de todo el historial**:
`cache_read = 44.432.971`, `output = 83.586` (ratio 531, el más alto de las 37 medidas).
**La sesión más cara sobre gastoscasa dejó el 100% de su salida sin publicar.**

Señal de retrabajo latente: el `CLAUDE.md` de `main` sigue listando como PENDIENTE
*"registrar pagos entre personas… gastos divididos en porcentajes distintos a 50/50"* —
exactamente lo que la rama sin mergear **ya implementó**. Una sesión futura que lea
`main` va a reimplementar features que ya existen.

## 3.3 webpodaenaltura

- Repo de 2 commits, ambos del 2026-08-04, en una única rama `claude/cloudflare-workers-token-6fzwce`.
- **No hay `main`.** No hay merge, no hay deploy consolidado.
- La única sesión de trabajo (2026-08-04 · *Cloudflare Workers token setup*) terminó en
  `need_input` con **tres preguntas de negocio sin responder**: *"(1) ¿los cursos siguen
  activos? (2) ¿publicar el PDF de poda segura? (3) ¿localidades exactas de cobertura?"*.
  Seis días después siguen sin respuesta y **no están anotadas en ningún archivo del repo**
  — sólo viven en el resumen de la sesión. Si esa sesión se archiva, se pierden.
- `public/` tiene sólo `index.html` (61 líneas, placeholder), `404.html`, `robots.txt` y
  `assets/css/base.css`. El rediseño no arrancó.

## 3.4 Ramas fantasma (trabajo que no dejó rastro)

Sesiones que declararon una rama en `outcomes` que **nunca existió en el remoto** — es
decir, terminaron sin un solo commit:

| Repo | Ramas fantasma | Sesiones |
| --- | ---: | --- |
| ArborRisk | 6 | New session, GitHub+Cloudflare deployment (failed), Test coverage analysis, Claude skills directory setup, Token-saving system setup, Neon for future projects |
| pruevacero | 1 | Neon for future projects |
| gastoscasa | 0 | — |
| webpodaenaltura | 0 | — |

## 3.5 Retrabajo visible en los títulos

- **`CDN versions and SRI hashes`** aparece dos veces seguidas (2026-06-09 `failed` por
  límite de sesión → 2026-06-10 `review_ready`). Rehacer completo.
- **`Budget app pre-launch audit`** aparece dos veces el mismo día (2026-06-08 20:07
  `failed` por `ede_diagnostic` → 20:08 relanzada, `review_ready`). Un minuto de vida y
  relanzamiento inmediato.
- **`Optimización del repositorio`** (incontextenglish) aparece dos veces el 2026-08-01,
  una de ellas archivada esperando `AskUserQuestion`.
- **`ArborRisk GitHub deployment`** (04:22) es la relanzada de
  **`ArborRisk GitHub and Cloudflare deployment`** (04:18, `failed`).

Patrón: **4 pares de sesiones duplicadas por caída o límite** en 116 sesiones.

---

# 4. Estado de los `CLAUDE.md`

Los cuatro comparten una misma "receta" (Qué es / Forma del proyecto / Trabajar sin quemar
tokens / mapa de líneas / Cómo verificar / Cosas que NO romper / Decisiones de Julio), lo
cual está muy bien. Los problemas son de **mantenimiento**, no de estructura.

| Repo | Líneas | Problema principal | Gravedad |
| --- | ---: | --- | --- |
| ArborRisk | 157 | Mapa de líneas **exacto** (2055–6980 vs 6.983 reales) ✅, pero **dos versiones divergentes** del archivo (main vs rama sin mergear) | media |
| pruevacero | 167 | **Mapa de tamaño desactualizado 2,5×** | **alta** |
| gastoscasa | 329 | Mapa desactualizado ~10% y **PENDIENTE contradice la rama sin mergear** | media |
| webpodaenaltura | 79 | Le falta todo lo operativo | media |

## ArborRisk

- ✅ Mapa de regiones y módulos JS **verificado y correcto** (`index.html` = 6.983 líneas,
  el mapa dice JS 2055–6980).
- ❌ **Existen dos `CLAUDE.md` incompatibles**: el de `main` (con la sección
  "⚠️ Trabajar sin quemar tokens" y tabla de líneas) y el de
  `claude/arbor-risk-repo-optimization-eyfhy0`, que **elimina esa sección** y la reemplaza
  por un mapa por marcadores (`grep -nE "js/[a-z]+\.js"`) más la autorización permanente de
  deploy. Quien mergee va a tener que elegir; hoy nadie eligió.
- ❌ No documenta que la default branch de GitHub no es `main`.
- ❌ No menciona las dos ramas con trabajo pendiente ni que la feature de backup a Drive
  existe pero no está publicada.
- ⚠️ Referencia `.claude/hooks/session-start.sh` para instalar el navegador headless — el
  hook existe en el repo, así que esto sí está bien.

## pruevacero

- ❌ **El dato más peligroso**: la sección "Trabajar sin quemar tokens" dice
  `index.html` pesa ~130 KB / ~2.800 líneas. **El archivo real tiene 6.890 líneas.**
  Está subestimado **2,5×**. Un agente que confíe en ese número planifica mal la lectura.
- ❌ La tabla de módulos **no tiene rangos de línea** (a diferencia de ArborRisk y
  gastoscasa) — sólo el rango del `<head>`/`<style>`/HTML, que sí quedó viejo
  (dice HTML 268–575 sobre un archivo 2,5× más grande).
- ✅ La sección "Cómo verificar cambios" es la mejor de los cuatro: incluye el chequeo de
  sintaxis, el patrón de test funcional con chromium headless y las **trampas conocidas**
  (`--virtual-time-budget` y los `await` de IndexedDB, IndexedDB no anda en `file://`).
- ✅ Es el único que documenta el problema de la default branch… pero como "idea menor",
  no como bloqueante.
- ⚠️ "PENDIENTE" dice *"No hay pedidos pendientes"* con fecha 2026-07-13. Es coherente con
  el estado del repo (nada sin mergear), pero está congelado hace un mes.

## gastoscasa

- ❌ Mapa dice `~140 KB / ~2.640 líneas`; el real en `main` es **2.893** (~10% de desvío)
  y en la rama sin mergear **3.587** (36% de desvío).
- ❌ La sección "PENDIENTE / ideas" lista como pendientes cosas que la rama
  `claude/app-feature-improvements-q8yuzu` **ya implementó** (registrar pagos entre
  personas, splits configurables). Riesgo directo de reimplementación.
- ✅ Excelente sección de seguridad: advierte explícitamente que *"el repo SE PUBLICA tal
  cual como app en Cloudflare y el historial de git no se borra"* y que nunca hay que
  commitear `SUPABASE_ACCESS_TOKEN`. Es el mejor tratamiento de secretos de los cuatro.
- ✅ Deploy y estampado del cache documentados con precisión.
- ❌ No documenta que la default branch no es `main`.

## webpodaenaltura

- ✅ Bien escrito, con el inventario del sitio viejo, la advertencia sobre los Términos y
  Condiciones copiados de una vinoteca, y los datos de contacto.
- ❌ **No registra las 3 preguntas abiertas** que bloquean el rediseño (cursos activos, PDF
  de poda segura, localidades). Están sólo en el `post_turn_summary` de la sesión del 08-04.
- ❌ No dice que **no existe `main`** ni cuál es el flujo de merge/publicación. Es el único
  de los cuatro sin sección de deploy operativo (los otros tres documentan
  `build.py`/`stamp-sw.yml`).
- ❌ No tiene sección "Cómo verificar cambios". Julio no puede correr nada local; sin esto,
  cada sesión improvisa la verificación.
- ❌ La estructura declarada menciona `public/assets/img/` y `public/assets/fonts/` — **no
  existen** en el repo.
- ❌ No tiene "Cosas que NO romper" ni "Decisiones de producto (de Julio)", que en los otros
  tres repos son la sección que evita retrabajo.
- ⚠️ "Estado actual" dice que `public/index.html` es un placeholder — eso sí está al día.

---

# 5. TAREA TRANSVERSAL — el patrón global sobre las 116 sesiones

## 5.a Distribución temporal y sesiones que se estiran

### Sesiones por semana ISO

| Semana | Lunes | Sesiones | |
| --- | --- | ---: | --- |
| 2026-W21 | 18-may | 1 | ▍ |
| 2026-W23 | 01-jun | 3 | █▎ |
| **2026-W24** | **08-jun** | **26** | ██████████████████████████ |
| 2026-W25 | 15-jun | 11 | ███████████ |
| 2026-W26 | 22-jun | 11 | ███████████ |
| 2026-W27 | 29-jun | 6 | ██████ |
| 2026-W28 | 06-jul | 12 | ████████████ |
| 2026-W29 | 13-jul | 6 | ██████ |
| 2026-W30 | 20-jul | 13 | █████████████ |
| 2026-W31 | 27-jul | 13 | █████████████ |
| 2026-W32 | 03-ago | 13 | █████████████ |
| 2026-W33 | 10-ago | 1 (parcial) | ▍ |

Lectura: hay un **pico de arranque** en la semana del 8 de junio (26 sesiones, 22% del
total — es la semana en que Julio descubre la herramienta; el reparto diario es
8-jun: 6 · 9-jun: 7 · 10-jun: 4 · 11-jun: 2 · 12-jun: 1 · 13-jun: 5 · 14-jun: 1) y después
un **régimen estable de 11-13 sesiones por semana** desde el 20 de julio. No hay señal de abandono: el uso es sostenido y creciente.

### Duración de sesión (`updated_at − created_at`)

- Mediana: **3,5 h**
- **48 de 116 sesiones (41%) duran más de 6 h**
- **26 de 116 (22%) duran más de 12 h**

Las más largas (nota: `updated_at` incluye el tiempo que la sesión queda esperando a Julio,
así que esto mide *elapsed*, no cómputo — y por eso mismo es una buena métrica del
**tiempo en que el trabajo queda parado esperando a una persona**):

| Horas | Fecha | Sesión | cache_read |
| ---: | --- | --- | ---: |
| 262,4 | 2026-07-14 | App security audit (presupuesto-ar) | 38.161.169 |
| 186,3 | 2026-06-27 | Joist Invoice app analysis (presupuesto-ar) | n/d |
| 107,8 | 2026-08-02 | Texto cortado en línea amarilla (incontextenglish) | 19.561.381 |
| 47,6 | 2026-07-07 | Pruebacero timer feature | n/d |
| 47,5 | 2026-06-16 | Odoo functions analysis | n/d |
| 47,4 | 2026-07-30 | Stock y conectividad: banco de pruebas | 8.972.430 |
| 37,3 | 2026-07-07 | Multi-day job scheduling | n/d |
| 37,1 | 2026-06-18 | StockMerger/StockVendedor security audit | n/d |
| 37,1 | 2026-07-10 | Player position menu expansion | n/d |

### Consumo: `cache_read` × `output_tokens`

Sobre las **37 sesiones con datos de uso** (las 79 restantes no los exponen):

- `cache_read` total medido: **472.945.098**
- `output` total medido: **2.302.202**
- Ratio global: **205 tokens de contexto releído por cada token producido**
- Mediana de `cache_read`: **7.192.004**

| Umbral | Sesiones | % de las 37 medidas | `cache_read` acumulado | % del total medido |
| --- | ---: | ---: | ---: | ---: |
| **> 20 M** | **6** | 16% | 256.419.636 | **54%** |
| > 10 M | 15 | 41% | 385.426.956 | 81% |

**Las 6 sesiones que superan los 20 M concentran más de la mitad del consumo medido.**

| `cache_read` | `output` | ratio | Fecha | Sesión | Repos |
| ---: | ---: | ---: | --- | --- | --- |
| 54.407.875 | 293.637 | 185 | 2026-07-27 | Juego de plataformas con precisión | game1claude + presupuesto-ar + stockmerger |
| 44.432.971 | 83.586 | **531** | 2026-07-29 | Funciones para mejorar la app | gastoscasa |
| 43.429.627 | 152.561 | 284 | 2026-07-30 | Fase 1 rediseño del editor | presupuesto-ar |
| 39.912.566 | 165.377 | 241 | 2026-08-08 | Syllabus Nivel 1 Parte 1 | game1claude |
| 38.161.169 | 139.452 | 273 | 2026-07-14 | App security audit | presupuesto-ar |
| 36.075.428 | 167.320 | 215 | 2026-07-27 | Continuamos con el encadenado | game1claude |

**Qué tienen en común las 6** (verificado, no inferido):

1. **Título de alcance abierto, sin criterio de cierre.** "Funciones para mejorar la app",
   "Continuamos con el encadenado", "Fase 1 rediseño del editor", "Juego de plataformas con
   precisión". Ninguna es "arreglá X". Son sesiones-maratón que empaquetan N sub-tareas.
   Contraste: las 6 sesiones más baratas por `cache_read` (`Scribd PDF downloader` 86 K,
   `Cloud Design export analysis` 146 K, `Design: Web academia` 593 K,
   `Movimientos últimos 4 días` 681 K, `Design: Rediseño de Presupuestos` 1,17 M,
   `Flecha y círculo impresos en PDF` 1,24 M) tienen todas un título de una sola pregunta
   acotada.
2. **Son 6 de las 8 sesiones con más `output_tokens` de todo el set medido**: todas
   superan los 83.586 tokens de salida, y la nº 9 del ranking de output ya baja a 77 K.
   (Las dos que se cuelan en el top-8 sin superar los 20 M de cache son
   `Requisitos de Vicky` 122 K/13,9 M y `Aplicación de gastos compartidos` 95 K/17,7 M.)
   O sea: no es contexto desperdiciado, es trabajo real y mucho en una sola sesión.
3. **Repos de un solo archivo gigante**: 4 de las 6 trabajan sobre `index.html`
   monolíticos (gastoscasa 3.587 líneas, presupuesto-ar, pruevacero 6.890, ArborRisk 6.983).
   El ratio 531 de gastoscasa es exactamente el síntoma: releer el mismo archivo enorme
   turno tras turno.
4. **3 de las 6 son `game1claude`** (generación de contenido/curso), donde el material
   generado se acumula en contexto.
5. **Ninguna de las 6 terminó en `need_input`**: las 6 cerraron `review_ready`. No se
   estiraron por indecisión de Julio, se estiraron por volumen de trabajo.

**Sesión más cara + trabajo sin publicar**: la nº 2 de la tabla (gastoscasa, 44,4 M) es
justo la que dejó 6 commits sin mergear (punto 3.2). Es el peor caso combinado del
historial: máximo gasto, cero entrega.

## 5.b Sesiones que terminan en `need_input`: decisión real vs cortesía

**30 de 116 sesiones (26%) terminan en `need_input`.** Clasificadas una por una según el
texto de `needs_action`:

| Tipo | Sesiones | % de los `need_input` | % del total |
| --- | ---: | ---: | ---: |
| **A. Decisión real** (el trabajo no puede seguir sin un dato o criterio que sólo Julio tiene) | **10** | 33% | 8,6% |
| **B. Cortesía de cierre / ofrecimiento opcional** (el trabajo ya estaba terminado) | **15** | 50% | 12,9% |
| **C. Verificación manual en el dispositivo** (Claude pide que Julio mire algo) | 3 | 10% | 2,6% |
| **D. Bloqueo del harness** (`AskUserQuestion` pendiente de aprobar/denegar) | 2 | 7% | 1,7% |

**La mitad de los `need_input` son ruido.** Quince sesiones quedaron marcadas como
"esperando a Julio" cuando en realidad no esperaban nada:

> `"¿Seguimos con algo más?"` · `"¿Querés que siga ahora con algo o lo dejamos acá por hoy?"` ·
> `"¿Querés que dejemos acá por hoy, o seguimos con lo último que queda?"` ·
> `"¿Algo más que quieras que agregue al documento antes de cerrar?"` ·
> `"¿Querés que la limpie?"` · `"¿Lo dejamos como está o querés que les agregue la tarjeta a
> esos también?"` · `"¿Querés que repasemos algo de lo hecho o seguimos con otra cosa?"` ·
> `"¿Querés que también cambie el emoji 🌳...?"` · `"¿Querés que te lo deje anotado en algún
> CLAUDE.md como decisión tomada?"` · `"¿Querés que te genere también una versión del
> Excel...?"` · `"¿Querés que verifique si el deploy corrió bien, o lo dejamos acá?"` ·
> `"¿Querés que la próxima sesión arranque por alguna en particular?"` · `"¿Querías la
> Weather API de Google... o era más curiosidad?"` · `"¿Querés que ajuste algo del look?"` ·
> `"¿Querés que revise algún presupuesto en particular contra su PDF?"`

Las 10 de tipo A, en cambio, son legítimas y ninguna se podía resolver sola:

| Fecha | Sesión | Qué se pedía |
| --- | --- | --- |
| 2026-08-09 | Auditoría de seguridad y desarrollo web | aprobación de Victoria (tercero) sobre la página de privacidad |
| 2026-08-08 | Syllabus Nivel 1 Parte 1 | decisión de producto: ¿undo recupera parte del borrador o todo? |
| 2026-08-04 | Cloudflare Workers token setup | 3 datos de negocio (cursos, PDF, localidades) |
| 2026-08-03 | Design: Rediseño de Presupuestos | dato faltante ("¿Cuál es?") |
| 2026-08-03 | Cloud Design export analysis | decidir si bajar los PNG originales a `contenido/` |
| 2026-06-29 | Google Maps Plus Code in quotes | elegir entre coordenadas o Plus Code |
| 2026-06-24 | Poda en Altura PWA product analysis | autorización explícita para mergear a `main` |
| 2026-06-13 | Recommended skills for app development | decisión de configuración |
| 2026-06-09 | Test coverage analysis (ArborRisk) | confirmar si se arma el runner de tests |
| 2026-06-08 | Application usage analytics | elegir la vía de analytics y los eventos |

Costo del ruido: **15 sesiones marcadas como bloqueadas sin estarlo**. Como Julio revisa
por notificación desde el celular, cada una de esas es una notificación que no lleva a
nada, y —peor— **dos de ellas (ArborRisk 06-19 y 06-20) son exactamente las que dejaron
ese repo frío con 3 commits sin mergear** (punto 2). El cierre de cortesía no es sólo
ruido: en ArborRisk fue la causa directa de la pérdida de trabajo.

Dato extra: **2 sesiones murieron esperando aprobar un `AskUserQuestion`**
(2026-06-09 `New session` en ArborRisk, 47 s de vida; 2026-08-01 `Optimización del
repositorio` en incontextenglish). Cero output útil en ambas.

## 5.c Loops de verificación manual — el costo del "sólo Android"

**Confirmación del contexto de trabajo**: `origin` en el dataset da
**112 android / 2 desktop_app / 2 sin origen** sobre 116. Los 2 `desktop_app` son del
2026-06-13 (`Recommended skills for app development`, `Claude skills setup`) y los 2 sin
origen son las sesiones `Design:` del 2026-08-03. Es decir: **el 97% es Android**, pero la
afirmación "todas las sesiones son android" es **falsa por 4 casos**. Corrijo el dato en
vez de repetirlo.

### Sesiones que terminan pidiéndole a Julio que verifique algo en el celular

Buscando en `status_detail` + `needs_action` de las 116 sesiones, **5 sesiones piden
explícitamente una verificación manual en el dispositivo**:

| Fecha | Repo | Pedido textual |
| --- | --- | --- |
| 2026-06-08 | presupuesto-ar | `"¿Lográs entrar a Configuración → Estilo y ver las 4 opciones?"` |
| 2026-06-09 | stockmerger/vendedor | `"¿Ya pudiste correrlo?"` |
| 2026-06-22 | presupuesto-ar | `"Check notification bar now and tell me what you see (🌳 icon = success, ❌ nothing/old Chrome notification = SW not updated)"` |
| 2026-06-24 | presupuesto-ar | `"confirm OK to merge to main so you can test 2-page PDF on phone"` |
| 2026-08-09 | incontextenglish | `"test that new rows appear after deploy to Cloudflare"` |

Además, **2 sesiones cierran anunciando una espera de propagación al teléfono** —
verificación manual implícita:

- 2026-06-12 · *Per-person access management*: `"waiting for deploy to phones (~5 min)"`
- 2026-06-21 · *StockMerger exchange rate sync*: `"rolling out to phones in minutes"`

Y **1 sesión queda esperando una acción física offline**:

- 2026-07-30 · *Stock y conectividad*: `"awaiting go for physical count"`

**Total con dependencia explícita de una acción manual de Julio: 8 de 116 (7%).**

### Pero el costo real es estructural, no esas 8

El dato que importa es otro:

- **80 de 116 sesiones (69%) terminan en `review_ready`.**
- De esas 80, **49 (61%) mencionan explícitamente un deploy/publicación en su resumen**
  (`deployed vNNN`, `merged to main`, `live`, `publicado`, `Cloudflare deploying`,
  `en producción`).

Es decir: **el flujo estándar de Julio es "Claude mergea a producción y Julio prueba en el
celular"**. Los `CLAUDE.md` lo institucionalizan; el de pruevacero lo dice sin vueltas:

> "Julio **no es programador** y prueba SOLO en la app publicada. […] merge a `main` →
> push (publicar sin preguntar). […] Verificar el deploy en vivo (curl al sitio buscando un
> string nuevo)."

**Cuantificación del costo**: cada una de esas ~49 sesiones publica directo a producción
y transfiere la validación a un humano en un celular. No hay staging ni preview. El
`CLAUDE.md` de ArborRisk y el de pruevacero ya compensan esto con **verificación
automatizada** (chequeo de sintaxis JS + chromium headless + `curl` al sitio buscando un
string nuevo) — pero **sólo 2 de los 4 repos chicos tienen esa sección** (gastoscasa la
tiene parcial, webpodaenaltura no la tiene).

**No aparece** en los datos un patrón de "ida y vuelta largo": ninguna sesión muestra 3+
ciclos de "probá / no anda / probá de nuevo" en su resumen. Lo que hay es **un handoff de
una sola vía**: se publica y se cierra. El riesgo no es el loop, es que **si algo se rompe
en producción, nadie se entera hasta que Julio lo usa**.

## 5.d Familias de tareas repetidas (asignación exclusiva, 116/116)

Cada sesión asignada a **exactamente una** familia primaria (sin duplicados ni faltantes;
verificado por script en `work/fams.py`):

| n | Familia | Ejemplos |
| ---: | --- | --- |
| **18** | Features de app (CRUD, flujos, bugs funcionales) | Notas especiales, Anotaciones en edición, Funciones para mejorar la app, bug del lápiz |
| **16** | Diseño, UI, estilos y rediseños visuales | DaisyUI design review, App emoji replacement plan, Light theme UI, Fase 1 rediseño del editor, Design: × 2 |
| **13** | **Auditorías y revisiones sistemáticas** | App security audit, PruebaCero quality audit, Styles and themes audit, Event logs audit, Budget app pre-launch audit × 2, Test coverage analysis, StockMerger security audit, Auditoría de seguridad y desarrollo web |
| **10** | Deploy / infra / Cloudflare / GitHub / optimización de repo | Cloudflare Workers token setup, ArborRisk GitHub deployment × 2, CDN versions and SRI hashes × 2, Diseño Claude y conexión de dominio |
| **9** | PDF / impresión / exportes visuales | PDF design options, Flecha y círculo impresos en PDF, Numeración plan de trabajo, Dark theme print bar bug, Fotos deformadas |
| **9** | Stock e inventario (StockMerger/StockVendedor) | exchange rate sync, Multi-currency treasury, Stock sorting and Excel exports |
| **9** | Meta-trabajo: skills, `CLAUDE.md`, tokens, planificación | Token-saving system setup, Claude skills setup/directory, Neon for future projects, Recommended skills |
| **7** | Contenido y marketing web (cursos, textos, SEO) | Syllabus Nivel 1, Requisitos de Vicky, Posicionamiento en Google, Testimonios de Victoria |
| **6** | Calendario / agenda / scheduling | Calendar phase 2/3, Error de conexión Google Calendar, Multi-day job scheduling |
| **4** | Notificaciones, banners y recordatorios | Budget expiration notifications, Historial de notificaciones |
| **4** | Mapas, ubicación y GPS | Budget locations map, Google Maps Plus Code, Map marker view |
| **4** | Backup, sync y comportamiento offline | Automatic backup to Drive, ArborRisk backup and real-time sync, Offline-first behavior |
| **3** | WhatsApp / compartir / Share Target | WhatsApp button, Share Target implementation, Zavu.dev |
| **2** | Accesos y seguridad multiusuario (implementación) | Per-person access management, Server cybersecurity options |
| **2** | Sin contenido (sesión vacía / dispatch) | New session, Dispatch background conversation |
| **116** | **TOTAL** | |

### Sub-conteo de las auditorías (el pedido explícito del encargo)

Dentro de las 13, por objeto auditado:

| Objeto de la auditoría | n | Sesiones |
| --- | ---: | --- |
| Seguridad | 3 | App security audit (07-14), StockMerger/StockVendedor security audit (06-18), Auditoría de seguridad y desarrollo web (08-09) |
| Calidad / QA general | 4 | PruebaCero quality audit, App audit and improvement plan, Budget app pre-launch audit × 2 |
| Estilos / diseño | 2 | Styles and themes audit, App scannability design review |
| Logs / eventos | 1 | Event logs audit |
| Cobertura de tests | 1 | Test coverage analysis |
| Inventario / datos | 1 | Stock y conectividad: banco de pruebas |
| Meta (crear el prompt de auditoría) | 1 | **App audit prompt** → produjo `docs/prompt-auditoria.md` |

**Señal fortísima para una skill**: el 2026-07-14 Julio ya hizo la sesión
*"App audit prompt"*, cuyo resultado fue *"audit prompt created at
`docs/prompt-auditoria.md`, committed to main"* — es decir, **ya intentó a mano lo que una
skill resuelve**, y ese prompt vive en un solo repo (presupuesto-ar) donde los otros 8 no
lo ven.

### Otras familias con masa crítica para skill

- **Deploy Cloudflare + estampado del SW (10 sesiones)**: los 4 repos chicos ya tienen el
  mismo `build.py` + `.github/workflows/stamp-sw.yml` + `.assetsignore` + `wrangler.jsonc`,
  documentado por separado y con texto casi idéntico en cada `CLAUDE.md`. Es la receta más
  copiada del historial.
- **PDF / impresión (9 sesiones)**: repetidamente los mismos problemas (elementos flotantes
  que se imprimen, `color-scheme` en dark theme, proporciones de `html2canvas`, numeración).
- **Diseño/UI (16)** y **Features (18)** son demasiado heterogéneas para una sola skill,
  pero la sub-familia "verificación headless de un cambio visual" atraviesa las dos.
- **Meta-trabajo (9)**: 4 de esas 9 son intentos de crear/registrar skills o sistemas de
  ahorro de tokens (06-09, 06-10 × 2, 06-13). Uno guardó la skill en
  `~/.claude/skills/desarrollo-apps/SKILL.md` — **fuera de cualquier repo, o sea perdida**.

## 5.e Sesiones fallidas

**4 de 116 (3,4%)** con `status_category = failed`, en dos sabores:

| Fecha | Sesión | Repos | Motivo | Duración |
| --- | --- | --- | --- | ---: |
| 2026-06-06 17:25 | PRESUPUESTO APP | presupuesto-ar | `You've hit your session limit · resets 12:40am (UTC)` | 28,6 h |
| 2026-06-08 20:07 | Budget app pre-launch audit | presupuesto-ar | `[ede_diagnostic] result_type=user last_content_type=n/a stop_reason=tool_use` | 47 s |
| 2026-06-09 04:18 | ArborRisk GitHub and Cloudflare deployment | ArborRisk | `[ede_diagnostic] result_type=user last_content_type=n/a stop_reason=tool_use` | 1 m 12 s |
| 2026-06-09 (fecha del TSV) | CDN versions and SRI hashes | stockmerger, stockvendedor | `You've hit your session limit · resets 2:40am (UTC)` | n/d |

Observaciones:

- **2 son límite de sesión** (06-06 y 06-09), ambas en la ventana de arranque intensivo
  (semana W24, 26 sesiones). Ambas se rehicieron después: `CDN versions and SRI hashes` se
  repitió al día siguiente y terminó `review_ready`; `PRESUPUESTO APP` fue seguida por
  `Frequent login prompts and offline support`.
- **2 son crashes técnicos** (`ede_diagnostic … stop_reason=tool_use`), ambos con menos de
  90 segundos de vida, y **ambos relanzados de inmediato en una sesión gemela** (a los 61 s
  y a los 3 min 43 s respectivamente). Ninguna de las dos dejó un commit.
- Las 4 fallas son de junio. **Ninguna en julio ni agosto** — el problema se resolvió solo.

---

# Resumen de correcciones a las premisas del encargo

| Premisa del encargo | Verificado | Realidad |
| --- | --- | --- |
| pruevacero: 8 ramas, sólo 2 mergeadas, la peor tasa | ❌ | 7 de 7 ramas `claude/*` mergeadas. Es el mejor de los cuatro. |
| ArborRisk: 4 ramas `claude/*`, 2 mergeadas | ~ | 3 ramas `claude/*`, 1 mergeada, 2 sin mergear con +3 commits |
| gastoscasa: 3 ramas, 2 mergeadas | ~ | 3 ramas (2 `claude/*` + `main`), 1 mergeada, 1 sin mergear con **+6 commits y ~694 líneas** |
| webpodaenaltura: 2 commits | ✅ | 2 commits, y **sin rama `main`** |
| "todas las sesiones tienen `origin: android`" | ❌ | 112 android, 2 `desktop_app`, 2 sin origen |
| "el TSV completo son 115 sesiones" | ~ | 116 en la API (la 116ª es la sesión de auditoría en curso) |
| "hay sesiones de 43M, 44M y 54M de cache read" | ✅ | 54,4 M / 44,4 M / 43,4 M — exacto |
| "hay al menos una sesión con session limit" | ✅ | 2 con session limit + 2 con crash técnico = 4 `failed` |
