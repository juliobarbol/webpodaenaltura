# Brief para la sesión de diseño

Esto es lo que hay que explicarle a Claude Design además de pasarle los textos
de `textos-sitio-actual.md`.

---

## El negocio

**Poda en Altura AR** — arboricultura profesional en Córdoba, Argentina.
Lo lleva Julio Barrientos Bolbochan, arborista.

No es un jardinero con motosierra: trabaja con técnicas de trepa, sistemas de
aparejo y criterio técnico fundado en biología arbórea. Interviene en árboles de
alta complejidad y riesgo — sobre techos, cables, muros, espacios públicos.

**Zona:** Córdoba Capital, Sierras Chicas y Valle de Punilla.

## Qué tiene que lograr el sitio

En orden de prioridad:

1. **Que manden consultas por WhatsApp.** Es el canal real: el cliente saca una
   foto del árbol, la manda y arranca la conversación. Todo el sitio empuja ahí.
2. **Transmitir criterio técnico.** Es el diferencial y lo que justifica cobrar
   más que el del hacha. Municipios, countries y aseguradoras necesitan ver
   seriedad técnica antes de llamar.
3. **Mostrar trabajos hechos.** El antes/después es la prueba.

## A quién le habla

- Vecinos y propietarios de casas con árboles grandes
- Administraciones de countries y consorcios
- Municipios que necesitan criterio técnico para el arbolado público
- Empresas y constructoras

El primer grupo es el volumen; los otros tres son los trabajos grandes. El sitio
tiene que servirle a los dos: directo y fácil para el vecino, con suficiente
sustancia técnica para que un municipio lo tome en serio.

## La frase del hero

El diferencial, en una línea, sale del propio texto de Julio:

> "Lo que me diferencia no es solo subir a un árbol — es entender qué hay
> adentro de él."

Y su principio de trabajo:

> "Cada trabajo es planificado: no improvisamos, evaluamos."

Se pueden usar tal cual o como base.

## Estructura propuesta

Seis páginas:

| Página | Qué lleva |
| --- | --- |
| **Home** | Hero + los 5 servicios resumidos + zona de cobertura + 3-4 trabajos destacados + CTA de WhatsApp |
| **Servicios** | Las 5 fichas completas (poda y tala, cuidados preventivos, evaluación, complejidad y riesgo, jardinería) |
| **Trabajos realizados** | Galería antes/después |
| **Sobre mí** | El texto en primera persona de Julio |
| **Preguntas frecuentes** | El FAQ completo, en acordeón |
| **Contacto** | WhatsApp + teléfono + Instagram + formulario |

"Sobre nosotros" hoy está cargado como si fuera un servicio más — no lo es.
Va como página propia o como sección de la Home.

## Decisiones tomadas

- **Sin e-commerce.** Los 6 "productos" del sitio viejo están todos a $0 y son
  fichas de servicio. Nada de carrito, checkout, precios ni "agregar al carrito".
- **Sin blog.** La única entrada publicada es un texto de coaching sobre
  actitud, sin relación con arboricultura. No se migra.
- **Términos y condiciones: no se migra.** El texto actual es de otro negocio
  (una vinoteca) y no aplica. Sin e-commerce ni cuentas de usuario, tampoco hace
  falta — como mucho, una nota de privacidad corta si el formulario junta datos.
- **La evaluación técnica se cobra**, y el monto se descuenta si se contrata el
  trabajo. Conviene decirlo claro en el sitio: filtra consultas y transmite
  seriedad.

## Restricciones técnicas (importantes)

El resultado va a **Cloudflare Workers static assets**, así que:

- **HTML + CSS puro.** Sin React, sin Tailwind, sin build step.
- **Sin CDNs externos, sin Google Fonts, sin librerías.** Todo autocontenido.
  Si hace falta una tipografía, se auto-hospeda.
- **Mobile-first.** Casi todas las consultas llegan del celular.
- **Español rioplatense (voseo).** `lang="es-AR"`.
- **Un archivo HTML por página**, no todo en un solo archivo.

## Correcciones al contenido viejo

- El subtítulo de la Home dice **"Puniulla"** — va "Punilla".
- Los textos mezclan "vos" y "tú" ("Descubre nuestros servicios",
  "¿Tienes más dudas?"). Unificar todo en **voseo**.
- Sacar el "Valorado con 0 de 5" de las fichas: es basura de WooCommerce.

---

## Respuestas al cuestionario de Claude Design

| Pregunta | Respuesta |
| --- | --- |
| ¿Qué páginas lleva? | Home, Servicios, Trabajos realizados, Preguntas frecuentes, Contacto (+ Sobre mí). Sin Blog ni Términos. |
| ¿Una página larga o varias? | Varias páginas separadas |
| ¿Qué tiene que lograr? | Que manden más consultas por WhatsApp + transmitir profesionalismo técnico |
| ¿A quién le hablás? | Vecinos y propietarios, countries y consorcios, municipios, empresas/constructoras |
| ¿Cómo querés que te contacten? | WhatsApp + teléfono + formulario |
| El blog | Sacarlo |
| Términos y condiciones | Sacarlo (el actual es de otro negocio) |
| Zona de cobertura | Listado de localidades — sirve para SEO local |
| Tono | Mezcla: técnico en los servicios, cercano y directo en los CTAs |

**A confirmar por Julio antes de arrancar:**

- **Los cursos, ¿siguen activos?** La página del sitio viejo está vacía (sólo un
  shortcode de plugin). Si siguen, hay que escribir el contenido de cero; si no,
  se saca.
- **El "Manual Técnico para Clientes: Poda Segura" del Drive, ¿se publica?**
  Como recurso descargable puede funcionar muy bien para captar contactos de
  municipios y countries.
- **Las localidades exactas** de la zona de cobertura, para listarlas.
