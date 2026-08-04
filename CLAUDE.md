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

## Estado actual

`public/index.html` es un **placeholder** funcional, no el diseño definitivo.
Existe para validar el pipeline de deploy. El rediseño lo reemplaza por
completo.
