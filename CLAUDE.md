# webpodaenaltura

Sitio de **Poda en Altura AR** — arboricultura profesional en Córdoba Capital,
Sierras Chicas y Valle de Punilla (Argentina).

Reemplaza al sitio WordPress + WooCommerce que hoy corre en
`https://podaenaltura-ar.com.ar/`. El destino es **Cloudflare Workers static
assets**, con el mismo dominio.

## Stack y restricciones

- **Sitio estático**: HTML + CSS a mano, sin framework, sin build step.
  `wrangler.jsonc` no define `main`, así que no hay código de Worker.
- **Sin dependencias externas en runtime**: nada de CDNs, Google Fonts ni
  scripts de terceros. Si hace falta una tipografía, se auto-hospeda en
  `public/assets/fonts/`.
- **Mobile-first**: la mayoría de las consultas llegan desde el celular.
- **Idioma**: español rioplatense (voseo). `lang="es-AR"`.

## Estructura

```
public/            # todo lo que se sirve; es la raíz del sitio
  index.html
  404.html
  robots.txt
  assets/css/      # hojas de estilo
  assets/img/      # imágenes (optimizadas, preferentemente .webp)
wrangler.jsonc     # config de Cloudflare Workers
```

Cada página es un archivo `.html` propio. Una carpeta con `index.html` da una
URL limpia: `public/servicios/index.html` → `/servicios`.

## Contenido a migrar del sitio viejo

Inventario relevado del WordPress actual (11 páginas, 1 post de blog,
6 "productos" de WooCommerce a $0 que en realidad son fichas de servicio —
**no hay e-commerce real**, así que no hace falta carrito ni checkout):

| Sección          | Estado en el sitio viejo                                  |
| ---------------- | --------------------------------------------------------- |
| Home             | Hero + listado de servicios                                |
| Servicios        | `/tienda` — 6 fichas: poda y tala, cuidados preventivos, evaluación del árbol, complejidad y riesgo, jardinería, sobre nosotros |
| Trabajos realizados | Galería                                                 |
| Cursos           | Página propia                                              |
| Preguntas frecuentes | FAQ                                                    |
| Blog             | 1 sola entrada — evaluar si se conserva                    |
| Contacto         | `/contact-2`                                               |
| Términos y condiciones | Legal                                                |
| Carrito / Checkout / Mi cuenta | De WooCommerce — **se descartan**            |

Los textos completos relevados del sitio viejo están en
`contenido/textos-sitio-actual.md`, y las decisiones de contenido del rediseño
en `contenido/brief-para-diseno.md`. Esa carpeta es material de referencia: no
se publica, no está dentro de `public/`.

**Ojo con los Términos y Condiciones del sitio viejo**: son un copy-paste de
otro negocio (una vinoteca) y no se migran.

## Preguntas de negocio abiertas

Estas tres frenan el rediseño desde el 4-ago-2026. Mientras no estén resueltas,
no asumas una respuesta: preguntá o dejá el bloque marcado como pendiente.

1. **¿Los cursos siguen activos?** Define si la sección Cursos se migra o se cae.
2. **¿Se publica el PDF de poda segura?** Define si hay una descarga en el sitio.
3. **¿Cuáles son las localidades exactas de cobertura?** Hace falta la lista
   textual para la home y para el SEO local.

## Contacto

- Titular: Julio Barrientos Bolbochan, arborista profesional
- WhatsApp: `+54 9 351 650-7699` → `https://wa.me/5493516507699`
- Instagram: [@podaenaltura.ar](https://instagram.com/podaenaltura.ar)

## Comandos

```bash
npm install
npm run dev      # servidor local en http://localhost:8787
npm run deploy   # publica a Cloudflare
```

## Ramas y cierre de sesión

`main` es la rama de integración, creada el 10-ago-2026. Las tandas de trabajo
salen de `main` en ramas `claude/*` y vuelven ahí.

Al terminar una tanda, cerrala de una de estas dos formas — nunca con una
pregunta de compromiso tipo "¿seguimos con algo más?":

- **Mergeada**, o
- **Sin mergear, diciendo por qué** y qué falta exactamente para poder hacerlo.

Lo segundo es una respuesta válida: una rama se puede descartar porque lo que se
quería ya estaba resuelto, o porque uno se arrepintió de la implementación. Lo
que no vale es dejarla sin registro — una rama descartada a propósito se ve
idéntica a una olvidada, y el que venga después no puede distinguirlas. Si se
descarta, borrala o dejá escrito por qué.

## Deploy y verificación

`npm run deploy` publica, pero publicar no es verificar. Después de un deploy,
confirmá que Cloudflare está sirviendo el commit esperado antes de dar la tarea
por terminada — hubo un caso en otro repo de 4 días sirviendo una versión vieja
sin que nadie lo notara.

Julio trabaja **sólo desde Android** y no puede correr nada local. No cierres
pidiéndole que abra la compu; si hace falta comprobación visual, sacá capturas
vos con Playwright (Chromium ya está instalado en el entorno).

## Cómo describir el código en este archivo

No escribas números de línea ni totales de líneas: se desactualizan en días y
Claude les cree. Para ubicar algo, dá el comando que lo encuentra:

```bash
grep -na "marcador" public/index.html
```

Cualquier dato que quede escrito acá tiene que poder verificarse con un comando
que también esté escrito acá.

## Ejemplos en la documentación

Los ejemplos de este archivo y de `.claude/commands/` son ilustrativos: describen
la **forma** de un pedido, no features que existan. No asumas que algo existe
porque aparece en un ejemplo — verificalo en el código antes de darlo por hecho.

## Estado actual

`public/index.html` es un **placeholder** funcional, no el diseño definitivo.
Existe para validar el pipeline de deploy. El rediseño lo reemplaza por
completo.

## Auditoría de uso de Claude Code

`docs/auditoria-claude-code/` tiene la auditoría de 116 sesiones (may–ago 2026)
sobre los 9 repos de Julio: dónde se traba el trabajo, qué skills faltan y qué
corregir en cada `CLAUDE.md`. Empezá por `informe.md`.
