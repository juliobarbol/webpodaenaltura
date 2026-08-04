# Poda en Altura AR — sitio web

Sitio estático servido con [Cloudflare Workers static assets](https://developers.cloudflare.com/workers/static-assets/).

## Desarrollo local

```bash
npm install
npm run dev
```

Abre `http://localhost:8787`. Los archivos de `public/` se sirven tal cual;
editás y refrescás.

## Deploy

Hay dos caminos. **Elegí uno solo** y quedate con ese.

### Opción A — Workers Builds (recomendado)

Cloudflare mira el repo de GitHub y deploya solo en cada push a la rama
principal. No hay que guardar ningún token en el repo.

1. En el dashboard de Cloudflare: **Workers & Pages → Create → Import a repository**.
2. Elegí `juliobarbol/webpodaenaltura`.
3. Deploy command: `npx wrangler deploy`. Build command: dejalo vacío.
4. Cuando pida el API token, ver la sección de abajo.

### Opción B — GitHub Actions

Requiere crear el token vos y guardarlo como secret `CLOUDFLARE_API_TOKEN`
del repo. Sólo tiene sentido si querés correr tests o pasos propios antes
de publicar.

## API token

Usá **un token dedicado a este proyecto** (por ejemplo `webpodaenaltura-deploy`),
no el global key ni un token compartido con otras cosas. Así lo podés revocar o
rotar sin romper nada más.

Permisos mínimos:

| Scope   | Permiso                                                     |
| ------- | ----------------------------------------------------------- |
| Account | Workers Scripts → **Edit**                                  |
| Account | Account Settings → **Read**                                 |
| User    | User Details → **Read**, Memberships → **Read**             |
| Zone    | Workers Routes → **Edit**, acotado a `podaenaltura-ar.com.ar` |

KV y R2 se agregan sólo el día que se usen. Usá siempre el mismo token para
todos los deploys de este Worker.

## Migrar el dominio

El sitio va a andar en `webpodaenaltura.<tu-subdominio>.workers.dev` desde el
primer deploy, sin tocar DNS. Para pasar `podaenaltura-ar.com.ar`:

1. Agregá el dominio como zona en Cloudflare y cambiá los nameservers en el
   registrador. Esperá a que la zona figure como **Active**.
2. Descomentá el bloque `routes` en `wrangler.jsonc`.
3. `npm run deploy`.

Hacelo **último**, con el sitio nuevo ya validado en `workers.dev` — es el único
paso con downtime potencial y el que corta con el WordPress actual.
