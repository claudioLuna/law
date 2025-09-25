#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${ROOT_DIR}/dist/AI-Accounting-n8n-Dokploy.pdf"
mkdir -p "${ROOT_DIR}/dist"

if command -v pandoc >/dev/null 2>&1; then
  pandoc -f gfm -t pdf -o "$OUT" "${ROOT_DIR}/README_DOKPLOY.md"
  echo "PDF generado: $OUT"
  exit 0
fi

echo "pandoc no está instalado. Ejecuta con Docker..."
docker run --rm -v "${ROOT_DIR}:/data" pandoc/core:3.1 -f gfm -t pdf -o /data/dist/AI-Accounting-n8n-Dokploy.pdf /data/README_DOKPLOY.md
echo "PDF generado: $OUT"

