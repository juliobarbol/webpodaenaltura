---
name: cerrar-sesion
description: Cerrar una tanda de trabajo dejando registro de la decisión. Usar SIEMPRE al terminar de trabajar, y cuando el usuario diga "listo", "terminamos", "cerremos", "dejémoslo acá", "hasta acá", o cuando estés por escribir un mensaje final. Obliga a que la rama termine mergeada o descartada por escrito, nunca en el limbo, y prohíbe cerrar con una pregunta de compromiso.
---

# Cerrar una tanda de trabajo

Una auditoría de 116 sesiones (`docs/auditoria-claude-code/informe.md`) encontró que
el trabajo no se traba por calidad, sino en el cierre:

- **18 ramas quedaron sin registro** de si se descartaron a propósito o se olvidaron.
  Las dos cosas se ven idénticas desde afuera.
- **15 de 30 sesiones** que quedaron esperando al usuario lo hicieron por una cortesía
  vacía — "¿Seguimos con algo más?" —, no por un bloqueo real. Dos de esas cortesías
  dejaron un proyecto entero congelado dos meses.

Esta skill existe para que ninguna sesión termine así.

## La regla

Toda tanda cierra de **una de estas dos formas**, nunca de otra:

1. **Mergeada.**
2. **Sin mergear, con el porqué escrito** y qué falta exactamente para poder hacerlo.

Descartar es una respuesta legítima: pasa que lo que el usuario quería ya estaba
resuelto por otro lado, o que se arrepintió de la implementación. Lo que **no** es
legítimo es dejar la rama sin que nadie sepa cuál de las dos cosas fue.

## Procedimiento

### 1. Mirá qué hiciste realmente

```bash
git status --short
git log --oneline main..HEAD          # commits de esta tanda
git diff --stat main...HEAD           # qué archivos tocó
```

Si hay cambios sin commitear, resolvelos antes de seguir: commitealos, o descartalos
diciendo cuáles y por qué.

### 2. Decidí, y si no podés decidir vos, preguntá una sola cosa concreta

Preguntá **sólo** si la respuesta cambia lo que hacés. "¿Mergeo?" cuando el trabajo
está terminado y probado no es una pregunta: es la cortesía que produjo las 18 ramas.

Si tenés que preguntar, que sea una decisión real y cerrada:

> Quedan dos caminos para X: A o B. Con A pasa esto, con B esto otro. ¿Cuál?

### 3a. Si mergea

```bash
git checkout main
git merge --ff-only <rama>     # o sin --ff-only si divergió
git push origin main
```

Si el repo despliega, verificá el despliegue antes de cantar victoria — para este
repo, la skill `verificar-deploy`. **Publicar no es verificar.**

### 3b. Si NO mergea

Elegí una y hacela, no las dos a medias:

- **Se descarta del todo** → borrá la rama, local y remota. Una rama borrada no
  confunde a nadie:
  ```bash
  git push origin --delete <rama>
  git branch -D <rama>
  ```
- **Queda para después** → dejá el porqué **por escrito y donde se vea desde `main`**,
  no dentro de la rama que nadie va a abrir. Una línea alcanza:

  ```markdown
  ## Ramas abiertas
  - `claude/loquesea` — hecho X, falta Y. Frenada porque Z. (10-ago-2026)
  ```

### 4. Escribí el cierre

El mensaje final dice, en este orden:

1. **Qué quedó hecho**, concreto y verificable.
2. **Dónde quedó**: mergeado en `main`, o en tal rama y por qué.
3. **Qué falta**, si falta algo, con el nivel de detalle que le permita a otro
   retomarlo sin releer la conversación.
4. **Las decisiones abiertas**, si las hay, planteadas como decisión y no como
   "¿querés que…?".

## Prohibido cerrar con esto

Estas frases son el patrón exacto que la auditoría encontró. No las escribas:

- "¿Seguimos con algo más?"
- "¿Querés que lo deje así o que lo cambie?"
- "¿Lo dejamos acá por hoy?"
- "¿Querés que la limpie?"
- "Avisame si querés que siga."

Si de verdad no queda nada, el cierre correcto es decir qué quedó hecho y punto.

## Antes de dar por terminado, chequeá

```bash
git status --short                          # ¿quedó algo sin commitear?
git log --oneline origin/main..HEAD         # ¿quedó algo sin pushear?
git branch -r --no-merged origin/main | grep claude/   # ¿ramas sin registro?
```

Si la última devuelve ramas viejas que no son la tuya, decilo en el cierre. Es
información que el usuario no tiene y que le cuesta plata averiguar.
