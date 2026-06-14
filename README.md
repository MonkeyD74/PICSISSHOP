# PICSIS SHOP 🐟

Catálogo e-commerce conectado a Loyverse POS con peces koi animados y compra por WhatsApp.

**Deploy:** [github.com/MonkeyD74/PICSISSHOP](https://github.com/MonkeyD74/PICSISSHOP) → Vercel (auto)

---

## Flujo de trabajo

Editar en Cowork (OneDrive) → copiar a WSL → push → Vercel despliega solo.

```bash
# Desde WSL — sincroniza todo y hace push en un solo comando:
bash /mnt/c/Users/alcal/OneDrive/Documents/TIENDA/PICSISSHOP/sync.sh "descripción del cambio"
```

---

## Estructura

```
PICSISSHOP/
├── app/
│   ├── layout.jsx        ← Layout raíz — importa globals.css
│   ├── page.jsx          ← Llama a Loyverse y renderiza Catalog
│   └── globals.css       ← Grid de productos + estilos globales
├── lib/
│   └── loyverse.js       ← API de Loyverse (token, fetch, parseo)
├── public/
│   ├── logopicsisshop.mp4        ← Video del logo (solo en WSL/repo)
│   ├── frames-azul/azul_01-10.png ← Frames pez azul transparente
│   └── frames-rosa/rosa_01-10.png ← Frames pez rosa transparente
├── AnimatedLogo.jsx/css  ← Componente del logo en video
├── Catalog.jsx           ← Catálogo: filtros, grid, cards, temas
├── SwimmingFish.jsx      ← Peces animados en canvas: movimiento, sonido, partículas
├── sync.sh               ← Script para sincronizar OneDrive → WSL → GitHub
└── README.md
```

---

## Qué modificar y dónde

| Qué quieres cambiar | Archivo | Qué buscar |
|---|---|---|
| Número de WhatsApp | `Catalog.jsx` | `WA_NUMBER` |
| Velocidad peces | `SwimmingFish.jsx` | `speed: 0.06` / `MAX_SWIM = 55` |
| Tamaño peces | `SwimmingFish.jsx` | `size: 190` (azul) / `size: 240` (rosa) |
| Transparencia peces | `SwimmingFish.jsx` | `this.opacity * 0.6` |
| Columnas del grid | `app/globals.css` | `grid-template-columns` |
| Velocidad del banner | `Catalog.jsx` | `marquee 70s` |
| Colores por categoría | `Catalog.jsx` | `CATEGORY_THEMES` |
| Descuentos Loyverse | Loyverse (descripción) | Agregar línea `Descuento: 30` |
| Caché de productos | `lib/loyverse.js` | `revalidate: 300` (segundos) |

---

## Variables de entorno (Vercel)

| Variable | Valor |
|---|---|
| `LOYVERSE_TOKEN` | Tu token de API de Loyverse |

---

## Stack

- Next.js 14 (App Router) · React 18
- HTML5 Canvas — animación de peces
- Web Audio API — sonido de gota al tocar pez
- Loyverse POS API — productos en tiempo real
- Vercel — deploy automático desde GitHub
