# PICSIS SHOP

Catálogo e-commerce conectado a Loyverse POS con peces animados y compra por WhatsApp.

---

## Stack

- Next.js 14 (App Router) · React 18
- HTML5 Canvas (animación de peces)
- Web Audio API (sonidos de gota)
- Loyverse POS API (productos en tiempo real)
- Vercel (deploy automático desde GitHub)

---

## Estructura del proyecto

```
PICSISSHOP/
├── app/
│   ├── layout.jsx        ← Layout raíz — importa globals.css
│   ├── page.jsx          ← Página principal — llama a Loyverse y renderiza Catalog
│   └── globals.css       ← CSS global: grid de productos (4 col desktop / 1 col móvil)
├── lib/
│   └── loyverse.js       ← Conexión a Loyverse API (token, fetch de productos)
├── public/
│   ├── logopicsisshop.mp4        ← Video del logo animado
│   ├── frames-azul/              ← 10 PNGs del pez azul (fondo transparente)
│   │   └── azul_01.png … azul_10.png
│   └── frames-rosa/              ← 10 PNGs del pez rosa (fondo transparente)
│       └── rosa_01.png … rosa_10.png
├── AnimatedLogo.jsx      ← Componente del logo en video
├── AnimatedLogo.css      ← Estilos del logo hero
├── Catalog.jsx           ← Catálogo completo: filtros, grid, cards, temas por categoría
└── SwimmingFish.jsx      ← Animación canvas: peces, partículas de agua, sonido de gota
```

---

## Cosas que puedes modificar fácilmente

### Número de WhatsApp
En `Catalog.jsx`, línea con `WA_NUMBER`:
```js
const WA_NUMBER = "523481239175"; // formato: 52 + 10 dígitos
```

### Velocidad de los peces
En `SwimmingFish.jsx`, en el array `fish`:
```js
new FishState({ speed: 0.06, size: 190, ... }) // azul
new FishState({ speed: 0.05, size: 240, ... }) // rosa
```
- `speed` — qué tan rápido oscila la trayectoria (más bajo = más lento)
- `size` — tamaño en px del pez en canvas
- Velocidad máxima de nado: busca `MAX_SWIM = 55` (px/s)

### Grid de productos
En `app/globals.css`:
```css
.product-grid { grid-template-columns: repeat(4, 1fr); } /* desktop */
@media (max-width: 768px) { grid-template-columns: repeat(1, 1fr); } /* móvil */
```

### Banner de ofertas (velocidad del marquee)
En `Catalog.jsx`, busca:
```js
animation: "marquee 70s linear infinite"
```
Sube el número para hacerlo más lento.

### Temas de colores por categoría
En `Catalog.jsx`, objeto `CATEGORY_THEMES` — cada categoría tiene su propio color de acento, fondo y degradado.

### Descuentos desde Loyverse
Agrega `Descuento: 30` en la descripción del producto en Loyverse (sin símbolo %).  
El sistema lo lee automáticamente y muestra el banner de oferta.

---

## Deploy

1. Push a GitHub → Vercel despliega automáticamente
2. Variable de entorno requerida en Vercel: `LOYVERSE_TOKEN` con tu API token de Loyverse

## Flujo de trabajo local → producción

```bash
# 1. Editar archivos en Cowork (OneDrive)
# 2. Copiar a WSL
SRC="/mnt/c/Users/alcal/OneDrive/Documents/TIENDA/PICSISSHOP"
cp "$SRC/NombreArchivo.jsx" ~/proyectos/PICSISSHOP/NombreArchivo.jsx

# 3. Push
cd ~/proyectos/PICSISSHOP
git add -A
git commit -m "descripción del cambio"
git push
```
