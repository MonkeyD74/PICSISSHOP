#!/bin/bash
# ─────────────────────────────────────────────────────────────
# sync.sh — Sincroniza archivos de OneDrive → WSL y hace push
# Uso: bash sync.sh "descripcion del cambio"
# ─────────────────────────────────────────────────────────────

REPO="$HOME/proyectos/PICSISSHOP"
SRC="/mnt/c/Users/alcal/OneDrive/Documents/TIENDA/PICSISSHOP"
MSG="${1:-update}"

echo "📂 Copiando archivos..."
cp "$SRC/AnimatedLogo.jsx"   "$REPO/AnimatedLogo.jsx"
cp "$SRC/AnimatedLogo.css"   "$REPO/AnimatedLogo.css"
cp "$SRC/Catalog.jsx"        "$REPO/Catalog.jsx"
cp "$SRC/SwimmingFish.jsx"   "$REPO/SwimmingFish.jsx"
cp "$SRC/app/globals.css"    "$REPO/app/globals.css"
cp "$SRC/app/layout.jsx"     "$REPO/app/layout.jsx"
cp "$SRC/app/page.jsx"       "$REPO/app/page.jsx"
cp "$SRC/lib/loyverse.js"    "$REPO/lib/loyverse.js"
cp "$SRC/README.md"          "$REPO/README.md"

echo "📦 Haciendo commit y push..."
cd "$REPO"
git add AnimatedLogo.jsx AnimatedLogo.css Catalog.jsx SwimmingFish.jsx \
        app/globals.css app/layout.jsx app/page.jsx lib/loyverse.js README.md
git commit -m "$MSG"
git push

echo "✅ Listo — Vercel desplegará en ~1 min"
