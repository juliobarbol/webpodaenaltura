# Hallazgos — grupo **stockmerger + stockvendedor**

Auditoría del uso de Claude Code de Julio Barrientos.
Fecha del análisis: 2026-08-10.

## Alcance y datos usados

| Fuente | Qué aporta |
| --- | --- |
| `sesiones-todas.tsv` | 86 sesiones, 2026-05-18 → 2026-07-24. **24** tocan algún repo de stock. |
| `pagina1-sesiones.tsv` | 30 sesiones recientes (hasta 2026-08-02). **5** más tocan stock, con datos de tokens. |
| `/workspace/juliobarbol/stockmerger` | 171 commits, 19 ramas `claude/*`, 30 merges. |
| `/workspace/juliobarbol/stockvendedor` | 130 commits, 17 ramas `claude/*`, 22 merges. |

**Total del grupo: 29 sesiones.** Dato clave para todo lo que sigue: **las 29
tocan LOS DOS repos. No hay ni una sola sesión que abra un repo solo.**
(`awk -F'\t' '$3 ~ /stock/'` sobre ambos TSV: los valores de la columna `repos`
son siempre `stockmerger,stockvendedor` o esa pareja dentro de una lista mayor.)

Limitación honesta: sólo 8 de 86 filas de `sesiones-todas.tsv` traen
`out_tokens`/`cache_read`, y ninguna de ellas es del grupo stock. Los únicos
números de tokens del grupo vienen de `pagina1-sesiones.tsv` (3 sesiones).

Ruido descontado en todos los conteos de commits: los `chore: estampar versión
del cache del SW [skip stamp]` que genera el CI (**53 de 171** en stockmerger,
**43 de 130** en stockvendedor — el 31% y el 33% del historial). Commits "reales":
**88** en stockmerger y **65** en stockvendedor.

---

## 1. Coordinación entre los dos repos

### 1.1 Los nombres de rama SÍ están apareados; el estado de merge NO

Las ramas se crean con el mismo sufijo en ambos repos (misma sesión, mismo
nombre). 17 de los 19 nombres de stockmerger existen también en stockvendedor.
Sólo dos son exclusivas de stockmerger: `automatic-backup-drive-OItcn` y
`odoo-functions-analysis-18zc1k`.

Pero el estado de merge **no coincide**:

| Rama | stockmerger | stockvendedor |
| --- | --- | --- |
| `claude/app-analysis-chat-access-ZtPqs` | sin mergear (+3) | sin mergear (+3) |
| `claude/person-access-management-banhlv` | sin mergear (+1) | sin mergear (+1) |
| `claude/odoo-functions-analysis-18zc1k` | **sin mergear (+1)** | no existe |
| `claude/stockmerger-memory-window-c50qde` | mergeada | **sin mergear (+1)** |
| `claude/ui-redesign-chrome-native-mioiz6` | mergeada | **sin mergear (+1)** |

**Dos ramas con el mismo nombre terminaron mergeadas en un repo y colgadas en el
otro** (`stockmerger-memory-window-c50qde`, 2026-06-11; `ui-redesign-chrome-native-mioiz6`,
2026-06-21). Ése es exactamente el desfasaje que se sospechaba.

### 1.2 Pero el desfasaje casi nunca costó trabajo perdido — con UNA excepción

Verifiqué el contenido de las 5 ramas colgadas una por una:

- `app-analysis-chat-access-ZtPqs` (ambos repos): sus 3 commits entraron a `main`
  vía squash del PR #1 (`35bf619` / `c153b2b`, 2026-06-07). Rama huérfana, sin pérdida.
- `person-access-management-banhlv` (ambos repos): `git patch-id --stable` da
  **el mismo hash** para el commit de la rama y el de `main`
  (merger `8a22f48` ≡ `09e6b83` → `d836658e…`; vendedor `f9ecaf3` ≡ `e341bf4` → `0cd292b8…`).
  El trabajo se rehízo directo sobre `main` el mismo día. Sin pérdida, pero sí retrabajo (ver §3).
- `stockmerger-memory-window-c50qde` (vendedor): sólo un merge y un estampado de `sw.js`. Sin pérdida.
- `ui-redesign-chrome-native-mioiz6` (vendedor): trae `c92e5f4` *"fix: evitar crash al abrir
  (enhanceAllSelects recibía el Event de DOMContentLoaded)"*. **El fix sí está en `main`**
  (`index.html:5772` tiene `DOMContentLoaded', () => enhanceAllSelects())`), commiteado
  aparte como `5488d24`. Sin pérdida; rama abandonada a mitad de vuelo.
- **`odoo-functions-analysis-18zc1k` (stockmerger): PÉRDIDA REAL.**

### 1.3 Trabajo perdido: `f5b7cf2` nunca llegó a producción

```
f5b7cf2  2026-06-18  "Reposición de stock y antigüedad de la deuda"
         rama claude/odoo-functions-analysis-18zc1k  ·  +126 / -14 en index.html
         sesión: session_01KuEQrudZGatfLWcWPcj8Du
```

Contiene dos funcionalidades completas: cuántas unidades comprar para volver al
mínimo de alerta (con columna nueva en el Excel de alertas) y el *aging* de
cuenta corriente (`_clientAging()`, tramos 0-30/31-60/61-90/+90 con FIFO,
resumen en "Dinero en calle", columnas por tramo en el Excel y desglose en el PDF).

Verificado ausente de `main` hoy, 8 semanas después:

```
_clientAging      en main: 0 ocurrencias
Reponer (uds.)    en main: 0
Más vieja (días)  en main: 0
repoLine          en main: 0
```

La sesión que lo generó figura en el índice como **`2026-06-16 | Odoo functions
analysis | stockmerger,stockvendedor | COMPLETED | review_ready`**, y su mensaje
final es: *"answered: can work on other branches while changes are saved
elsewhere"*. O sea: la sesión cerró tranquilizando a Julio sobre trabajar en otras
ramas, y esa rama se quedó ahí. Es el único caso de trabajo real enterrado del grupo.

### 1.4 Lo que NO pasó (y conviene decirlo)

- **El contrato de datos compartido nunca divergió.** Comparé la función
  `normalize()` de ambos `index.html` en 6 cortes (2026-06-09, 06-13, 06-21,
  06-22, 07-30, 08-01): **idéntica en los seis**. La `KEY_VECTORS` de los dos
  `pruebas.html` también es idéntica hoy.
- **`schema.sql` nunca quedó desincronizado a fin de día.** Mismos 6 cortes,
  0 líneas de diferencia en todos. Hoy es byte-idéntico. Sí hubo un desfasaje
  *intradía* el 2026-08-01 (merger `5000eaa` metió el trigger de auditoría y el
  vendedor tuvo que emparejar con un commit aparte, `df6a12a`, literalmente
  titulado *"Sincronizar schema.sql y decisiones"*).
- El miedo grande ("las apps se rompen porque el contrato divergió") **no se
  materializó**. Lo que sí se desincroniza es la UI y la higiene de ramas.

### 1.5 Desbalance de commits por sesión

Los commits llevan trailer `Claude-Session:` desde el 2026-06-18 (34 de 88 en
merger, 27 de 65 en vendedor — el 39% y el 42%). Con eso se puede aparear:

| Sesión | merger | vendedor | |
| --- | --- | --- | --- |
| `session_012WVrcGx1kSi4AVnA` (06-18/19, seguridad) | 8 | 6 | desbalance |
| `session_019epUDLTUEhVAZot6` (06-21, rediseño UI) | 9 | 5 | desbalance |
| `session_01DF2AW2i57br3Rg66` (07-30) | 3 | 1 | desbalance |
| `session_01142Bng2qpZTmbBwP` (06-21) | 1 | 2 | desbalance |
| `session_0195rCAav3PPyKacCT` (06-21, dólar blue) | 2 | 2 (**sólo docs**) | desbalance real |
| `session_01K799yr9Q5vt4c7h4` (06-21, bitácora) | 5 | 5 | ok |
| `session_01THYsPcab1Ghk2ZH6` (06-22, fichas) | 3 | 3 | ok |
| `session_01VBbxvSSdEJEKrr88` (07-30/08-01, pruebas) | 3 | 3 | ok |

**5 de 8 sesiones cierran con distinto volumen en cada repo.** Buena parte es
legítima (Caja, PDF y tesorería son sólo de la central). El caso claro de
desfasaje es `session_019epUDLTUEhVAZot6`: la central se llevó `appPrompt`,
el diálogo de contraseñas, el selector de cliente y tres arreglos de tablas; el
vendedor sólo el tema y el desplegable. Resultado en §1.6.

### 1.6 El pendiente de sincronización lleva 7 semanas abierto

`stockvendedor/CLAUDE.md:388-392` dice, desde el 2026-06-21 (commit `6aea5bc`):

> **PENDIENTE / a sincronizar con StockMerger**: portar `appPrompt` (cuadro de
> texto propio) para los `prompt()` de contraseña que SIGUEN NATIVOS acá (gran
> reset y conexión, `sbUnlockConfig`/`authGateConfig`) […] Falta confirmación de Julio.

Estado hoy (último commit del repo: 2026-08-01):

```
appPrompt en stockvendedor: 2 ocurrencias, ambas en CLAUDE.md — cero en index.html
prompt() nativos vivos:  index.html:2504, 2710, 2898
```

Nunca se portó. **51 días** con la nota escrita en el archivo que Claude lee
primero en cada sesión, y ninguna de las sesiones posteriores (06-22, 07-30,
08-01, 08-02) lo levantó.

---

## 2. Duplicación entre los dos `CLAUDE.md`

### 2.1 Números

- stockmerger: **575 líneas**. stockvendedor: **442 líneas**.
- Líneas **byte-idénticas** tras normalizar espacios (bloques comunes de
  `difflib.SequenceMatcher`): **245** → **42,5% del CLAUDE.md de merger** y
  **55,3% del de vendedor**.
- Sólo en bloques contiguos de ≥4 líneas: **199 líneas** (34,5% / 44,9%).
- Similitud global a nivel caracteres: **0,84**.
- Por secciones (49% de las líneas de merger viven en secciones con similitud ≥0,60):

| Sección | merger | vendedor | similitud |
| --- | ---: | ---: | ---: |
| Forma del proyecto | 9 | 9 | **0,96** |
| Deploy y versión del cache (PWA) | 17 | 18 | **0,96** |
| Contrato de datos compartido | 16 | 17 | **0,88** |
| Cómo se conectan las dos apps | 29 | 28 | **0,85** |
| Decisiones de producto (de Julio) | 105 | 90 | **0,78** |
| ⚠️ Trabajar sin quemar tokens | 21 | 19 | **0,77** |
| Acceso por persona (Auth + RLS) | 54 | 60 | 0,65 |
| Conexión con la nube (Supabase) | 35 | 26 | 0,63 |

Los bloques idénticos más largos: `m148-175 / v119-146` (28 líneas, el párrafo
entero del captcha Turnstile), `m352-374 / v316-338` (23 líneas, la bitácora
antifraude **copiada literal en el repo del vendedor aunque el propio texto de
merger diga "StockVendedor no cambió (los vendedores no tocan dinero)"**),
`m264-285 / v243-264` (22 líneas, el contrato `vendor_data_v2`).

### 2.2 La sección duplicada trae su propia instrucción de sincronización manual

Idéntica en los dos archivos (merger:269, vendedor:248):

> ⚠️ **Mantener al día**: si Julio cambia alguna de estas reglas, hay que EDITAR
> esta sección en los CLAUDE.md de **ambos repos** en el mismo cambio.

Eso es una tarea manual recurrente escrita a mano en el propio artefacto que la
causa. Es el candidato número uno a archivo compartido.

### 2.3 La duplicación no es sólo del CLAUDE.md: 1.807 líneas byte-idénticas

15 archivos con el mismo blob de git en los dos repos:

```
.claude/settings.json                                8
.claude/skills/flujo-stock/SKILL.md                 98
.claude/skills/webapp-testing/*                    506   (LICENSE + SKILL + 3 ejemplos + script)
.claude/skills/workers-best-practices/*            764   (SKILL + review.md + rules.md)
.github/workflows/stamp-sw.yml                      39
.gitignore                                           2
build.py                                            45
schema.sql                                         345
                                              ────────
                                    TOTAL: 1.807 líneas × 2 copias
```

Dos observaciones sobre eso:

- **`workers-best-practices` (764 líneas × 2 = 1.528) no aplica a estos repos.**
  Los dos `wrangler.jsonc` son `{"assets": {"directory": "."}}` sin `main`: no
  hay código de Worker. Es guía sobre streaming, promesas flotantes en el
  runtime, bindings y observabilidad de Workers, para dos sitios estáticos.
- **`webapp-testing` (506 × 2) es una skill que ya viene con el harness.** Se
  vendorizó igual. Ambas entraron el 2026-06-13 (`df3e167` / `19ffab1`), en la
  sesión **`2026-06-13 | Claude skills setup`**, cuyo cierre fue *"evaluated 2
  skills for app development practicality"*.

### 2.4 El mapa de navegación —la razón de ser del CLAUDE.md— está roto

La sección `⚠️ Trabajar sin quemar tokens — LEER PRIMERO` manda saltar a rangos
de línea en lugar de leer el `index.html` entero. Comparé los rangos declarados
contra los banners `// XXX.JS` reales:

**stockmerger: 22 de 22 módulos desfasados. Desvío promedio 749 líneas, máximo 1.835.**

| módulo | declarado | real | desvío |
| --- | ---: | ---: | ---: |
| STORE.JS | 3466 | 3683 | +217 |
| UI.JS | 5723 | 6000 | +277 |
| SUPABASE.JS | 9395 | 9858 | +463 |
| REALTIME.JS | 9890 | 10968 | **+1.078** |
| ORDERS_UI.JS | 10672 | 11877 | +1.205 |
| DOCS.JS | 11289 | 12572 | +1.283 |
| CAJA.JS | 13105 | 14444 | +1.339 |
| BOOT.JS | 13830 | 15665 | **+1.835** |

**stockvendedor: 10 de 10 desfasados. Promedio 593, máximo 1.045** (UI.JS declarado
4411, real 5456).

Además la tabla es internamente incoherente: `LOG.JS` figura como 10412–10631 y
`ORDERS.JS` como 10004–10671 — **rangos que se pisan**. Y `LOG.JS` está listado
antes que `REALTIME.JS` (9890) con número mayor.

Y los tamaños declarados tampoco son ciertos:

| | CLAUDE.md dice | real |
| --- | --- | --- |
| merger `index.html` | "~12k líneas" (§Forma) / "~13.900 líneas, 558 KB" (§tokens) | **15.738 líneas, 665 KB** |
| vendedor `index.html` | "~5.220 líneas, 197 KB" | **6.419 líneas, 258 KB** |

(El propio CLAUDE.md de merger se contradice a sí mismo: 12k vs 13.900.)

Consecuencia práctica: el mecanismo de ahorro de tokens manda a Claude a leer el
tramo equivocado, encontrar otra cosa, y volver a buscar con `Grep`. Es peor que
no tener tabla. Los únicos datos de tokens que tengo del grupo son consistentes
con eso: `2026-07-30 | Stock no carga para Santiago` → `cache_read = 10.708.559`;
`2026-07-30 | Stock y conectividad: banco de pruebas` → `8.972.430`;
`2026-08-02 | Movimientos últimos 4 días` → `680.867`. **~20,4 M de cache read en
3 sesiones.** El `index.html` de merger son ~166k tokens: 10,7 M equivalen a
~64 relecturas completas del archivo.

### 2.5 Notas obsoletas que sobrevivieron

- `stockvendedor/CLAUDE.md:428-429`: *"`.assetsignore` excluye […] `README.md`
  (ojo: el readme real se llama `READE.md`, así que hoy no queda excluido)"*.
  El archivo se renombró a `README.md` el **2026-06-09** (`ea51c88`, registrado
  como resuelto en `AUDITORIA.md`). La nota lleva **8 semanas mintiendo**.
- `AUDITORIA.md` reconoce el problema de fondo en su propio encabezado: *"Los
  números de línea son de la fecha de la auditoría; si no cuadran, reubicar con
  `Grep`"*. Es la solución correcta, aplicada al archivo equivocado: el
  `CLAUDE.md` sigue prometiendo rangos exactos.

---

## 3. Retrabajo

### 3.1 Por mensaje de commit, el retrabajo es BAJO

Commits de reparación explícita (`fix:`, "arreglar", "ya no sale", "evitar crash"):
**5 de 88 en merger (5%)** y **5 de 65 en vendedor (7%)**. No hay un patrón de
"arreglar el arreglo" masivo. Hay que decirlo: por esta métrica el grupo está sano.

### 3.2 Donde sí hay retrabajo es en las pasadas múltiples del mismo día

**a) Login por persona — trabajo tirado y rehecho (2026-06-13).**
La rama `person-access-management-banhlv` implementó "login por usuario en la
sección de conexión" (60 líneas en cada repo). El mismo día se abandonó la rama
y se rehízo el mismo parche directo sobre `main` (patch-id idéntico, §1.2), y
además se lo reemplazó por un enfoque distinto: `3e89bd7` / `4e83aa0`
*"feat: pantalla de login obligatoria al abrir la app"*. Dos diseños, mismo día,
uno descartado.

**b) Desplegable propio del vendedor — tres pasadas, la tercera es un crash en producción (2026-06-21).**
```
8c40a72  "A (piloto): desplegable propio reemplaza el <select> nativo en orden/agrupar de Stock"
fcafc1c  "A: desplegable propio robusto (lista flotante) en todos los <select> del Vendedor"
5488d24  "fix: evitar crash al abrir (enhanceAllSelects recibía el Event de DOMContentLoaded)"
```
El bug: se pasó `enhanceAllSelects` como handler de `DOMContentLoaded`, así que
`root` llegaba siendo el `Event` y `root.querySelectorAll` explotaba. Como la app
es un `index.html` monolítico, **un error de JS deja la pantalla en blanco para
todos** — riesgo que el propio `flujo-stock/SKILL.md` advierte. Se publicó y se
arregló después.

**c) Scroll horizontal en la central — tres commits para el mismo síntoma (2026-06-21).**
```
2632e40  "Caja: envolver cada tabla de reportes en recuadro deslizable (arregla scroll que corría la página…)"
5640bf2  "Limpieza UI: tablas de Caja contenidas + detalle de Pedidos sin desbordar la página"
3a30858  "Precios: tabla por rubro scrollea horizontal dentro de su tarjeta (no corre la página)"
```

**d) Banco de pruebas — arreglado el mismo día que nació (2026-07-30).**
`f7fab85`/`8b4ac6d` crean el banco; `b81ca02` *"el chequeo del rol ya no sale en
amarillo"* y `54e5d9f` *"que las pruebas de confirmar se puedan correr más de una
vez"* lo corrigen horas después.

**e) Bugs de producción que salieron a la luz semanas después.**
- `900ee72` (2026-07-30) *"Un pedido = un id en todos los dispositivos de la central"*:
  cada equipo le ponía `localId` al azar al mismo pedido → duplicados en
  `received_orders`. El cuerpo del commit dice: *"se vieron 6 pedidos duplicados,
  uno con 3 copias"*. Datos reales afectados.
- `f955a84` (2026-07-30) *"Arreglar el texto ilegible del resumen de cuenta corriente
  en PDF"*: jsPDF sólo dibuja WinAnsi; un `≈` rompía la codificación de toda la
  línea. Venía del trabajo del 2026-06-22.

### 3.3 El 2026-06-21: 84 commits, 24 merges, 27 deploys en un día

| | commits | merges | estampados (= pushes a `main`) |
| --- | ---: | ---: | ---: |
| stockmerger | 47 | 14 | 15 |
| stockvendedor | 37 | 10 | 12 |

Cada estampado es un push a `main` → workflow → deploy de Cloudflare → Julio
mirando el teléfono. **27 ciclos de publicación en un día**, repartidos en 4-5
sesiones.

Esto contradice una regla que ya estaba escrita desde el 2026-06-10 en
`flujo-stock/SKILL.md` (`46d8c94`):

> Si Julio pide varios cambios en un mensaje, implementalos TODOS y publicalos en
> una sola tanda (un solo ciclo de commit + merge + verificación), no un ciclo por cambio.
> […] verificá el estampado UNA SOLA VEZ, después del último merge.

La regla existe, es correcta y **no se cumplió**: `session_019epUDLTUEhVAZot6`
produjo 9 commits de merger repartidos en 7 merges separados.

---

## 4. Ramas abandonadas

`git branch -r --no-merged HEAD | grep claude/`:

**stockmerger (3 de 19 = 16%)**

| Rama | Adelanto | Última | Sesión que la generó | Contenido |
| --- | --- | --- | --- | --- |
| `claude/app-analysis-chat-access-ZtPqs` | +3 | 2026-06-07 | `2026-06-07 STOCK V Y M` | ya en main vía squash PR #1 |
| `claude/person-access-management-banhlv` | +1 | 2026-06-13 | `2026-06-12 Per-person access management` | patch-id idéntico a main |
| `claude/odoo-functions-analysis-18zc1k` | +1 | 2026-06-18 | `2026-06-16 Odoo functions analysis` | **126 líneas perdidas** |

**stockvendedor (4 de 17 = 24%)**

| Rama | Adelanto | Última | Sesión | Contenido |
| --- | --- | --- | --- | --- |
| `claude/app-analysis-chat-access-ZtPqs` | +3 | 2026-06-07 | `STOCK V Y M` | ya en main |
| `claude/person-access-management-banhlv` | +1 | 2026-06-13 | `Per-person access management` | patch-id idéntico a main |
| `claude/stockmerger-memory-window-c50qde` | +1 | 2026-06-11 | `2026-06-10 Stockmerger memory window minimization` | sólo merge + estampado |
| `claude/ui-redesign-chrome-native-mioiz6` | +1 | 2026-06-21 | `2026-06-21 UI redesign native Chrome components` | el fix ya está en main |

Ninguna rama `claude/*` se borra nunca después de mergear: quedan las 19 y las 17
enteras en `origin`. El ruido hace que `--no-merged` sea la única forma de saber
qué pasó, y ahí es donde `odoo-functions-analysis-18zc1k` se camufló entre falsos
positivos durante 8 semanas.

---

## 5. Loops de verificación manual

Julio trabaja **sólo desde Android** y no puede correr nada local. El
`flujo-stock/SKILL.md` lo dice explícitamente y convierte eso en procedimiento:

> Julio **no es programador** y **no tiene entorno de pruebas**: la única forma
> que tiene de probar algo es abrir las apps ya publicadas en su teléfono.
> […] Decile a Julio qué mirar en la app publicada para confirmar que el cambio
> funciona (1 o 2 pasos concretos). **Es la única prueba real que existe.**

Sesiones del grupo que terminan en ese loop — **6 de 24 (25%)** en `sesiones-todas.tsv`:

| Fecha | Sesión | Cierre |
| --- | --- | --- |
| 2026-06-07 | STOCK V Y M | *"¿Querés que verifique si el deploy corrió bien?"* (`need_input`) |
| 2026-06-08 | Automatic backup to Drive | *"backup system live; stockmerger merged, Cloudflare deploying"* |
| 2026-06-09 | App audit and improvement plan | *"¿Ya pudiste correrlo?"* (`need_input`) |
| 2026-06-11 | Multi-currency treasury | *"verified both apps live and serving latest version"* |
| 2026-06-12 | Per-person access management | *"waiting for deploy to phones (~5 min)"* |
| 2026-06-21 | StockMerger exchange rate sync | *"rolling out to phones in minutes"* |

Más el pendiente permanente en los dos `CLAUDE.md`:
`merger:472` *"Falta que Julio confirme los desplegables en ventanas/modales y dinámicos"*
y `vendedor:392` *"Falta confirmación de Julio"* — abiertos desde el 2026-06-21.

**El loop ya tiene solución construida y funciona.** El 2026-07-30
(`session_01VBbxvSSdEJEKrr88`) se creó `pruebas.html` en los dos repos: 1.014
líneas en merger, banco de diagnóstico + **15 pruebas automáticas** (13 en el
vendedor) que cargan la app real en un iframe con `localStorage`/`indexedDB`
falsos. Julio lo abre desde el celular en `/pruebas.html` y ve 16/16 o 13/13.
Es exactamente la automatización que faltaba, y llegó 7 semanas tarde.

Lo que falta: **el `flujo-stock/SKILL.md` no lo menciona**. Su procedimiento de
cierre sigue siendo "decile a Julio qué mirar", escrito el 2026-06-10 y sin
tocar desde entonces (`git log -- .claude/skills/flujo-stock/SKILL.md` → 2 commits,
ambos del 2026-06-10). La skill sigue mandando el flujo viejo.

Segundo loop, menos visible: la verificación del estampado del `sw.js`. La skill
manda `git pull` y chequear `const CACHE`, con espera de ~2 minutos y fallback a
`python build.py`. Con 27 publicaciones en un día (§3.3) eso son 27 esperas.

---

## 6. Decisiones colgadas

Descarto las cortesías (*"¿Querés que repasemos algo?"*, *"¿seguimos con otra
cosa?"*, *"¿lo dejamos acá por hoy?"*). Quedan **4 decisiones reales**:

1. **Neon como base para proyectos futuros** — `2026-07-15 | Neon for future
   projects | presupuesto-ar,pruevacero,stockvendedor,stockmerger,ArborRisk |
   COMPLETED/need_input`. Cierre literal: *"¿Querés que te lo deje anotado en
   algún `CLAUDE.md` como decisión tomada, para no volver a evaluarlo cada vez?"*
   **Nunca se anotó**: `grep -ri neon` en los dos repos no devuelve ni una
   mención en `CLAUDE.md` (el único hit es una palabra suelta en `index.html`).
   La sesión previó exactamente su propio fracaso: se va a volver a evaluar.

2. **Rotar la anon key de Supabase** — `2026-06-18 | StockMerger/StockVendedor
   security audit`, cierre: *"¿Querés que dejemos acá por hoy, o seguimos con lo
   último que queda (lo opcional de cambiar la clave pública)?"*. Sigue abierto
   en `AUDITORIA.md:122`, `:131` y `:289`: *"Opcional pendiente: rotar la anon key
   (limpieza de legado); obliga a re-pegar la key en cada teléfono"*. Nota: desde
   la conexión de fábrica del 2026-07-30 (`SB_DEFAULT_KEY` hardcodeada) el costo
   de rotarla **bajó** — ya no hay que re-pegar nada a mano, alcanza con publicar.
   La decisión quedó congelada con premisas que ya no son ciertas.

3. **Portar `appPrompt` al vendedor** — ver §1.6. 51 días.

4. **Conteo físico de stock** — `2026-07-30 | Stock y conectividad: banco de
   pruebas`, columna `pendiente`: *"esperando OK para conteo físico"*. Es la
   única forma de detectar el hueco que la bitácora antifraude no cubre
   (`stockmerger/CLAUDE.md:389-391`: *"si alguien entrega mercadería y cobra sin
   registrar nada en la app, no hay evento — eso se detecta por faltante de stock"*).

Además hay un pendiente **con fecha de vencimiento** que conviene no perder:
`CLAUDE.md` de ambos repos, *"Aviso a los usuarios — PENDIENTE (a partir de
~septiembre 2026, tras 1 mes de uso real)"*: avisar en la app que los movimientos
quedan registrados. Es **el mes que viene** y sólo vive como bullet en un archivo
de 575 líneas.

---

## 7. Temas repetidos → candidatos a skill

### 7.1 Auditoría (el más fuerte)

En todo el índice hay **9 sesiones de auditoría**, 5 de ellas del grupo stock:

```
2026-06-08  Budget app pre-launch audit        presupuesto-ar        COMPLETED
2026-06-08  Budget app pre-launch audit        presupuesto-ar        FAILED   ← repetida
2026-06-08  Styles and themes audit            presupuesto-ar
2026-06-09  App audit and improvement plan     stock ×2
2026-06-11  Server cybersecurity options       stock ×2
2026-06-18  StockMerger/StockVendedor security audit   stock ×2
2026-06-21  Event logs audit                   stock ×2
2026-07-13  PruebaCero quality audit           pruevacero
2026-07-14  App security audit                 presupuesto-ar
2026-07-14  App audit prompt                   presupuesto-ar        ← Julio armando el prompt a mano
```

El 2026-07-14 Julio tuvo una sesión entera titulada **"App audit prompt"**: estaba
reconstruyendo a mano el prompt de auditoría que ya había usado 5 veces. Eso es
una skill que falta, textual.

El producto de esas sesiones (`AUDITORIA.md`, 299 líneas: hallazgos numerados
C1-C4 / A1-A8 / M1-M9, tabla de estado, sección de falsos positivos verificados,
plan por fases) es **excelente** y se mantuvo al día durante 10 commits. Ese
formato es lo que la skill debería reproducir.

### 7.2 Otros temas repetidos

- **Backups**: `2026-06-08 Automatic backup to Drive` (stock) y `2026-06-20
  ArborRisk backup and real-time sync` (ArborRisk + presupuesto-ar + stockmerger,
  `BLOCKED`). Dos veces el mismo problema en repos distintos.
- **Ahorro de tokens**: `2026-06-10 Token-saving system setup` (stockmerger +
  ArborRisk, cierre: *"rewritten prompt for token-saving system; ready to use with
  any repo"*), `2026-06-10 Stockmerger memory window minimization` y
  `2026-06-10 Stock sorting…` (cierre: *"explained token-saving system
  replicability across projects"*). **Tres sesiones el mismo día** explicando y
  re-explicando el mismo sistema. El resultado fue precisamente la sección
  "Trabajar sin quemar tokens" que hoy está rota (§2.4).
- **Sesión desperdiciada**: `2026-06-09 | CDN versions and SRI hashes | FAILED`
  → *"You've hit your session limit"*, rehecha al día siguiente con el mismo
  título. Es el único título que se repite en las 24 sesiones del grupo.

---

# Correcciones propuestas para los `CLAUDE.md`

Cada una está justificada por un hallazgo numerado. Redactadas para pegar.

---

## C-1 · Reemplazar el mapa de rangos por una regla que no se pudre

**Justificación**: §2.4 — 22/22 y 10/10 módulos desfasados, promedio 749 y 593
líneas, máximo 1.835. La tabla manda a Claude al lugar equivocado; el único dato
del grupo que tengo sobre tokens es 20,4 M de cache read en 3 sesiones.

**Acción**: en `stockmerger/CLAUDE.md` borrar las tablas de "Mapa de navegación"
y la columna **Líneas** de "Módulos internos"; en `stockvendedor/CLAUDE.md`, ídem.
Dejar la columna **Rol**, que sí es información estable. Reemplazar la sección
`⚠️ Trabajar sin quemar tokens — LEER PRIMERO` por:

```markdown
## ⚠️ Trabajar sin quemar tokens — LEER PRIMERO

`index.html` es un archivo único de ~16k líneas (~665 KB, ≈166k tokens).
**Leerlo entero gasta un contexto completo de una.** Está limpio y modularizado
(líneas cortas, sin minificados ni base64, banners `// XXX.JS`), así que la
lectura por tramos es exacta y barata. Reglas:

1. **NUNCA** hagas `Read` del archivo completo (sin `offset`/`limit`). Tampoco
   `cat`/`sed`/`head` de todo el archivo.
2. **No hay tabla de rangos de línea, a propósito**: se desfasaba cientos de
   líneas en cada release y mandaba a leer el tramo equivocado. Para ubicarte:

   ```
   Grep -n "^// [A-Z_]*\.JS"  index.html      # todos los módulos y su línea de hoy
   Grep -n "nombreDeLaFuncion" index.html      # el símbolo exacto
   ```
   Después `Read` con `offset`/`limit` sólo ese tramo (±30 líneas).
3. Para **editar**: `Grep` el `old_string` único → `Read` sólo esa franja →
   `Edit`. No vuelvas a leer el archivo después de editar (el harness ya valida).
4. **CSS y HTML/markup** (todo lo anterior al primer banner `// XXX.JS`) casi
   nunca hacen falta para lógica de negocio — no los leas salvo trabajo de
   estilos o maquetado.
5. Contrato compartido con la app hermana: `Grep` el símbolo en **ambos** repos
   en vez de abrir los dos `index.html`.
6. **Nunca escribas números de línea en este archivo.** Ni en `AUDITORIA.md`,
   ni en notas de avance. Escribí el nombre del símbolo: `Grep` lo encuentra
   siempre, el número miente en el próximo commit.
```

---

## C-2 · Sacar el contenido compartido a un único archivo y dejar un puntero

**Justificación**: §2.1 — 42,5%/55,3% de líneas idénticas, similitud global 0,84;
la sección "Decisiones de producto" (105/90 líneas, sim. 0,78) trae escrita a
mano su propia instrucción de sincronización manual. §1 — **29 de 29 sesiones
del grupo abren los dos repos**, así que un puntero cruzado siempre resuelve.

**Acción**: crear `stockmerger/SISTEMA.md` con las cuatro secciones que hoy están
duplicadas: *Cómo se conectan las dos apps*, *Contrato de datos compartido*,
*Decisiones de producto (de Julio)* y *Deploy y versión del cache (PWA)*
(≈167 líneas de merger, ≈153 de vendedor). Borrar esas secciones de los dos
`CLAUDE.md` y poner en **ambos**:

```markdown
## Sistema completo (las dos apps)

El contrato de datos entre las apps, las **decisiones de producto de Julio** y
el mecanismo de deploy/cache son **compartidos**: viven en un solo lugar,
`stockmerger/SISTEMA.md`. Leelo antes de tocar catálogo, pedidos, precios,
fichas de clientes, `_key` o el service worker.

- Las sesiones de este sistema **siempre abren los dos repos** (29 de 29 hasta
  hoy), así que ese archivo está disponible aunque estés trabajando del lado
  del vendedor.
- **No copies contenido de `SISTEMA.md` a este archivo.** Si una regla cambia,
  se edita ahí y en ningún otro lado. Cuando hubo dos copias, se
  desincronizaron: mirá la nota del `READE.md` que quedó 8 semanas desactualizada
  en `stockvendedor/CLAUDE.md`.
- En este `CLAUDE.md` va sólo lo **específico de esta app**: su forma, sus
  módulos, sus tablas de Supabase y sus pendientes propios.
```

**Bonus del mismo hallazgo (§2.3)**: borrar `.claude/skills/workers-best-practices/`
de los dos repos (764 líneas × 2). Ninguno de los dos `wrangler.jsonc` define
`main`: son sitios estáticos, no hay código de Worker que auditar. Y
`.claude/skills/webapp-testing/` (506 × 2) ya viene en el harness.

---

## C-3 · Regla de cierre de sesión con los dos repos y las ramas

**Justificación**: §1.1 — dos ramas con el mismo nombre mergeadas en un repo y
colgadas en el otro. §1.3 — `f5b7cf2` (126 líneas: reposición de stock + aging de
deuda) lleva 8 semanas sin llegar a producción, en una sesión que cerró como
`COMPLETED / review_ready`. §4 — 3/19 y 4/17 ramas sin mergear, y las mergeadas
tampoco se borran, así que el ruido tapa el caso real.

**Acción**: agregar a `.claude/skills/flujo-stock/SKILL.md` (el mismo texto en
los dos repos, o mejor: dejar la skill sólo en stockmerger cuando se aplique C-2):

```markdown
## Cierre de sesión — obligatorio en LOS DOS repos

Antes de dar por terminada una tanda de trabajo, en **cada** repo:

1. `git branch -r --no-merged origin/main | grep claude/` — la salida tiene que
   quedar **vacía**. Si aparece una rama:
   - Comparala con main por contenido, no por nombre:
     `git show <rama> | git patch-id --stable` contra el commit equivalente de
     main. Si el patch-id coincide, el trabajo YA está publicado: borrá la rama
     (`git push origin --delete claude/<rama>`).
   - Si NO coincide, el trabajo está sin publicar: mergealo o, si Julio decidió
     descartarlo, borrá la rama y anotá la decisión. **No la dejes ahí.**
2. Borrá también las ramas `claude/*` ya mergeadas. Una rama que sobrevive al
   merge es ruido que después tapa a la que sí quedó colgada.
3. Si la sesión tocó los dos repos, decí explícitamente en el reporte final qué
   quedó publicado **en cada uno**. Si uno de los dos no necesitaba cambios,
   decilo también ("StockVendedor no cambia porque los vendedores no tocan
   dinero") — así se distingue "no hacía falta" de "me lo olvidé".

> Antecedente: la rama `claude/odoo-functions-analysis-18zc1k` (commit `f5b7cf2`,
> 2026-06-18) tiene la reposición de stock y la antigüedad de la deuda —126 líneas
> de funcionalidad terminada— y nunca se mergeó. La sesión cerró como
> "review_ready". Revisá si todavía sirve antes de rehacerla.
```

---

## C-4 · El banco de pruebas reemplaza a "decile a Julio qué mirar"

**Justificación**: §5 — 6 de 24 sesiones (25%) terminan pidiéndole a Julio que
mire el celular; `pruebas.html` (15 y 13 pruebas automáticas) existe desde el
2026-07-30 y la skill, sin tocar desde el 2026-06-10, no lo menciona.

**Acción**: reemplazar el bloque "Después de mergear" de
`.claude/skills/flujo-stock/SKILL.md`:

```markdown
## Después de mergear

1. **Verificación automática primero.** Cada repo tiene un banco de pruebas en
   `/pruebas.html` (no linkeado desde la app): diagnóstico de conexión y stock +
   pruebas automáticas que cargan la app real en un iframe aislado (16 en la
   central, 13 en el vendedor). No toca datos reales.
   Decile a Julio: *"abrí <url>/pruebas.html y tocá ▶ Correr todas las pruebas;
   tiene que dar 16 de 16"*. Ésa es la verificación por defecto, no un paso a mano.
   - Si tocaste `normalize()`, `vendor_data_v2`, el cruce por `_key` o el
     descuento de stock: **hay que correr los dos bancos** y actualizar
     `KEY_VECTORS` en los dos `pruebas.html` (hoy es idéntica; si diverge, el
     banco se pone en rojo antes de que se rompan los pedidos).
   - Si el cambio no está cubierto por ninguna prueba, **agregá la prueba** en el
     mismo commit. Es más barato que otro ciclo de "mirá el teléfono".
2. Un solo paso manual, y sólo si el cambio es visual: 1 o 2 indicaciones
   concretas de qué mirar en la app publicada.
3. Verificá el estampado del cache **una sola vez, después del último merge**
   de la sesión (`git pull` + `const CACHE` en `sw.js` con timestamp nuevo).
   Si en ~2 min no aparece: `python build.py`, commit, push.

## Publicar de a tandas — no negociable

Un merge = un deploy = un ciclo de espera para Julio. Implementá **todo** lo que
pidió y publicá **una sola vez** al final. Regla dura: **máximo un merge por
sesión**, salvo que Julio pida explícitamente publicar algo antes.

> Antecedente: el 2026-06-21 se hicieron 24 merges y 27 publicaciones entre los
> dos repos en un día, con esta misma regla ya escrita desde el 2026-06-10.
```

---

## C-5 · Sección de decisiones abiertas, con fecha

**Justificación**: §6 — 4 decisiones reales colgadas, una de ellas
(`appPrompt`) enterrada en la línea 388 de un archivo de 442 y sin levantar en
5 sesiones posteriores; Neon evaluado el 2026-07-15 y **nunca anotado** pese a
que la propia sesión ofreció anotarlo; el aviso a usuarios vence en septiembre 2026.

**Acción**: agregar cerca del **principio** de `SISTEMA.md` (no al final, no
adentro de "Notas de desarrollo"):

```markdown
## 🔴 Decisiones abiertas — revisar al empezar cualquier sesión

Si alguna de estas se resuelve, **borrala de acá** y movela a la sección que
corresponda. Si una lleva más de un mes, planteásela a Julio en la primera
respuesta de la sesión en vez de esperar a que se acuerde.

| Abierta desde | Qué falta decidir/hacer | Estado |
| --- | --- | --- |
| 2026-06-18 | **Rotar la anon key de Supabase** (limpieza de legado, `AUDITORIA.md` §5.1). Ojo: desde la conexión de fábrica del 2026-07-30 ya NO hay que re-pegar la key en cada teléfono — el costo que frenó la decisión desapareció. | sin decidir |
| 2026-06-21 | **Portar `appPrompt` a StockVendedor**: sus `prompt()` de contraseña siguen siendo los nativos del navegador (`sbUnlockConfig`, `authGateConfig`, gran reset). La central ya lo tiene. | sin hacer |
| 2026-06-21 | **Confirmación de Julio** sobre los desplegables propios en modales y en los `<select>` dinámicos de la central. | esperando a Julio |
| 2026-07-15 | **Neon vs Supabase para proyectos nuevos**: se evaluó en una sesión y la conclusión no quedó anotada en ningún lado, así que se vuelve a evaluar cada vez. Anotar el veredicto acá. | sin registrar |
| 2026-07-30 | **Conteo físico de stock** contra el sistema. Es la única forma de detectar el faltante que la bitácora antifraude NO cubre (entregar mercadería sin registrar nada). | esperando OK de Julio |
| ~2026-09 | **Aviso a los usuarios** de que los movimientos quedan registrados (encuadre y texto ya definidos más abajo). Vence cuando se cumpla ~1 mes de uso real. | con fecha |
```

---

## C-6 · Skill de auditoría (sacarla de los `CLAUDE.md`)

**Justificación**: §7.1 — 9 sesiones de auditoría en el índice, 5 del grupo
stock, más una sesión entera del 2026-07-14 titulada *"App audit prompt"* dedicada
a reconstruir el prompt a mano. El formato bueno ya existe (`AUDITORIA.md`,
299 líneas, mantenido al día en 10 commits).

**Acción**: crear una skill `auditoria-app` (a nivel usuario, no por repo — sirve
para `presupuesto-ar`, `pruevacero` y `ArborRisk` también) que codifique lo que
`AUDITORIA.md` ya hace bien:

- Alcance fijo: XSS e interpolación en `onclick`, RLS y policies de Supabase,
  integridad/atomicidad de escrituras, promesas flotantes, CDN pineado + SRI,
  service worker y cache, y el contrato compartido entre apps hermanas.
- Salida: `AUDITORIA.md` con hallazgos numerados por severidad (🔴 C / 🟠 A /
  🟡 M), tabla de estado que se **tacha** al resolver, sección explícita de
  **falsos positivos verificados y descartados**, y plan por fases.
- Regla heredada de C-1: **ubicar los hallazgos por nombre de símbolo, nunca por
  número de línea** — el propio `AUDITORIA.md` ya tuvo que poner el descargo
  *"si no cuadran, reubicar con Grep"*.
- Al terminar: enlazar los pendientes en la tabla de "Decisiones abiertas" (C-5)
  en vez de dejarlos sólo en `AUDITORIA.md`.
```
