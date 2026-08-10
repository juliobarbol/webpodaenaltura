# Hallazgos — grupo `presupuesto-ar`

Auditoría del uso de Claude Code de Julio en el repo `juliobarbol/presupuesto-ar`.
Fecha del relevamiento: **2026-08-10**.

## 0. Alcance y método

| Dato | Valor | Cómo se obtuvo |
|---|---|---|
| Commits en `main` | **392** | `git rev-list --count HEAD` |
| Merges en `main` | 152 | `git rev-list --count --merges HEAD` |
| Ramas `claude/*` | **53** | `git branch -r \| grep -c claude/` |
| Ramas `claude/*` mergeadas | **47** | `git branch -r --merged HEAD` |
| Ramas `claude/*` sin mergear | **6** | `git branch -r --no-merged HEAD` |
| Sesiones que tocan el repo | **62 únicas** | 54 en `sesiones-todas.tsv` + 8 en `pagina1-sesiones.tsv`, intersección 0 |
| Sesiones con `origin` conocido | 52 (de los dumps `mcp-*.txt`) | **51 `android` / 1 `desktop_app`** |
| Rango temporal | 2026-06-06 → 2026-08-06 | primer y último commit |

**Limitación declarada:** no tuve acceso a transcripciones de sesión, sólo a
`post_turn_summary` (`status_detail` / `needs_action`) y al historial de git. Donde
un patrón sólo puede medirse con transcripciones, lo digo explícitamente en vez de
estimarlo (ver §3).

El clone es *treeless*: `git log`, `git show --stat` y `git show <commit> -- <archivo>`
funcionaron sin problemas, así que toda la evidencia de abajo está verificada contra
commits reales.

---

## 1. Retrabajo: commits que arreglan un arreglo

**Resultado: al menos 14 temas necesitaron 2+ pasadas.** Abajo, cada uno con sus
commits. El patrón dominante no es "vuelve semanas después", es **iteración dentro de
la misma sesión y el mismo día**: se despliega, Julio mira el celular, no era eso, se
vuelve a desplegar.

### T1 — Conectar con Google (Drive + Calendar): 15 commits, 6 en un solo día

| Hash | Fecha | Asunto |
|---|---|---|
| `5eaa01d` | 06-07 | Backup automático en Google Drive (inerte hasta configurar Client ID) |
| `012f84d` | 06-07 | Activar backup en Google Drive (Client ID configurado); cache v20 |
| `874a11a` | 06-08 | Drive: no pedir login al abrir; renovar token en silencio con email-hint |
| `2f8c0a5` | 06-13 | Drive: usar `login_hint` (**no `hint`**) para no mostrar el selector con 2 cuentas |
| `7545c0a` | 07-16 | Agenda: sincronización automática con Google Calendar (módulo GCAL) |
| `4fcec62` | 07-16 | GCAL: mensajes de error accionables al conectar/sincronizar |
| `6a3d243` | 07-16 | GCAL: forzar consentimiento al conectar (fix `access_denied`) |
| `2f4718a` | 07-20 | Cachear el token de Google para reaperturas rápidas |
| `6ac9ce0` | 07-20 | Arranque de Google diferido + reintento silencioso ante 401 |
| `a40a42c` | 07-25 | Que el error de Google Calendar se lea y diga qué arreglar |
| `f4a7da1` | 07-25 | Mostrar qué respondió Google al fallar la conexión |
| `19464a5` | 07-25 | Precargar la librería de Google: el popup llegaba tarde |
| `629876f` | 07-25 | Conectar Calendar sin ventana cuando el permiso ya está otorgado |
| `24cfc65` | 07-25 | Conectar Google Calendar **por redirección, sin ventana emergente** |
| `c8e0d3f` | 07-25 | Reintentar **sin la cuenta recordada** cuando la ventana se cierra sola |

Seis commits el **2026-07-25**, todos sobre el mismo botón "Conectar" (sesión
`Error de conexión Google Calendar`, rama `claude/google-calendar-connection-error-lkn7i4`,
71.246 tokens de salida / 17,9 M de cache read). El mismo síntoma (`popup_closed`
que "parece falta de permisos y no lo es") aparece dos veces con **50 días de
diferencia**: `2f8c0a5` (13/06, Drive) y `c8e0d3f` (25/07, Calendar). El CLAUDE.md ya
documenta las dos lecciones (líneas 82-83), pero se documentaron **después** del
segundo golpe, no del primero.

### T2 — Imprimir el PDF / nombre del archivo: 3 fixes seguidos, 2 en direcciones opuestas

Todos de la **misma sesión** `session_01JWDS4sqoHnpGf2fEtDGUEn`, todos el 2026-07-05:

- `9b14063` Recibo de pago en PDF desde la pestaña Facturación
- `5c5588d` Recibo: **no restaurar** `#doc-a4` tras imprimir (PDF en blanco al cambiar a A4)
- `e47104e` PDF con nombre correcto: **restaurar el título** al volver del diálogo de impresión
- `7ccde88` PDF con prefijo en el nombre: `Presupuesto NNNN - Cliente`

`5c5588d` y `e47104e` son literalmente "no restaures esto al volver de imprimir" /
"sí, restaurá esto al volver de imprimir": el primer fix rompió el segundo caso.

### T3 — Compartir el presupuesto: 9 commits y **un revert explícito**

- `37cb6f4` (06-06) Enviar PDF como archivo adjuntable (Web Share API)
- `196db9f` (06-06) PDF vectorial (pdfmake) — reemplaza html2pdf
- **`3cfd7ec` (06-06) `Revert "Merge: PDF vectorial (pdfmake)…"`** ← único revert del repo
- `b6282a5` (06-06) Subir CACHE_VERSION a v16 tras quitar el PDF como archivo
- `8f61d5e` (06-25) Agregar botón "Compartir PDF por WhatsApp"
- `f96d065` (06-25) Agregar opción "Compartir como imagen PNG"
- `01cf263` (06-25) **Dejar solo imagen PNG (quitar PDF)** ← segunda marcha atrás
- `1cf816c` (06-27) Arreglar espacio en blanco al compartir imagen PNG
- `b42e49a` (07-21) Compartir imagen: flujo de dos toques + fallback

Dos cambios de dirección completos (pdfmake revertido; PDF eliminado a favor de PNG)
sobre la misma funcionalidad.

### T4 — Anotaciones internas / panel "Notas": 7 commits en un día, la misma sesión

Sesión `session_012j5p3gmuF7U8gueEcNJHAy`, 2026-07-20:

`933d54e` (crear anotaciones por ítem) → `5aee2de` (**"Rediseñar anotaciones internas:
panel único"** — el commit inmediatamente siguiente al que las creó) → `68e3ef9` (no
abrir el teclado) → `7e7447d` (resaltar la nota abierta) → `7f77448` → `3aae079` →
`9c86449` (**"Arreglar el contador de Notas pegado"**). v144 → v150 en un día.

### T5 — Popup del mapa: la misma acción redefinida 3 veces en una sesión

Sesión `session_011qxLjHmxfvL66q9K35zvUt`, 2026-07-10:

- `0510a30` (v121) tocar la fila **abre la vista previa**
- `f91ccf7` (v122) tocar el nombre **abre la vista previa, no el editor**
- `402369e` (v123) tocar la fila **lleva al presupuesto en el historial** (`goToHistoryEntry`)

Tres definiciones distintas de qué hace un tap, con tres deploys, en el mismo día.

### T6 — Agenda, vista Semana/3 días: 4 reconstrucciones en 3 días

`e04f37f` v129 (lista cronológica, 07-10) → `35f3687` v132 (grilla de columnas, 07-10)
→ `ff51b8c` v133 (**"rediseño"** como tira de días, 07-10) → `2bc285c` + `4af53f9` v134
(columnas por día con bloques, 07-11) → `ded7ae4` v135 (**"fix encabezado fantasma"**,
07-12). Nueve versiones de caché (v126→v135) en cuatro días para una sola pestaña.

### T7 — Clima: el texto que se corta, arreglado dos veces el mismo día

Sesión `session_013iLorrsm2a8449Djz4rFJD`, 2026-07-21:
`b533750` "Aviso de lluvia: toast que **no se trunca**" y `9dc1f09` "Clima: el fondo del
chip **envuelve el texto largo (no lo corta)**".

### T8 — Controles nativos de Chrome, reemplazados de a uno

`43410fa` (dropdowns, 06-27) → `24cbfc8` (datepicker propio, 06-27) → `0860301`
(display de vencimiento, 06-27) → `d7cb72d` (buscador + inputs nativos, 06-27) →
y **un mes después** `15b28cf` (07-22) *"Agenda: arreglar selector de tipo del modal de
editar nota"* — el mismo problema otra vez. La lección quedó escrita recién en
CLAUDE.md:48 (`z-index 2400/2401`, *"el mismo problema que convirtió el `<select>` de
Tipo en un segmentado"*).

### T9 — Estilos y temas del PDF: 4 commits el mismo día + 1 recaída

`1f491a0` (4 temas) → `7f3c12b` (**"Auditoría de estilos: corregir variable `--card`"**)
→ `a1aa582` (coherencia del color de marca) → `1a69e30` (refactor: fuente única de
estilos), todos el 2026-06-08. Recaída: `2f868df` (06-27) *"Vista previa del historial
usa el diseño/tema elegido **ahora**"* — la vista previa seguía sin respetar el tema.

### T10 — `CACHE_VERSION` olvidado: 8 commits que existen sólo para eso

Bumps sueltos (el paso se olvidó en el commit de la feature):
`8a64eaf` (v12, 06-06), `b6282a5` (v16, 06-06), `01d21c1` (v45, 06-14),
`ac9a204` (v46, 06-14), **`5864cd5` (v109, 07-07)** — este último es un mes después de
que la regla estuviera escrita.
Commits que sólo sincronizan el número dentro del CLAUDE.md: `a1dc7a3` (v70),
`5c5855d` (v72), `25069ae` (v173). **El CLAUDE.md guarda un dato que se desactualiza
solo y obliga a un commit de mantenimiento.**

### T11 a T14 — Otros temas con 2+ pasadas (evidencia resumida)

| Tema | Commits |
|---|---|
| T11 · "Tiempo estimado de trabajo" | `7c435c2` (agregar) → `eefe9e0` (reordenable) → `a122c1b` (hacerlo discreto), 06-28 |
| T12 · Ubicación exacta | `522ac9e` (agregar, 06-29) → `bfa017a` (desplegable) → `4774ff5` (GPS) → `3292f47` (bug: se heredaba entre presupuestos, 07-05) |
| T13 · Banner "Podas de hoy" | `77a8e05` (07-07) → `5864cd5` (bump olvidado) → `c19b094` (queda todo el día + Realizado) → `b80378d` (pop-up) → `48066d0` (**"usar el ícono de árbol en vez del emoji"**) |
| T14 · Rediseño del editor | Fases ejecutadas **fuera de orden**: `2e08613` (0a) → `81b2983` (0b) → `c11feeb` (1) → `a2d1318` (**4**) → `7792fba` (**2**) → `a1a6cde` (**1b**), todo el 07-30; más `e985da9` *"docs: **sacar las contradicciones del plan** antes de retomarlo en otra sesión"* |

**Costo aproximado del retrabajo:** de los 392 commits de `main`, ~55 (14 %) son
segundas o terceras pasadas sobre algo ya entregado en los días anteriores.

---

## 2. Ramas abandonadas

`git branch -r --no-merged HEAD` devuelve **6 ramas `claude/*`**. De esas, **3 tienen
contenido que efectivamente ya está en `main` con otro hash** (rebase/squash) y **3
perdieron trabajo real**.

### Trabajo realmente perdido

| Rama | Commit | Fecha | Qué se perdió | Sesión que lo generó |
|---|---|---|---|---|
| `claude/poda-altura-product-analysis-8b48jf` | `c8cb419` | **2026-06-25** | **Fix de un bug de producción**: la franja verde de 5 px del encabezado del PDF se duplicaba al pie de página en documentos multipágina (se ve casi negra en visores Android). Afecta 4 de 7 temas (clásico, cálido, técnico, elegante). | *"Poda en Altura PWA product analysis"*, 2026-06-24, `need_input`: **"confirm OK to merge to main so you can test 2-page PDF on phone"** |
| `claude/cool-bohr-6riute` | `01ce8e6` | **2026-06-13** | **3 skills, 403 líneas**: `.claude/skills/deploy-presupuesto/SKILL.md` (93), `.claude/skills/nueva-feature/SKILL.md` (91), `.claude/skills/webapp-testing/SKILL.md` (70) + `scripts/app-shot.cjs` (149) | *"Recommended skills for app development"*, 2026-06-13, `need_input`: *"¿Quiero dejarlo cableado así esa variable empieza a tener efecto?"*. **Única sesión del repo con `origin: desktop_app`** (las otras 51 son `android`) |
| `claude/styles-themes-audit-99fkui` | `4c35feb`, `7ee580e` | **2026-06-08** | `test-preview.html` (479 líneas, banco de pruebas standalone del PDF) y `HANDOFF.md` (142 líneas, continuidad entre sesiones). El commit útil de esa rama (`3177e6b`) sí llegó como `1a69e30`. | *"Styles and themes audit"*, 2026-06-08, `need_input`: *"¿Algo más que quieras que agregue al documento antes de cerrar?"* |

**El caso más caro está confirmado a nivel de código:** el fix `c8cb419` **sigue sin
aplicarse hoy, 47 días después**.

```
$ grep -an 'class="ph" style="border-top:5px' index.html
14840:  <div class="ph" style="border-top:5px solid ${color}">

$ grep -an 'linear-gradient(${color},${color}) top left' index.html
(sin resultados)
```

Es decir: `main` conserva exactamente el `border-top:5px` que `c8cb419` identificó como
la causa de la raya espuria al pie. La sesión se cerró preguntando permiso para
mergear, Julio no respondió, y el bug sigue vivo en producción.

### Ramas cuyo contenido sí llegó a `main`

| Rama | Equivalente en `main` |
|---|---|
| `claude/budget-expiration-notifications-38vrbo` (`cfd6d6d`) | `e18672e`, mismo asunto y fecha |
| `claude/share-target-implementation-lnjmib` (`7aaa193`) | `72ff967` (`… (#8)`) |
| `claude/login-prompts-offline-support-5pwFk` (`4fac957`, `569326e`, `a14ddf4`) | `874a11a (#2)`, `d08f51e (#3)`, `ddf3f01 (#4)` |

Estas 3 no son pérdida de trabajo, pero **sí son ruido**: quedan como "sin mergear" y
obligan a investigarlas cada vez que alguien mira el estado del repo.

---

## 3. Loops de verificación manual

**Lo que puedo probar con los datos disponibles: 3 sesiones cierran pidiéndole
explícitamente a Julio que mire algo en el celular.** No puedo dar un número mayor
porque no tengo transcripciones — sólo los resúmenes de cierre. **Digo esto
explícitamente para no inflar el hallazgo.**

| Fecha | Sesión | Lo que se le pidió |
|---|---|---|
| 2026-06-08 | PDF design options | **"¿Lográs entrar a Configuración → Estilo y ver las 4 opciones?"** |
| 2026-06-22 | Budget expiration notifications | **"Check notification bar now and tell me what you see (🌳 icon = success, ❌ nothing/old Chrome notification = SW not updated)"** |
| 2026-06-24 | Poda en Altura PWA product analysis | **"confirm OK to merge to main so you can test 2-page PDF on phone"** — la que terminó en el fix perdido `c8cb419` |

**Pero la evidencia estructural del cuello de botella es mucho más fuerte que esas 3
frases**, y está en el git y en la metadata:

1. **51 de 52 sesiones tienen `origin: "android"`.** La única `desktop_app` es la del
   13/06 sobre skills — y es la única cuyo trabajo nunca se mergeó.
2. **El ciclo "cambio → deploy → mirar el celular → corregir" está fosilizado en los
   commits.** T5 (3 taps distintos en un día, `0510a30`/`f91ccf7`/`402369e`), T4 (7
   versiones de caché en un día), T7 (dos veces el mismo texto cortado) sólo tienen
   sentido si cada iteración requiere un deploy y una mirada humana a una pantalla de
   celular.
3. **Se construyó infraestructura sólo para poder verificar sin Julio:**
   - `2ca4beb` (06-14) *"push: endpoint `GET /test` para disparar un push de prueba a mano"* — un endpoint HTTP cuyo único propósito es que Julio pueda gatillar una notificación desde el navegador del celular.
   - `0ffd79c` (06-09) *"chore: SessionStart hook + test de PWA con navegador headless"* + `.claude/hooks/session-start.sh` (baja `chrome-headless-shell` 131.0.6778.204).
   - `d29e39b` (07-30) *"Red de seguridad para el rediseño: rollback documentado y **test visual**"* → `test/visual-snap.cjs` + `test/visual-crop.py`.
   - `14ccb76` (07-30) *"test/visual-snap: ocultar el indicador de guardado"* — retoque del propio verificador visual.
4. **El deploy mismo dejó de ser verificable a ciegas:** `87aaf03` (07-30) documenta que
   *"el merge llegó a GitHub pero Cloudflare seguía sirviendo la versión de **cuatro días
   antes** — la integración con el repositorio se había desconectado sola"*, y agrega a
   `docs/rollback.md` el comando
   `curl -s …/sw.js | grep -m1 CACHE_VERSION` para distinguir "todavía construye" de
   "no se disparó". Cuatro días de trabajo desplegado que nadie vio.

**Conclusión honesta:** el patrón "decime qué ves" aparece poco en los resúmenes, pero
el costo del cuello de botella está pagado igual — en forma de iteraciones múltiples
por deploy y en herramientas construidas para esquivarlo. Y esas herramientas
(`visual-snap`, `rollback.md`) **no están referenciadas desde el CLAUDE.md**, así que
cada sesión nueva arranca sin saber que existen.

---

## 4. Decisiones que quedaron colgadas

Filtré las sesiones `need_input` del repo separando decisiones reales de cortesías.

### Decisiones reales, abiertas

| Decisión | Sesión / fecha | Abierta hace | Verificación |
|---|---|---|---|
| **¿Mergeo `c8cb419` para que puedas probar el PDF de 2 páginas en el celular?** | *Poda en Altura PWA product analysis*, 2026-06-24 | **47 días** | Confirmado sin resolver: `border-top:5px` sigue en `index.html:14840` |
| **¿Qué camino de analytics? (Cloudflare Web Analytics / Umami / Plausible / endpoint en el Worker) y qué eventos medir** | *Application usage analytics*, 2026-06-08 | **63 días** | `git log --all --grep='analytic\|umami\|plausible'` → **0 resultados**. Nunca se implementó nada. |
| **¿Cableo la variable para que las skills empiecen a tener efecto?** | *Recommended skills for app development*, 2026-06-13 | **58 días** | Las 3 skills siguen sólo en `claude/cool-bohr-6riute`; `main` sólo tiene `.claude/skills/nuevo-tema-pdf/` |
| **¿Dejo anotada en algún `CLAUDE.md` la decisión sobre Neon, para no volver a evaluarla cada vez?** | *Neon for future projects*, 2026-07-15 | **26 días** | `grep -ci neon CLAUDE.md` → **0**. `git log --all --grep=neon` → 0. La decisión se va a re-evaluar de cero la próxima vez. |
| **¿Querías la Weather API de Google por algún dato puntual que falta, o era curiosidad?** | *Banner de detalles climáticos*, 2026-07-23 | **18 días** | Sin commits de Google Weather API; sigue Open-Meteo (`js/clima.js`) |
| **Plan de remediación de la auditoría: Tandas 5 (M7), 6 (M1+M2) y 7 (A5, M4, M5, M6, M8, B1–B4)** | *App security audit*, 2026-07-14 / informe `c981985` del 07-24 | **17 días** | `docs/auditoria-2026-07-24.md:805-820`: Tandas 1–4 ✅ HECHAS, 5 parcial, 6 y 7 sin empezar. **El CLAUDE.md no menciona que este plan existe.** |

### Resueltas de hecho, aunque la pregunta quedó sin contestar

- *Google Maps Plus Code in quotes* (06-29): "¿coordenadas o Plus Code?" → se resolvió
  haciendo las dos cosas en `0548c70` (07-09).
- *DaisyUI design review* (06-14): "¿cambio el emoji 🌳 de la barra superior?" → resuelto
  por arrastre en `8af2f2e` (06-27, emojis → iconos Lucide).

### Cortesías (no son decisiones; no las cuento)

*"¿Seguimos con algo más?"* (07-09, Budget locations map) · *"¿Algo más que quieras que
agregue al documento antes de cerrar?"* (06-08, Styles and themes audit) · *"¿Querés
que la limpie?"* (06-19) · *"¿Querés que siga ahora con algo o lo dejamos acá por hoy?"*
(07-05) · *"¿Querés que ajuste algo del look…?"* (06-27, Save as draft).

**Observación:** 4 de las 6 decisiones reales abiertas son de la forma *"¿querés que lo
deje escrito / cableado / mergeado?"*. Es decir: **el trabajo estaba hecho y se perdió
en el último paso, por pedir permiso para persistirlo.**

---

## 5. Temas atacados desde cero varias veces → candidatos a skill

### 5.1 Auditoría integral de la app — **reconstruida 3 veces**

| Intento | Evidencia | Qué produjo |
|---|---|---|
| 1º · 2026-06-08 | Sesiones *"Budget app pre-launch audit"* ×2 (una **`FAILED`**, `claude-sonnet-4-6`) + *"Styles and themes audit"* | `7f3c12b` "Auditoría de estilos"; `HANDOFF.md` **nunca mergeado** |
| 2º · 2026-07-14 | Sesión *"App audit prompt"* (`claude-fable-5`) | `5422fd1` → **`docs/prompt-auditoria.md`** (7,3 KB): *"prompt de auditoría integral **para usar en otra sesión**"* |
| 3º · 2026-07-14/24 | Sesión *"App security audit"* (`claude-opus-5`, **139.452 tokens out / 38,2 M cache read — la sesión más cara del repo**) | `c981985` → `docs/auditoria-2026-07-24.md` (45,7 KB, 24 hallazgos) + `25069ae` (actualizarla a v173) + tandas `d9640ad`/`095ff8e`/`4d8239f`/`4ed602e` |

`docs/prompt-auditoria.md` **ya es una skill disfrazada de documento**: un prompt
reusable guardado a mano porque no había dónde ponerlo. Convertirlo en
`.claude/skills/auditoria-app/` es el cambio de mayor retorno del repo.

### 5.2 Deploy y verificación del despliegue

Evidencia: 8 commits de `CACHE_VERSION` (T10) · `87aaf03` + `docs/rollback.md`
(incidente del 30/07: 4 días sirviendo una versión vieja) · `d98830a` "Merge: nota de
despliegue tras la desconexión de Cloudflare" · `5864cd5` "Subir CACHE_VERSION a v109
**para desplegar**". **La skill ya estaba escrita y se perdió**:
`.claude/skills/deploy-presupuesto/SKILL.md`, 93 líneas, en `claude/cool-bohr-6riute`.

### 5.3 Verificación visual sin el celular

Evidencia: `0ffd79c` (hook + puppeteer), `d29e39b` (`test/visual-snap.cjs` +
`test/visual-crop.py`), `14ccb76` (retoque del snapshotter), `2ca4beb` (endpoint
`/test` del push). **También ya escrita y perdida**:
`.claude/skills/webapp-testing/SKILL.md` + `scripts/app-shot.cjs` (149 líneas) en la
misma rama abandonada. Hoy `main` tiene el tooling pero **cero documentación de cómo
usarlo** — CLAUDE.md no lo nombra.

### 5.4 Conectar / diagnosticar OAuth de Google

15 commits (T1), 3 tests dedicados (`gis-preload`, `gcal-connect`, `gcal-redirect`), un
doc (`docs/gcal-redirect.md`) y ~50 líneas de CLAUDE.md (82-85). El mismo bug de
`login_hint` mordió dos veces con 50 días de diferencia. Es un procedimiento de
diagnóstico repetible, no prosa de referencia.

### 5.5 Revisión de estilo / escaneabilidad de la UI

`8c1e292`→`74cb65a` (Fases 1-5, 06-27) · `43410fa`/`24cbfc8`/`0860301`/`d7cb72d`
(controles nativos, 06-27) · `66693a9`→`94ae72e` (color de iconos, dos pasadas) ·
`15b28cf` (recaída del `<select>`, 07-22). Cinco sesiones distintas atacando "que se
lea mejor en el celular" sin un criterio escrito.

### 5.6 Nueva feature end-to-end

`.claude/skills/nueva-feature/SKILL.md` (91 líneas) existía en
`claude/cool-bohr-6riute` y nunca se mergeó. Los 152 merges de `main` siguen todos el
mismo ritual (rama → CACHE_VERSION → test → merge → deploy) reconstruido de memoria en
cada sesión.

**Skills que hoy existen en `main`: 1** (`nuevo-tema-pdf`). Skills escritas y perdidas: 3.

---

## 6. Fallas del `CLAUDE.md` actual

El archivo tiene **26.629 bytes / 137 líneas**. Todo lo de abajo está verificado contra
el repo en el estado actual de `main`.

### 6.1 Datos numéricos desactualizados (3 de 3 están mal)

| Línea | Dice | Realidad | Factor |
|---|---|---|---|
| 4 | *"no escanear las **~8.000 líneas** del `index.html`"* | `wc -l index.html` → **19.374** | **2,4×** |
| 51 | *"El CSS vive en el `<style>` (**líneas ~16–1711**)"* | `<style>` en 21, `</style>` en **3218** | **1,9×** |
| 18 / 95 | `CACHE_VERSION: presupuesto-v201` | `sw.js` → `presupuesto-v201` ✅ | correcto — pero **a costa de 3 commits de mantenimiento** (`a1dc7a3`, `5c5855d`, `25069ae`) |

### 6.2 El comando que el propio CLAUDE.md manda usar **no funciona**

Línea 28: ` grep -n "===== js/" index.html `

```
$ grep -n "===== js/" index.html
grep: index.html: binary file matches
```

`index.html` contiene fuentes embebidas en base64 y logos, así que grep lo trata como
binario. **Hay que usar `grep -an`.** Cada sesión que sigue la instrucción literal
recibe una sola línea inútil en vez del índice de 19 secciones. Es la primera
instrucción operativa del archivo.

### 6.3 El "Mapa del código" omite 2 de las 19 secciones

Presentes en `index.html` y **ausentes de la tabla** (líneas 31-49):
`js/dropdown.js` (línea 5137) y `js/datepicker.js` (línea 5251). No es trivial: son
justo los módulos del T8 (controles nativos reemplazados) y del bug de z-index
documentado en la línea 48.

### 6.4 Afirmación falsa sobre el push worker

Línea 20: *"La app **es inerte** a esto hasta rellenar `PUSH_WORKER_URL` /
`PUSH_VAPID_KEY` en `index.html`."*

```
index.html:4850: const PUSH_WORKER_URL = 'https://presupuesto-push.juliobarribolbo.workers.dev';
index.html:4851: const PUSH_VAPID_KEY  = 'BBlrB43TWc5wHAHPhY0kcMwt4g9f1tBejOZ5W5zWc6OU273X9DCvunkB4Cu9zkdXEWom3IRqPi7fxa9Au0vAWiE';
```

Están rellenos desde `462c300` (**2026-06-14**). El push está vivo hace 57 días. Una
sesión que lea esa línea puede concluir que la feature no está conectada y "arreglarla".

### 6.5 El flujo de despliegue afirma algo que ya falló en producción

Líneas 89-92: *"Cloudflare detecta el push y despliega automáticamente — **no hay
ningún paso manual extra**."*

Contradicho por `87aaf03` (30/07): *"el merge llegó a GitHub pero Cloudflare seguía
sirviendo la versión de cuatro días antes — la integración con el repositorio se había
desconectado sola"*, y por el detalle que ese doc rescata: **al reconectar, el commit
que ya estaba NO se construye solo**. El playbook vive en `docs/rollback.md` y
**CLAUDE.md no lo menciona ni una vez** (`grep -c rollback.md CLAUDE.md` → 0).

### 6.6 Documentos y tests existentes que el CLAUDE.md no referencia

| Recurso | ¿Mencionado? | Por qué importa |
|---|---|---|
| `docs/rollback.md` (5,5 KB) | **No** | Cómo volver atrás y qué hacer si el deploy no aparece |
| `test/visual-snap.cjs` + `test/visual-crop.py` | **No** | La única forma de que Claude *vea* la pantalla sin el celular de Julio |
| `docs/prompt-auditoria.md` (7,3 KB) | **No** | El prompt de auditoría reusable |
| `docs/apk-twa.md`, `docs/share-target-fotos.md` | **No** | Specs de features desplegadas |
| `test/backup-sync.test.cjs`, `test/money.test.cjs`, `test/push-worker.test.cjs` | **No** | 3 de los 14 tests quedan invisibles |

### 6.7 La autorización de auto-merge exige menos verificación de la que hay disponible

Líneas 103-108: autoriza mergear a `main` *"al terminar cada cambio ya verificado
(**sintaxis JS + `test/pwa.test.cjs` OK**)"*. Hay **14 archivos en `test/`**. No existe
`package.json` (`ls package.json` → no such file), así que **no hay un `npm test`**: cada
sesión decide a mano qué corre. Con esa vara, un cambio en `js/pdf.js` se puede
mergear sin ejecutar `security.test.cjs`, `money.test.cjs` ni `config-global.test.cjs`.

### 6.8 No dice en ninguna parte cómo trabaja Julio

51 de 52 sesiones con `origin: android`. El CLAUDE.md **no menciona** que el usuario
opera sólo desde el celular, no puede correr nada local, y que cada verificación visual
cuesta un ciclo completo de deploy. Es el dato que más condiciona cómo debería
trabajar Claude en este repo, y no está escrito. Consecuencias medibles: T4, T5, T6, T7.

### 6.9 No hay ninguna regla sobre ramas

6 ramas `claude/*` sin mergear, 3 de ellas con trabajo perdido (§2), y una con un fix de
producción de 47 días. El archivo no dice qué hacer con una rama al terminar ni cómo
cerrar el ciclo.

### 6.10 Riesgo de alucinación desde ejemplos — **evaluado, con matices**

Se me pidió buscar ejemplos que Claude pudiera confundir con hechos reales (hubo un
caso confirmado en otro repo). En este archivo:

- **NO es alucinación** el ejemplo más "sospechoso": línea 59, *"ese fue el origen de C2
  (el PDF decía $710.000 y el historial guardaba $470.000)"*. Está respaldado por
  `docs/auditoria-2026-07-24.md:37` y `:190-195`. **Es un hecho real y sirve.**
- **Sí hay riesgo estructural, y ya se materializó:** las filas del "Mapa del código"
  son narrativas de changelog de 400-900 palabras con nombres de función, tokens CSS,
  z-index y TTLs concretos (línea 34 sobre `js/net.js`, línea 46 sobre `js/clima.js`,
  línea 48 sobre `js/calendar.js`). No hay forma de distinguir lo que sigue siendo
  cierto de lo que quedó viejo — y **§6.1 y §6.4 demuestran que 4 datos concretos de
  ese archivo ya son falsos**. El riesgo no es que Claude invente una feature de un
  ejemplo: es que dé por vigente una descripción congelada en junio.
- **Un desfase menor detectado:** `docs/auditoria-2026-07-24.md` marca la Tanda 4 como
  A6+M9, pero el commit `4ed602e` la implementó como *"Tanda 4 + A4 + A5"*; A5 sigue
  listado como pendiente en la Tanda 7 del mismo documento.

---

## 7. Propuesta concreta para el `CLAUDE.md` de `presupuesto-ar`

Redactado listo para pegar. Cada bloque cita el hallazgo que lo justifica.

### 7.1 CORREGIR — línea 4 y línea 51 (datos numéricos)

> **Reemplazar** *"para no escanear las ~8.000 líneas del `index.html`"* **por:**

```markdown
> Esta guía es el mapa del proyecto: leela primero para no escanear el `index.html`
> entero (hoy ~19.000 líneas; el número crece, no lo tomes como dato fijo — medilo con
> `wc -l index.html` si te importa).
```

> **Reemplazar** la línea 51 **por:**

```markdown
El CSS vive en el `<style>` del `index.html`. Para ubicarlo sin fiarte de números de
línea: `grep -an "<style>\|</style>" index.html`. Hay dos bloques de estilos del
documento: uno `@media print` (`#doc-a4`) y otro de pantalla para la vista previa
(`.doc-preview-host .doc-a4-screen`).
```

*Justifica: §6.1 — los dos números estaban 2,4× y 1,9× desactualizados.*

### 7.2 CORREGIR — línea 28 (el comando roto)

```markdown
Comando rápido para listarlos todos con número de línea:
```bash
grep -an "===== js/" index.html
```
> **La `-a` no es opcional**: `index.html` lleva fuentes en base64, así que grep lo
> trata como binario y sin `-a` sólo devuelve `binary file matches`. Lo mismo vale para
> cualquier búsqueda dentro de `index.html`.
```

*Justifica: §6.2 — reproducido; la primera instrucción operativa del archivo no funciona.*

### 7.3 AGREGAR — al "Mapa del código", las dos secciones faltantes

```markdown
| `js/dropdown.js` | Dropdown propio que reemplaza el `<select>` nativo de Chrome |
| `js/datepicker.js` | Calendario propio que reemplaza el picker de `<input type="date">` |
```

*Justifica: §6.3 — presentes en `index.html:5137` y `:5251`, ausentes de la tabla, y son
justo los módulos del bug de z-index que la línea 48 documenta.*

### 7.4 CORREGIR — línea 20 (push worker)

> **Reemplazar** *"La app es inerte a esto hasta rellenar `PUSH_WORKER_URL` / `PUSH_VAPID_KEY`"* **por:**

```markdown
Ya está conectado y en producción desde el 14/06/2026 (`PUSH_WORKER_URL` y
`PUSH_VAPID_KEY` rellenos en `index.html`, ver `462c300`). No lo trates como pendiente.
Ver `docs/push-setup.md` y `test/push-worker.test.cjs`.
```

*Justifica: §6.4 — afirmación falsa hace 57 días; invita a "arreglar" algo que funciona.*

### 7.5 AGREGAR — sección nueva, arriba de todo (bloque más importante)

```markdown
## Cómo trabaja el usuario (leer antes de proponer nada)

Julio trabaja **exclusivamente desde un celular Android** (51 de 52 sesiones del repo).
No tiene terminal, no corre nada local, no puede abrir DevTools. La consecuencia
práctica:

- **Cada verificación visual le cuesta un ciclo completo**: mergear → esperar el deploy
  de Cloudflare → abrir la app → mirar. Un "probá y decime" no es gratis, son minutos y
  un deploy.
- **Antes de tocar algo visual, describí en texto el resultado esperado** y pedí
  confirmación del criterio, no del resultado. Tres deploys para decidir qué hace un tap
  (`0510a30` → `f91ccf7` → `402369e`, todos el 10/07) es el modo de fallar típico acá.
- **Usá el snapshotter antes de pedirle que mire**: `node test/visual-snap.cjs` (+
  `test/visual-crop.py` para recortar). Está para eso. Si podés verlo vos, no se lo
  preguntes a él.
- **No cierres una sesión con una pregunta de permiso sobre trabajo ya hecho.** Ver la
  sección "Ramas y cierre de sesión".
```

*Justifica: §3 y §6.8 — 51/52 sesiones desde Android, retrabajo T4/T5/T6/T7, y
`test/visual-snap.cjs` existe pero no está documentado.*

### 7.6 AGREGAR — sección "Ramas y cierre de sesión"

```markdown
## Ramas y cierre de sesión

- **Nunca cierres una sesión dejando trabajo terminado en una rama sin mergear.** La
  autorización permanente de deploy (más abajo) ya cubre el merge: usala.
- Si el cambio está verificado, **mergealo**. Si NO está verificado, decilo en el
  resumen final con el hash y qué falta, en una línea que empiece con
  `PENDIENTE DE MERGE:`.
- **Caso real que esto evita:** `c8cb419` (25/06/2026) arregla una raya negra al pie del
  PDF en documentos de 2+ páginas (temas clásico, cálido, técnico, elegante). La sesión
  terminó preguntando *"¿lo mergeo?"*, nadie contestó, y **el bug sigue en producción 47
  días después** (`index.html:14840` conserva el `border-top:5px` culpable). El fix está
  en `origin/claude/poda-altura-product-analysis-8b48jf`.
- Al empezar una sesión, si `git branch -r --no-merged HEAD | grep claude/` devuelve
  algo, revisalo antes de proponer trabajo nuevo.
```

*Justifica: §2 y §4 — 6 ramas sin mergear, 3 con trabajo perdido, y 4 de las 6
decisiones abiertas son "¿querés que lo deje escrito/mergeado?".*

### 7.7 CORREGIR — la vara de verificación del auto-merge (líneas 103-128)

> **Reemplazar** *"(sintaxis JS + `test/pwa.test.cjs` OK)"* **por:**

```markdown
(sintaxis JS OK + **todos** los tests de `test/` verdes)
```

> **Y agregar** debajo del bloque de "Cómo verificar cambios":

```markdown
**Correr toda la batería** (no hay `package.json`, así que va a mano):
```bash
for t in test/*.test.cjs; do echo "── $t"; node "$t" || break; done
```
Son 14 tests y tardan poco. `test/pwa.test.cjs` solo NO alcanza: los bugs que más
costaron (`C2` del total del estimativo, el XSS por backup importado, la config de
empresa que se reseteaba) los cubren `money.test.cjs`, `security.test.cjs` y
`config-global.test.cjs`, que hoy nadie está obligado a correr.

**Ver el cambio sin depender del celular de Julio:**
```bash
node test/visual-snap.cjs        # screenshot del app-shell
python3 test/visual-crop.py      # recorte para mirar una zona
```
```

*Justifica: §6.7 — 14 tests, la autorización sólo exige 1, y no hay `npm test`.*

### 7.8 CORREGIR — el flujo de despliegue (líneas 89-97)

> **Agregar** después del punto 4:

```markdown
5. **Verificar que el deploy realmente salió** — no asumas que salió:
   ```bash
   curl -s https://presupuesto-ar.juliobarribolbo.workers.dev/sw.js | grep -m1 CACHE_VERSION
   ```
   Si a los ~5 minutos sigue la versión vieja, no es demora. **El 30/07/2026 la
   integración de Cloudflare con el repo se desconectó sola y produjo cuatro días
   sirviendo una versión vieja.** El playbook completo (incluido el detalle de que al
   reconectar el commit que ya estaba NO se construye solo) está en
   **`docs/rollback.md` → "Si el despliegue no aparece"**. Salida de emergencia:
   `npx wrangler deploy`.
```

*Justifica: §6.5 — el CLAUDE.md afirma "no hay ningún paso manual extra", desmentido por
`87aaf03`, y nunca nombra `docs/rollback.md`.*

### 7.9 SACAR — el `CACHE_VERSION` hardcodeado (líneas 18 y 95)

> **Reemplazar ambas menciones de `v201` por:**

```markdown
- `sw.js` — Service Worker (offline + actualizaciones). La versión vigente se lee del
  archivo: `grep CACHE_VERSION sw.js`. **No la copies acá**: se desactualiza sola y
  obliga a un commit de mantenimiento.
```

*Justifica: §6.1 / T10 — `a1dc7a3`, `5c5855d` y `25069ae` son commits cuyo único
contenido es sincronizar ese número dentro del CLAUDE.md.*

### 7.10 AGREGAR — índice de documentos y trabajo pendiente

```markdown
## Dónde está cada cosa (antes de investigar, mirá acá)

| Necesitás | Archivo |
|---|---|
| Volver atrás un deploy / el deploy no aparece | `docs/rollback.md` |
| Correr una auditoría integral de la app | `docs/prompt-auditoria.md` |
| Hallazgos abiertos de la última auditoría | `docs/auditoria-2026-07-24.md` §5 |
| Estado y pendientes de la Agenda | `docs/agenda-roadmap.md` |
| Rediseño del editor (plan y fases) | `docs/rediseno-editor.md` |
| Conexión OAuth por redirección | `docs/gcal-redirect.md` |
| Salud de la conexión / red lenta | `docs/red-lenta.md` |
| Push notifications | `docs/push-setup.md` |
| Empaquetar como APK (TWA) | `docs/apk-twa.md` |
| Share Target de fotos | `docs/share-target-fotos.md` |

**Trabajo pendiente ya priorizado** (`docs/auditoria-2026-07-24.md` §5): Tandas 1–4
hechas. Queda **M7** (Tanda 5), **M1+M2** — fotos, espacio y memoria (Tanda 6) y
**M4, M5, M6, M8, B1–B4** (Tanda 7). Si Julio pregunta "¿qué falta?", la respuesta
está ahí, no hace falta re-auditar.
```

*Justifica: §6.6 y §4 — 5 documentos existentes invisibles para el CLAUDE.md, y un plan
de remediación de 17 días que nadie retoma porque no está enlazado.*

### 7.11 AGREGAR — nota de mantenimiento del propio archivo

```markdown
> **Sobre esta guía:** las filas del "Mapa del código" son descripciones densas,
> escritas en el momento en que cada módulo se construyó. **Tratalas como orientación,
> no como verdad verificada.** Si vas a apoyar una decisión en un detalle concreto de
> acá (un nombre de función, un z-index, un TTL, un número de línea), **confirmalo
> contra `index.html` primero**. Al 10/08/2026 este archivo tenía cuatro afirmaciones
> falsas por antigüedad (tamaño del `index.html`, rango del CSS, estado del push
> worker, y un comando `grep` que no funcionaba).
```

*Justifica: §6.10 — el riesgo real acá no es inventar una feature de un ejemplo, es dar
por vigente una descripción congelada. Ya pasó cuatro veces.*

### 7.12 CREAR — 3 skills (fuera del CLAUDE.md, pero es la acción de mayor retorno)

| Skill | Origen | Evidencia |
|---|---|---|
| `.claude/skills/auditoria-app/` | Convertir `docs/prompt-auditoria.md` | §5.1 — auditoría reconstruida 3 veces; la 3ª costó 139.452 tokens out / 38,2 M cache read |
| `.claude/skills/deploy-presupuesto/` | **Recuperar de `origin/claude/cool-bohr-6riute:01ce8e6`** (93 líneas, ya escrita) + fusionar `docs/rollback.md` | §5.2 — 8 commits de `CACHE_VERSION` + el incidente del 30/07 |
| `.claude/skills/verificacion-visual/` | **Recuperar `webapp-testing/SKILL.md` + `scripts/app-shot.cjs`** de la misma rama (219 líneas) + documentar `test/visual-snap.cjs` | §5.3 y §3 — tooling existente, sin documentar, con el usuario 100 % en Android |

Recuperación literal:
```bash
git checkout origin/claude/cool-bohr-6riute -- .claude/skills/
```

*Justifica: §2 y §5 — 403 líneas de skills escritas el 13/06 que nunca se mergearon
porque la sesión terminó con una pregunta ("¿quiero dejarlo cableado?") que nadie
contestó. La respuesta lleva 58 días abierta.*

---

## Anexo — Patrones que busqué y **NO** encontré

Para que no se lean como omisiones:

- **No hay `git revert` recurrente.** Hay **uno solo** en 392 commits: `3cfd7ec`
  (pdfmake). El retrabajo se hace hacia adelante, no revirtiendo.
- **No hay commits de "merge conflict resuelto mal"** en `main`. El único
  `Resolver conflictos de merge` (`2584bf0`) quedó en una rama sin mergear.
- **No hay ramas con trabajo de más de 3 commits abandonado.** La rama abandonada más
  grande tiene 3 commits, y 1 de esos 3 ya está en `main`.
- **No encontré evidencia de que Julio revierta cambios de Claude en producción.** No
  hay commits de autoría distinta a `Claude <noreply@anthropic.com>` deshaciendo nada.
- **El patrón "decime qué ves en el celular" aparece en sólo 3 de 62 sesiones** en los
  datos disponibles. Es un hallazgo real pero acotado; la evidencia fuerte del cuello de
  botella es indirecta (§3). No lo inflé.
- **No encontré una alucinación confirmada de feature derivada de un ejemplo del
  CLAUDE.md** en este repo. El ejemplo más citable (C2, $710.000 vs $470.000) es un
  hecho verificado en `docs/auditoria-2026-07-24.md`. El riesgo acá es de otra
  naturaleza: obsolescencia silenciosa (§6.10).
