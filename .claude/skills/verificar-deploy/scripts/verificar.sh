#!/usr/bin/env bash
# Compara cada archivo de public/ contra lo que sirve una URL desplegada.
# Uso: verificar.sh https://webpodaenaltura.algo.workers.dev
#
# Sale 0 sólo si todos los archivos coinciden byte a byte.

set -uo pipefail

BASE="${1:-}"
if [ -z "$BASE" ]; then
  echo "uso: $0 <url-base>" >&2
  exit 2
fi
BASE="${BASE%/}"

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo .)"
PUB="$REPO_ROOT/public"
if [ ! -d "$PUB" ]; then
  echo "no encuentro $PUB" >&2
  exit 2
fi

ok=0; mal=0; falta=0

while IFS= read -r -d '' f; do
  rel="${f#"$PUB"/}"

  # .assetsignore no se publica; es config de wrangler, no contenido.
  [ "$rel" = ".assetsignore" ] && continue

  local_hash="$(sha256sum "$f" | cut -d' ' -f1)"

  # Cloudflare sirve `dir/index.html` también como `dir/`. Probamos la ruta
  # literal y, si es un index.html, la URL limpia.
  urls=("$BASE/$rel")
  case "$rel" in
    index.html)   urls+=("$BASE/") ;;
    */index.html) urls+=("$BASE/${rel%index.html}") ;;
  esac

  remote_hash=""
  for u in "${urls[@]}"; do
    h="$(curl -fsSL --max-time 20 "$u" 2>/dev/null | sha256sum | cut -d' ' -f1)"
    # sha256 de vacío: la respuesta no trajo cuerpo
    if [ -n "$h" ] && [ "$h" != "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" ]; then
      remote_hash="$h"
      break
    fi
  done

  if [ -z "$remote_hash" ]; then
    printf '  FALTA    %s\n' "$rel"
    falta=$((falta+1))
  elif [ "$remote_hash" = "$local_hash" ]; then
    printf '  ok       %s\n' "$rel"
    ok=$((ok+1))
  else
    printf '  DISTINTO %s\n' "$rel"
    mal=$((mal+1))
  fi
done < <(find "$PUB" -type f -print0 | sort -z)

echo
echo "iguales: $ok   distintos: $mal   sin respuesta: $falta"

commit="$(git -C "$REPO_ROOT" rev-parse --short HEAD 2>/dev/null || echo '?')"

if [ "$mal" -eq 0 ] && [ "$falta" -eq 0 ]; then
  echo "OK — $BASE está sirviendo el commit $commit"
  exit 0
fi

echo "FALLA — lo servido NO coincide con el commit $commit"
echo "Si recién desplegaste, esperá un minuto (caché de borde) y reintentá."
exit 1
