# Análisis comparativo: Arborista Calamuchita vs. Poda en Altura AR

Relevado el 12-sep-2026 sobre las dos páginas en vivo.

- **Colega:** https://www.arboristacalamuchita.com.ar/ — Jonatan Meneses, Valle de Calamuchita.
- **Nuestro:** https://podaenaltura-ar.com.ar/ — Julio Barrientos Bolbochan, Córdoba Capital.

No competimos por la misma zona (él Calamuchita, nosotros Capital / Sierras Chicas /
Punilla), así que esto no es un rival directo: es la vara de qué se ve como un
arborista profesional en Córdoba hoy.

## Cómo se relevó

Chromium no puede salir a internet desde el entorno (el proxy le corta el túnel TLS,
aunque `curl` y `wget` sí pasan). Lo resuelto fue bajar las dos páginas completas con
`wget --page-requisites`, servirlas en localhost y fotografiarlas ahí:

```bash
wget --ca-certificate=/root/.ccr/ca-bundle.crt -e robots=off \
  --page-requisites --convert-links --adjust-extension \
  --span-hosts --domains=<dominio> -P <destino> <url>
npx http-server <destino>/<dominio> -p 8801
```

Todo hallazgo que dependía del espejo se volvió a verificar contra el sitio en vivo
con `curl`, porque el espejo miente en dos cosas: no baja recursos de CDNs externas
(por eso los testimonios del colega aparecían vacíos y **no lo están**) y marca como
rotas imágenes que sí responden 200.

## Números duros

| | Colega | Nuestro |
| --- | --- | --- |
| Plataforma | WordPress + Elementor | WordPress + Elementor + **WooCommerce** |
| Estructura | Una sola página larga (~17.800 px en móvil) | Multipágina, home corta (~3.300 px) |
| HTML de la home | 191 KB | **332 KB** |
| Peso total de la home | 13 MB / 111 archivos | **24 MB / 297 archivos** |
| `<script>` en el HTML | 33 | **103** |
| Hojas de estilo | 41 | **53** |
| TTFB | 0,75 s | 1,18 s |
| `lang` | `es-AR` | `es` |
| `<h1>` | **0** | 1 |
| Open Graph (preview al compartir) | sí (título, descripción, imagen) | **ninguno** |
| `sitemap_index.xml` | 200 | **404** |
| Reseñas de Google en el sitio | **103, calificación "Excelente"** | ninguna |
| Nombres de archivo de imagen | `poda-arboles-altura-calamuchita-29.jpg` | `IMG_20240730_141202.jpg` |

Comandos para rehacer las mediciones:

```bash
curl -sS -o /dev/null -w "ttfb=%{time_starttransfer}s size=%{size_download}\n" https://podaenaltura-ar.com.ar/
curl -sS -o /dev/null -w "%{http_code}\n" https://podaenaltura-ar.com.ar/sitemap_index.xml
curl -sS https://www.arboristacalamuchita.com.ar/ | grep -o 'A base de <strong>[0-9]* reseñas'
```

## Lo que el colega hace mejor

### 1. Prueba social verificable

Tiene un widget de Trustindex con **103 reseñas de Google** y calificación
"Excelente", con nombres y textos reales ("Excelente trabajo, cumplidor y muy limpio
y seguro para trabajar"). Nosotros no tenemos una sola reseña en el sitio.

Esto es lo más difícil de copiar y lo más caro de no tener. No se arregla con diseño.

### 2. Credenciales concretas, no adjetivos

Su bloque "Qué nos diferencia" lista cosas comprobables:

- Procedimientos bajo **normas ANSI Z133** (lo pone arriba de todo, sobre el hero).
- **Nivel 1 – AATAAC** (Asociación Argentina de Trabajadores del Árbol con Acceso por Cuerdas).
- **Nivel 2 – LCA** (La Casa del Arborista, Latinoamérica).
- Congresos universitarios de arboricultura – **UNC**.
- En el pie, el sello de miembro de la asociación.

Esto es exactamente el "criterio técnico" que el brief pone como diferencial nuestro
número 2 — y él lo tiene escrito y nosotros no.

### 3. Un camino claro hacia el contacto

Arriba del todo: botón naranja **"Solicitar Presupuesto"** y, más abajo, un
**"CONTACTAR POR WHATSAPP"** grande con el número a la vista. El link lleva mensaje
precargado:

```
https://api.whatsapp.com/send?phone=+5493546480747&text=Hola%20Jonatan!%20te%20contacto%20desde%20tu%20página%20web
```

El que consulta ya arranca la conversación escrita.

### 4. Historia con cara y nombre

"Nuestra historia" con foto de Jonatan trepado, su nombre, sus diez años de
experiencia. Visión, misión y lema. Da con quién se está hablando.

### 5. Cobertura dicha en palabras

"Cobertura: de Calamuchita a toda la provincia de Córdoba", repetido en el hero.

## Lo que nosotros hacemos mejor

1. **Las fotos.** La tira del hero — cuatro fotos reales de trabajo en altura, cielo
   azul, arnés, motosierra — es mejor material que el logo gigante sobre fondo verde
   que él pone arriba. Son fotos propias de trabajos hechos, no stock.
2. **Estructura semántica.** Tenemos un `<h1>` y seis `<h2>`; su página no tiene
   **ningún** `<h1>`: todo son `div`. Para Google eso es una página sin título interno.
3. **Página de trabajos realizados.** Él no tiene galería separada.
4. **Página de preguntas frecuentes propia** (él las mete en la home, lo cual también
   es defendible).
5. **Sitio más liviano de leer**: su home en móvil mide 17.800 px de alto. Son unos
   veinte scrolls de pantalla completa.

## Problemas concretos de nuestro sitio

Ordenados por lo que cuesta plata.

### 1. En el celular no se puede tocar para escribir por WhatsApp — CRÍTICO

Es el peor hallazgo. En la home, en un viewport de 390 px:

- El botón verde de WhatsApp del encabezado **desaparece** en móvil.
- El único enlace de WhatsApp que queda en el DOM está **oculto**
  (`http://wa.me/message/QEXUKCUSGG73P1`, a y=670, no visible).
- El menú hamburguesa abre y ofrece: Inicio, Servicios, Ayuda, Trabajos realizados,
  Contacto. **Ningún botón de contacto directo.**

O sea: el visitante de celular —que es la mayoría— no tiene un solo enlace tocable
para escribir. Tiene que abrir el menú, entrar a Contacto y buscar ahí. El colega
tiene un botón verde enorme con mensaje precargado.

El brief pone "que manden consultas por WhatsApp" como objetivo número 1 del sitio.
Hoy la home en celular no lo cumple.

### 2. Dos errores de tipeo en el subtítulo del hero

```
Cordoba Capital, Sierras Chicas y Valle de Puniulla
```

- **"Puniulla"** → es **Punilla**.
- **"Cordoba"** sin tilde → **Córdoba**.

Está en un `<h2>`, es decir en el texto que Google lee para decidir si aparecemos en
búsquedas locales. "Valle de Puniulla" no lo busca nadie.

Verificable con:

```bash
curl -sS https://podaenaltura-ar.com.ar/ | grep -o 'Valle de [A-Za-z]*'
```

### 3. Al compartir el link por WhatsApp no aparece vista previa

No hay **ninguna** etiqueta Open Graph: ni `og:title`, ni `og:description`, ni
`og:image`. Cuando Julio pega el link en un chat, sale la URL pelada. El colega tiene
las tres y sale una tarjeta con foto.

Siendo WhatsApp nuestro canal principal, esto es un agujero grande y de arreglo barato.

### 4. Un link a un negocio ajeno en el pie

En el pie de la home hay un enlace saliente a `https://centralweb.website/mabelplus/`.
Es del que hizo el sitio, pero apunta a otro cliente suyo.

### 5. Restos del theme de demostración

- Un `<iframe>` de Google Maps apuntando a **"Avenida San Martín 2784, Caseros,
  Provincia de Buenos Aires"**. Está oculto (un ancestro tiene `display:none`), así
  que el visitante no lo ve — pero está en el HTML que Google rastrea, y es una
  dirección a 700 km, en otra provincia.
- `https://podaenaltura-ar.com.ar/wp-content/uploads/2020/05/pose.png` responde **404**.

### 6. El WooCommerce se ve

Los seis servicios son "productos" y se nota: las tarjetas dicen **"Ver todo"** arriba
del título, el pie lista **"Todos los productos"**, la nav manda a `/tienda/` y hay
"Vista rápida" por todos lados. Parece una tienda a la que le sacaron los precios.
Ya está decidido que el rediseño lo saca; queda anotado como confirmación de que se ve
desde afuera, no sólo desde el código.

### 7. Castellano mezclado

- `lang="es"`, debería ser `es-AR`.
- **"Descubre nuestros servicios"** — tuteo. En voseo: *Descubrí*.
- El H1 en **Mayúscula En Cada Palabra** ("Expertos En Poda De Árboles De Alta
  Complejidad Y Riesgo") es una convención del inglés; en castellano se escribe
  "Expertos en poda de árboles de alta complejidad y riesgo".

(El colega tiene el mismo problema al revés: su tagline es **"PROFESSIONAL
HIGH-ALTITUDE PRUNING"**, en inglés, para clientes de Calamuchita, y su sección de
testimonios dice "¡**Vea** las opiniones…", ustedeo. No es un modelo a copiar en esto.)

### 8. El sitio pesa casi el doble

24 MB y 297 archivos contra 13 MB y 111. 103 scripts. Para alguien mirando desde el
celular con datos móviles en las Sierras, eso se siente.

## Qué me llevaría al rediseño

Lo que el colega demuestra que hay que tener, y que el rediseño debería resolver:

1. **WhatsApp tocable siempre.** Botón fijo flotante en móvil, más un bloque grande a
   media página. Con mensaje precargado:
   `https://wa.me/5493516507699?text=Hola%20Julio!%20te%20escribo%20desde%20la%20web`
2. **Un bloque de credenciales.** Formación, asociaciones, normas con las que se
   trabaja. Es el diferencial del brief y hoy no está escrito en ningún lado.
   → **Hace falta que Julio diga qué certificaciones y membresías tiene.** Sin eso el
   bloque no se puede escribir.
3. **Reseñas de Google.** Requiere tener ficha de Google Business con reseñas. Es la
   ventaja más grande del colega y la de plazo más largo: conviene empezar ya,
   independientemente del sitio.
4. **Open Graph completo** — título, descripción e imagen. Barato y de impacto directo
   en el canal principal.
5. **Cara y nombre.** Una foto de Julio trabajando, con nombre y trayectoria.
6. **Localidades escritas textualmente** — sigue siendo una de las tres preguntas
   abiertas del `CLAUDE.md`, y el colega la tiene resuelta en una línea.
7. **Nombres de archivo descriptivos** en las imágenes: `poda-altura-cordoba-01.webp`,
   no `IMG_20240730_141202.jpg`.

## Lo que NO copiaría

- La página única de 17.800 px. Es demasiado scroll en celular.
- El logo gigante ocupando toda la primera pantalla. Nuestras fotos de trabajo
  convierten mejor que un logo.
- El inglés decorativo en el tagline.
- Su falta de `<h1>`.
