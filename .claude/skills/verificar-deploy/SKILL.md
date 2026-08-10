---
name: verificar-deploy
description: Publicar el sitio a Cloudflare y confirmar que lo que quedó servido es realmente lo que hay en el repo. Usar cuando el usuario diga "deploy", "desplegar", "publicar", "subir el sitio", o después de mergear a main. Compara byte a byte cada archivo de public/ contra la URL en producción; publicar sin verificar no cuenta como terminado.
---

# Publicar y verificar

`npm run deploy` publica. **Publicar no es verificar.** En otro repo de Julio,
Cloudflare se desconectó solo y estuvo **4 días sirviendo una versión vieja** sin que
nadie lo notara (`docs/auditoria-claude-code/informe.md`, sección 6).

Este sitio no tiene build step, así que no hay hash de build que comparar. La
verificación es directa: bajar lo que está servido y compararlo con `public/`.

## 1. Publicar

```bash
npm run deploy
```

Anotá la URL que imprime wrangler (`https://webpodaenaltura.<subdominio>.workers.dev`,
o el dominio propio cuando esté migrado). La vas a necesitar en el paso 2.

Para probar sin pisar producción:

```bash
npm run preview     # wrangler versions upload — sube una versión sin activarla
```

## 2. Verificar

```bash
.claude/skills/verificar-deploy/scripts/verificar.sh https://LA-URL-QUE-IMPRIMIO
```

Compara el sha256 de cada archivo de `public/` contra lo que devuelve esa URL. Sale
con código 0 sólo si **todos** coinciden.

Si algo no coincide, casi siempre es una de estas tres:

| Síntoma | Causa probable |
| --- | --- |
| Todos los archivos viejos | El deploy no llegó a aplicarse, o Cloudflare quedó desconectado del repo |
| Sólo algunos viejos | Caché de borde: reintentá en un minuto antes de asustarte |
| 404 en un archivo nuevo | Está en `public/.assetsignore`, o no se commiteó |

## 3. Recién ahora está terminado

En el cierre, decí **qué commit quedó servido**, no "lo desplegué":

```bash
git rev-parse --short HEAD
```

## Verificación visual

Julio trabaja **sólo desde Android** y no puede abrir la compu para mirar cómo quedó.
Si el cambio es visual, no le pidas que lo verifique él: sacá la captura vos con
Playwright, que ya está instalado en el entorno, y mostrásela.
