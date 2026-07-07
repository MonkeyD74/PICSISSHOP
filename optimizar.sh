#!/data/data/com.termux/files/usr/bin/bash
# ══════════════════════════════════════════════════════════════
#  PISCIS SHOP — Optimización de carga y despliegue de productos
#  Ejecutar DENTRO de la carpeta del repo PICSISSHOP en Termux:
#    bash optimizar.sh
# ══════════════════════════════════════════════════════════════
set -e

if [ ! -f "Catalog.jsx" ] || [ ! -d "app" ]; then
  echo "❌ Ejecuta este script dentro de la carpeta del repo PICSISSHOP"
  exit 1
fi

echo "→ 1/5 Escribiendo archivos optimizados..."
cat > Catalog.jsx << 'PISCIS_EOF_MARK'
"use client"
import RecompensasSection from "./components/RecompensasSection"

import { useState, useMemo, useEffect, useRef } from "react";
import { Swiper, SwiperSlide } from "swiper/react";
import { EffectCoverflow, Pagination, Navigation } from "swiper/modules";
import "swiper/css";
import "swiper/css/effect-coverflow";
import "swiper/css/pagination";
import "swiper/css/navigation";
import AnimatedLogo from "./AnimatedLogo";
import SwimmingFish from "./SwimmingFish";

// Tema visual por categoría
const CATEGORY_THEMES = {
  Todos: {
    bg: "#111111", bgCard: "#1a1a1a", bgElevated: "#222222", border: "#2a2a2a",
    text: "#f0f0f0", textMuted: "#888888", textDim: "#555555",
    accent: "#c8ff00", accentBg: "rgba(200,255,0,0.08)",
    gradient: "linear-gradient(180deg, #1a1a1a 0%, #111 100%)",
    subtitle: "Catálogo 2026", title: "Nuestra Colección", icon: "",
  },
  Hombres: {
    bg: "#0f1114", bgCard: "#181b20", bgElevated: "#22262d", border: "#2a3040",
    text: "#e8ecf0", textMuted: "#8090a0", textDim: "#506070",
    accent: "#4dabf7", accentBg: "rgba(77,171,247,0.1)",
    gradient: "linear-gradient(180deg, #151a22 0%, #0f1114 100%)",
    subtitle: "◆ Colección Masculina ◆", title: "Para Ellos", icon: "♂",
  },
  Mujeres: {
    bg: "#1a1019", bgCard: "#241c26", bgElevated: "#2e2530", border: "#3d2f42",
    text: "#f5eaf0", textMuted: "#b8a0b0", textDim: "#7a6578",
    accent: "#f472b6", accentBg: "rgba(244,114,182,0.1)",
    gradient: "linear-gradient(180deg, #2e1a2e 0%, #1a1019 100%)",
    subtitle: "✦ Colección Femenina ✦", title: "Para Ella", icon: "♀",
  },
  Calzado: {
    bg: "#13110f", bgCard: "#1c1914", bgElevated: "#26221a", border: "#3a3228",
    text: "#f0e8d8", textMuted: "#a09080", textDim: "#605040",
    accent: "#FFD700", accentBg: "rgba(255,215,0,0.08)",
    gradient: "linear-gradient(180deg, #1e1a12 0%, #13110f 100%)",
    subtitle: "👟 Colección Calzado", title: "A Tu Paso", icon: "👟",
  },
  Electrónica: {
    bg: "#0d1117", bgCard: "#161b22", bgElevated: "#1f2937", border: "#253040",
    text: "#e6edf3", textMuted: "#7d8fa0", textDim: "#4a5a6a",
    accent: "#00d4ff", accentBg: "rgba(0,212,255,0.08)",
    gradient: "linear-gradient(180deg, #141c28 0%, #0d1117 100%)",
    subtitle: "⚡ Tech & Gadgets", title: "Electrónica", icon: "⚡",
  },
  Hogar: {
    bg: "#14120f", bgCard: "#1d1a15", bgElevated: "#28241c", border: "#38322a",
    text: "#f0ebe0", textMuted: "#a09585", textDim: "#6a5f50",
    accent: "#ff9f43", accentBg: "rgba(255,159,67,0.08)",
    gradient: "linear-gradient(180deg, #1e1a14 0%, #14120f 100%)",
    subtitle: "🏠 Confort & Estilo", title: "Tu Hogar", icon: "🏠",
  },
  Deportes: {
    bg: "#0f1210", bgCard: "#171d18", bgElevated: "#202820", border: "#2a3a2c",
    text: "#e8f0e8", textMuted: "#80a080", textDim: "#506850",
    accent: "#00e676", accentBg: "rgba(0,230,118,0.08)",
    gradient: "linear-gradient(180deg, #141e16 0%, #0f1210 100%)",
    subtitle: "💪 Fuerza & Rendimiento", title: "Deportes", icon: "💪",
  },
  Electronicos: {
    bg: "#0d1117", bgCard: "#161b22", bgElevated: "#1f2937", border: "#253040",
    text: "#e6edf3", textMuted: "#7d8fa0", textDim: "#4a5a6a",
    accent: "#00d4ff", accentBg: "rgba(0,212,255,0.08)",
    gradient: "linear-gradient(180deg, #141c28 0%, #0d1117 100%)",
    subtitle: "⚡ Tech & Gadgets", title: "Electrónicos", icon: "⚡",
  },
  Herramientas: {
    bg: "#141008", bgCard: "#1e1810", bgElevated: "#2a2216", border: "#3a3020",
    text: "#f0e8d0", textMuted: "#a09070", textDim: "#706040",
    accent: "#f59e0b", accentBg: "rgba(245,158,11,0.08)",
    gradient: "linear-gradient(180deg, #201a0e 0%, #141008 100%)",
    subtitle: "🔧 Equipo & Herramientas", title: "Herramientas", icon: "🔧",
  },
  Juguetes: {
    bg: "#120d1a", bgCard: "#1c1528", bgElevated: "#261d36", border: "#3a2a50",
    text: "#f0e8ff", textMuted: "#b090d0", textDim: "#7050a0",
    accent: "#a855f7", accentBg: "rgba(168,85,247,0.08)",
    gradient: "linear-gradient(180deg, #1e1430 0%, #120d1a 100%)",
    subtitle: "🎮 Diversión & Juegos", title: "Juguetes", icon: "🎮",
  },
};

const CAT_PILL_COLORS_BY_NAME = {
  Todos: { bg: "#1e1e1e", text: "#888" },
  Hombres: { bg: "rgba(77,171,247,0.12)", text: "#4dabf7" },
  Mujeres: { bg: "rgba(244,114,182,0.12)", text: "#f472b6" },
  Calzado: { bg: "rgba(255,215,0,0.10)", text: "#FFD700" },
  Electrónica: { bg: "rgba(0,212,255,0.10)", text: "#00d4ff" },
  Hogar: { bg: "rgba(255,159,67,0.10)", text: "#ff9f43" },
  Deportes: { bg: "rgba(0,230,118,0.10)", text: "#00e676" },
  Electronicos: { bg: "rgba(0,212,255,0.10)", text: "#00d4ff" },
  Herramientas: { bg: "rgba(245,158,11,0.10)", text: "#f59e0b" },
  Juguetes: { bg: "rgba(168,85,247,0.10)", text: "#a855f7" },
};
const DEFAULT_PILL = { bg: "#1e1e1e", text: "#aaa" };

const SHOE_TIERS = [
  { name: "Bronce", max: 800, color: "#CD7F32", glow: "rgba(205,127,50,0.35)", icon: "🥉" },
  { name: "Plata", max: 1100, color: "#C0C0C0", glow: "rgba(192,192,192,0.35)", icon: "🥈" },
  { name: "Oro", max: 1600, color: "#FFD700", glow: "rgba(255,215,0,0.35)", icon: "🥇" },
  { name: "Diamante", max: 2200, color: "#b9f2ff", glow: "rgba(185,242,255,0.4)", icon: "💎" },
  { name: "Diamante Elite", max: Infinity, color: "#e0c3fc", glow: "rgba(224,195,252,0.45)", icon: "👑" },
];

function getShoeTier(price) {
  return SHOE_TIERS.find((t) => price < t.max) || SHOE_TIERS[SHOE_TIERS.length - 1];
}

// Descuento desde Loyverse: agrega "Descuento: 30" en la descripción del producto
function getDiscount(specs) {
  const val = parseInt(specs?.Descuento);
  return isNaN(val) ? 0 : val;
}

const WA_NUMBER = "523521444391";

const fmt = (n) => new Intl.NumberFormat("es-MX", { style: "currency", currency: "MXN" }).format(n);

function buildWhatsAppURL(product, selectedSize) {
  const sizeText = selectedSize ? ` | Talla/Opción: ${selectedSize}` : "";
  const msg =
    `Hola, me interesa este producto:\n\n` +
    `📦 *${product.name}*\n` +
    `💰 Precio: ${fmt(product.price)}${sizeText}\n` +
    (product.image ? `🖼️ ${product.image}\n` : "") +
    `\n¿Me pueden dar informes?`;
  return `https://wa.me/${WA_NUMBER}?text=${encodeURIComponent(msg)}`;
}

function TierBadge({ tier }) {
  return (
    <div style={{ position: "absolute", top: 12, right: 12, background: "rgba(0,0,0,0.7)", backdropFilter: "blur(6px)", borderRadius: 20, padding: "4px 10px", display: "flex", alignItems: "center", gap: 4, zIndex: 2, border: `1px solid ${tier.color}40` }}>
      <span style={{ fontSize: 12 }}>{tier.icon}</span>
      <span style={{ color: tier.color, fontSize: 10, fontWeight: 700, letterSpacing: 0.5, textTransform: "uppercase" }}>{tier.name}</span>
    </div>
  );
}

const PLACEHOLDER_IMG = "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='400' height='400'%3E%3Crect fill='%231a1a1a' width='400' height='400'/%3E%3Ctext x='50%25' y='50%25' dominant-baseline='middle' text-anchor='middle' fill='%23444' font-size='48'%3E📷%3C/text%3E%3C/svg%3E";

const WA_ICON = (
  <svg width="16" height="16" viewBox="0 0 24 24" fill="#fff"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/></svg>
);

function ProductCard({ product, theme, discount }) {
  const [hovered, setHovered] = useState(false);
  const [selectedSize, setSelectedSize] = useState(product.sizes[0] || null);
  const [showSpecs, setShowSpecs] = useState(false);
  const [imgError, setImgError] = useState(false);
  const [lightbox, setLightbox] = useState(false);
  const [zoom, setZoom] = useState(1);
  const [rotation, setRotation] = useState(0);

  const isCalzado = product.category === "Calzado";
  const tier = isCalzado ? getShoeTier(product.price) : null;

  // Color propio de la categoría del producto (no del filtro activo)
  const productTheme = CATEGORY_THEMES[product.category] || CATEGORY_THEMES.Todos;
  const accentColor = isCalzado ? tier.color : productTheme.accent;

  const cardBorder = isCalzado ? `2px solid ${tier.color}` : `1.5px solid ${accentColor}40`;
  const cardGlow = isCalzado ? tier.glow : `${accentColor}20`;
  const cardShadow = hovered
    ? `0 8px 32px ${cardGlow}, 0 0 0 1px ${accentColor}30`
    : `0 0 0 0 transparent`;

  const waURL = buildWhatsAppURL(product, selectedSize);
  const imgSrc = !product.image || imgError ? PLACEHOLDER_IMG : product.image;
  const hasSpecs = Object.keys(product.specs || {}).length > 0;

  return (
    <>
    <div data-product-card="true" onMouseEnter={() => setHovered(true)} onMouseLeave={() => setHovered(false)} style={{
      background: theme.bgCard, borderRadius: 14, overflow: "hidden", border: cardBorder,
      transition: "all .4s ease", transform: hovered ? "translateY(-4px)" : "none", boxShadow: cardShadow,
    }}>
      <div style={{ position: "relative", overflow: "hidden", aspectRatio: "1", background: theme.bg }}>
        <img src={imgSrc} alt={product.name} loading="lazy" decoding="async" onError={() => setImgError(true)}
          onClick={() => { setLightbox(true); setZoom(1); setRotation(0); }}
          style={{ width: "100%", height: "100%", objectFit: "cover", transition: "transform .5s ease", transform: hovered ? "scale(1.08)" : "scale(1)", cursor: "zoom-in" }} />
        {/* Pill de categoría con el color propio */}
        <span style={{
          position: "absolute", top: 12, left: 12, background: accentColor,
          color: "#111", fontSize: 10, fontWeight: 700, padding: "4px 10px", borderRadius: 20,
          textTransform: "uppercase", letterSpacing: 1, zIndex: 2
        }}>{product.category}</span>
        {isCalzado && <TierBadge tier={tier} />}
        {isCalzado && <div style={{ position: "absolute", bottom: 0, left: 0, right: 0, height: "40%", background: `linear-gradient(transparent, ${tier.color}10)`, pointerEvents: "none" }} />}
      </div>

      <div style={{ padding: "18px 18px 20px" }}>
        <h3 style={{ color: theme.text, fontSize: 15, margin: "0 0 12px", fontWeight: 600, fontFamily: "'Playfair Display', serif", lineHeight: 1.3 }}>{product.name}</h3>

        {/* Botón único: oferta con descuento O consulta de precio — ambos llevan directo a WA */}
        {discount > 0 ? (
          <a href={waURL} target="_blank" rel="noopener noreferrer" style={{
            display: "flex", alignItems: "center", justifyContent: "space-between",
            background: "linear-gradient(135deg, #0066ff 0%, #0033cc 100%)",
            borderRadius: 10, padding: "10px 14px", marginBottom: 12,
            boxShadow: "0 4px 18px rgba(255,45,85,0.35)", animation: "pulse 2s infinite",
            textDecoration: "none", cursor: "pointer",
          }}>
            <div>
              <p style={{ color: "#fff", fontSize: 11, fontWeight: 700, margin: 0, letterSpacing: 1.5, textTransform: "uppercase" }}>🔥 Oferta Especial</p>
              <p style={{ color: "#fff", fontSize: 26, fontWeight: 900, margin: "2px 0 0", lineHeight: 1 }}>{discount}% OFF</p>
            </div>
            <div style={{ textAlign: "right" }}>
              {WA_ICON}
              <p style={{ color: "#ffe066", fontSize: 12, fontWeight: 700, margin: "4px 0 0" }}>Pedir informes</p>
            </div>
          </a>
        ) : (
          <a href={waURL} target="_blank" rel="noopener noreferrer" style={{
            display: "flex", alignItems: "center", justifyContent: "space-between",
            background: `${accentColor}15`, border: `1.5px solid ${accentColor}50`,
            borderRadius: 10, padding: "10px 14px", marginBottom: 12,
            textDecoration: "none", cursor: "pointer", transition: "background .2s",
          }}>
            <div>
              <p style={{ color: accentColor, fontSize: 11, fontWeight: 700, margin: 0, letterSpacing: 1.5, textTransform: "uppercase" }}>Precio especial</p>
              <p style={{ color: "#fff", fontSize: 14, fontWeight: 700, margin: "4px 0 0" }}>Consultar por WhatsApp</p>
            </div>
            <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 4 }}>
              {WA_ICON}
              <span style={{ color: accentColor, fontSize: 18 }}>💬</span>
            </div>
          </a>
        )}

        {product.sizes.length > 0 && (
          <div style={{ marginBottom: 14 }}>
            <p style={{ color: theme.textDim, fontSize: 11, margin: "0 0 6px", textTransform: "uppercase", letterSpacing: 1 }}>Tallas</p>
            <div style={{ display: "flex", gap: 6, flexWrap: "wrap" }}>
              {product.sizes.map((s) => (
                <button key={s} onClick={() => setSelectedSize(s)} style={{
                  background: selectedSize === s ? accentColor : theme.bgElevated,
                  color: selectedSize === s ? "#111" : theme.textMuted,
                  border: "none", borderRadius: 6, padding: "5px 12px", fontSize: 12,
                  fontWeight: 600, cursor: "pointer", transition: "all .15s ease"
                }}>{s}</button>
              ))}
            </div>
          </div>
        )}

        {hasSpecs && (
          <>
            <button onClick={() => setShowSpecs(!showSpecs)} style={{
              background: "none", border: "none", color: theme.textMuted, fontSize: 12, cursor: "pointer",
              padding: 0, marginBottom: showSpecs ? 10 : 14, display: "flex", alignItems: "center", gap: 4
            }}>
              <span style={{ transform: showSpecs ? "rotate(90deg)" : "none", transition: "transform .2s", display: "inline-block" }}>▸</span>
              Especificaciones
            </button>
            {showSpecs && (
              <div style={{ background: theme.bg, borderRadius: 8, padding: 12, marginBottom: 14, border: `1px solid ${theme.border}`, animation: "fadeIn .2s ease" }}>
                {Object.entries(product.specs).map(([k, v]) => (
                  <div key={k} style={{ display: "flex", justifyContent: "space-between", padding: "4px 0", borderBottom: `1px solid ${theme.bgElevated}` }}>
                    <span style={{ color: theme.textMuted, fontSize: 12 }}>{k}</span>
                    <span style={{ color: "#ccc", fontSize: 12, fontWeight: 500 }}>{v}</span>
                  </div>
                ))}
              </div>
            )}
          </>
        )}
      </div>
    </div>

    {/* ── Lightbox visor de imagen ── */}
    {lightbox && (
      <div onClick={() => setLightbox(false)} style={{
        position: "fixed", inset: 0, zIndex: 9999,
        background: "rgba(0,0,0,0.92)", display: "flex",
        flexDirection: "column", alignItems: "center", justifyContent: "center",
      }}>
        {/* Imagen — rueda del mouse para zoom en desktop */}
        <img src={imgSrc} alt={product.name}
          onClick={e => e.stopPropagation()}
          onWheel={e => { e.stopPropagation(); setZoom(z => Math.min(Math.max(z - e.deltaY * 0.001, 0.5), 4)); }}
          style={{
            maxWidth: "90vw", maxHeight: "75vh", objectFit: "contain",
            borderRadius: 12, boxShadow: "0 0 60px #0008",
            transform: `scale(${zoom}) rotate(${rotation}deg)`,
            transition: "transform 0.2s ease",
            userSelect: "none", cursor: "grab",
          }} />

        {/* Solo botón cerrar */}
        <button onClick={e => { e.stopPropagation(); setLightbox(false); }} style={{
          marginTop: 20, background: "#ef444430", border: "1px solid #ef444460",
          color: "#fca5a5", borderRadius: 10, padding: "10px 24px",
          fontSize: 18, cursor: "pointer",
        }}>✕ Cerrar</button>

        <p style={{ color: "#ffffff40", fontSize: 11, marginTop: 12 }}>
          📱 Pellizca para zoom · 🖥️ Rueda del mouse · Toca fuera para cerrar
        </p>
      </div>
    )}
    </>
  );
}

const WA_PEZOS = `https://wa.me/523521444391?text=${encodeURIComponent("Hola, quiero información sobre los PEZOS 💎")}`

export default function Catalog({ products, categories, error }) {
  const [category, setCategory] = useState("Todos");
  const [search, setSearch] = useState("");
  const [sortBy, setSortBy] = useState("default");
  const [pezosModal, setPezosModal] = useState(false);
  const [pezosBurst, setPezosBurst] = useState(false);

  function handlePezosClick() {
    // Sonido de burbuja via Web Audio API
    try {
      const ctx = new (window.AudioContext || window.webkitAudioContext)()
      const osc = ctx.createOscillator()
      const gain = ctx.createGain()
      osc.connect(gain)
      gain.connect(ctx.destination)
      osc.type = "sine"
      osc.frequency.setValueAtTime(700, ctx.currentTime)
      osc.frequency.exponentialRampToValueAtTime(120, ctx.currentTime + 0.18)
      gain.gain.setValueAtTime(0.45, ctx.currentTime)
      gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.28)
      osc.start(ctx.currentTime)
      osc.stop(ctx.currentTime + 0.28)
    } catch(e) {}
    // Animación burst → luego abre modal
    setPezosBurst(true)
    setTimeout(() => { setPezosBurst(false); setPezosModal(true) }, 420)
  }

  const theme = CATEGORY_THEMES[category] || CATEGORY_THEMES.Todos;

  const filtered = useMemo(() => {
    let list = products;
    if (category !== "Todos") list = list.filter((p) => p.category === category);
    if (search) list = list.filter((p) => p.name.toLowerCase().includes(search.toLowerCase()));
    if (sortBy === "priceAsc") list = [...list].sort((a, b) => a.price - b.price);
    if (sortBy === "priceDesc") list = [...list].sort((a, b) => b.price - a.price);
    return list;
  }, [category, search, sortBy, products]);

  // ── Carga por lotes: renderiza 12 y agrega más al hacer scroll ──
  const BATCH = 12;
  const [visibleCount, setVisibleCount] = useState(BATCH);
  const sentinelRef = useRef(null);
  useEffect(() => { setVisibleCount(BATCH); }, [category, search, sortBy]);
  useEffect(() => {
    const el = sentinelRef.current;
    if (!el || visibleCount >= filtered.length) return;
    const io = new IntersectionObserver(
      (entries) => { if (entries[0].isIntersecting) setVisibleCount((c) => c + BATCH); },
      { rootMargin: "700px" }
    );
    io.observe(el);
    return () => io.disconnect();
  }, [visibleCount, filtered.length]);
  const visibleProducts = filtered.slice(0, visibleCount);

  // Destacados: productos con descuento primero; si no hay suficientes, primeros 8
  const featured = useMemo(() => {
    const withDiscount = products.filter((p) => getDiscount(p.specs) > 0);
    return withDiscount.length >= 3 ? withDiscount.slice(0, 10) : products.slice(0, 8);
  }, [products]);

  // ── Burbujas flotantes que suben del nav ───────────────────────
  const bubbleContainerRef = useRef(null);
  useEffect(() => {
    const colors = categories.map((c) => (CATEGORY_THEMES[c] || CATEGORY_THEMES.Todos).accent);
    const container = bubbleContainerRef.current;
    if (!container) return;

    const spawn = () => {
      const el = document.createElement("div");
      const color   = colors[Math.floor(Math.random() * colors.length)];
      const size    = 7 + Math.random() * 15;          // 7-22 px
      const x       = 4 + Math.random() * 92;          // % horizontal
      const dur     = 1600 + Math.random() * 1800;     // ms
      el.style.cssText = `
        position:absolute; bottom:0; left:${x}%;
        width:${size}px; height:${size}px; border-radius:50%;
        background:${color}22; border:1px solid ${color}44;
        box-shadow:0 0 ${size * 0.6}px ${color}33;
        pointer-events:none;
        animation:floatUp ${dur}ms ease-out forwards;
      `;
      container.appendChild(el);
      setTimeout(() => el.remove(), dur + 120);
    };

    const id = setInterval(spawn, 380);
    return () => clearInterval(id);
  }, [categories]);

  return (
    <>
      <style>{`
        @keyframes fadeIn  { from { opacity:0 } to { opacity:1 } }
        @keyframes pulse   { 0%,100% { box-shadow:0 4px 18px rgba(255,45,85,.35) } 50% { box-shadow:0 4px 28px rgba(255,45,85,.65) } }
        @keyframes marquee { from { transform:translateX(0%) } to { transform:translateX(-100%) } }
        @keyframes bubbleGlow { 0%,100% { box-shadow:0 0 10px var(--bub-color,#fff3), 0 4px 20px var(--bub-color,#fff1) } 50% { box-shadow:0 0 22px var(--bub-color,#fff5), 0 6px 28px var(--bub-color,#fff2) } }
        @keyframes bubblePop  { 0% { transform:translateY(0) scale(1) } 40% { transform:translateY(-5px) scale(1.08) } 100% { transform:translateY(-2px) scale(1.04) } }
        @keyframes floatUp    { 0% { transform:translateY(0) scale(1); opacity:.55 } 70% { opacity:.25 } 100% { transform:translateY(-160px) scale(.4); opacity:0 } }
        @keyframes pezPulse   { 0%,100% { box-shadow:0 0 0 0 #ec489966, 0 4px 20px #3b82f644 } 50% { box-shadow:0 0 0 10px #ec489900, 0 4px 28px #3b82f688 } }
        @keyframes burstRing  { 0% { transform:scale(1); opacity:.9 } 100% { transform:scale(3.5); opacity:0 } }
        @keyframes burstBtn   { 0% { transform:scale(1); opacity:1 } 40% { transform:scale(1.35); opacity:.8 } 100% { transform:scale(0); opacity:0 } }
        * { box-sizing: border-box; }
        input::placeholder { color: ${theme.textDim}; }
        ::-webkit-scrollbar { width: 6px; }
        ::-webkit-scrollbar-track { background: ${theme.bg}; }
        ::-webkit-scrollbar-thumb { background: ${theme.border}; border-radius: 3px; }
        .cat-nav::-webkit-scrollbar { display: none; }
      `}</style>

      <div id="page-content" style={{
        minHeight: "100vh", background: theme.bg, color: theme.text,
        fontFamily: "'DM Sans', sans-serif", transition: "background .5s ease, color .5s ease",
        paddingBottom: 90,                   // espacio para el nav flotante
      }}>

        {/* Banner marquee */}
        <div style={{ background: "linear-gradient(90deg, #0066ff, #0033cc, #0066ff)", padding: "10px 0", overflow: "hidden" }}>
          <div style={{ whiteSpace: "nowrap", animation: "marquee 38s linear infinite", display: "inline-block" }}>
            {[...Array(4)].map((_, i) => (
              <span key={i} style={{ color: "#fff", fontWeight: 800, fontSize: 14, letterSpacing: 1, marginRight: 60 }}>
                💎 REBAJAS · PIEZAS ÚNICAS · CRÉDITO SUJETO A APROBACIÓN(el precio aumenta si aprueba) · PROGRAMA DE RECOMPENSAS CON EL 1% DE REEMBOLSO
              </span>
            ))}
          </div>
        </div>

        {/* Peces nadando por toda la página */}
        <SwimmingFish />

        {/* Header con logo animado */}
        <AnimatedLogo />

        {/* Error Loyverse */}
        {error && (
          <div style={{ maxWidth: 1100, margin: "0 auto", padding: "20px 20px 0" }}>
            <div style={{ background: "rgba(255,100,100,0.08)", border: "1px solid rgba(255,100,100,0.3)", borderRadius: 12, padding: "14px 20px", color: "#ff9999", fontSize: 13 }}>
              <strong>⚠ Error al cargar productos de Loyverse:</strong> {error}
            </div>
          </div>
        )}

        {/* ── Carrusel 3D Destacados — solo en inicio/Todos ── */}
        {category === "Todos" && featured.length > 0 && (
          <div style={{ paddingTop: 36 }}>
            {/* Título de sección */}
            <div style={{ maxWidth: 1200, margin: "0 auto", padding: "0 20px 14px", display: "flex", alignItems: "center", gap: 14 }}>
              <div style={{ flex: 1, height: 1, background: `linear-gradient(90deg, transparent, ${theme.accent}50)` }} />
              <span style={{ color: theme.accent, fontSize: 11, fontWeight: 700, letterSpacing: 2.5, textTransform: "uppercase" }}>
                🔥 Destacados
              </span>
              <div style={{ flex: 1, height: 1, background: `linear-gradient(270deg, transparent, ${theme.accent}50)` }} />
            </div>

            <Swiper
              className="catalog-swiper"
              effect="coverflow"
              grabCursor={true}
              centeredSlides={true}
              slidesPerView="auto"
              coverflowEffect={{ rotate: 32, stretch: 0, depth: 140, modifier: 1.15, slideShadows: true }}
              pagination={{ clickable: true }}
              navigation={true}
              modules={[EffectCoverflow, Pagination, Navigation]}
            >
              {featured.map((p) => (
                <SwiperSlide key={p.id}>
                  <ProductCard product={p} theme={theme} discount={getDiscount(p.specs)} />
                </SwiperSlide>
              ))}
            </Swiper>
          </div>
        )}

        {/* Separador */}
        <div style={{ maxWidth: 1100, margin: "8px auto 0", padding: "0 20px" }}>
          <div style={{ height: 1, background: `linear-gradient(90deg, transparent, ${theme.border} 20%, ${theme.border} 80%, transparent)` }} />
        </div>

        {/* Tier legend — solo Calzado */}
        {category === "Calzado" && (
          <div style={{ maxWidth: 1100, margin: "0 auto", padding: "20px 20px 0" }}>
            <div style={{ background: theme.bgCard, border: `1px solid ${theme.border}`, borderRadius: 12, padding: "14px 20px", display: "flex", flexWrap: "wrap", gap: 16, justifyContent: "center" }}>
              {SHOE_TIERS.map((t) => (
                <div key={t.name} style={{ display: "flex", alignItems: "center", gap: 6 }}>
                  <div style={{ width: 12, height: 12, borderRadius: 3, background: t.color, boxShadow: `0 0 8px ${t.glow}` }} />
                  <span style={{ color: t.color, fontSize: 12, fontWeight: 600 }}>{t.icon} {t.name}</span>
                  <span style={{ color: theme.textDim, fontSize: 11 }}>
                    {t.max === 800 ? "< $800" : t.max === 1100 ? "$800–$1,100" : t.max === 1600 ? "$1,100–$1,600" : t.max === 2200 ? "$1,600–$2,200" : "> $2,200"}
                  </span>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Filters */}
        <div style={{ maxWidth: 1100, margin: "0 auto", padding: "24px 20px 0", display: "flex", flexWrap: "wrap", gap: 12, alignItems: "center" }}>
          <div style={{ position: "relative", flex: "1 1 240px" }}>
            <span style={{ position: "absolute", left: 14, top: "50%", transform: "translateY(-50%)", color: theme.textDim, fontSize: 15 }}>⌕</span>
            <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Buscar productos…"
              style={{ width: "100%", padding: "12px 14px 12px 38px", background: theme.bgCard, border: `1px solid ${theme.border}`, borderRadius: 10, color: theme.text, fontSize: 14, outline: "none", fontFamily: "'DM Sans', sans-serif", transition: "all .4s ease" }} />
          </div>

          <div style={{ display: "flex", gap: 6, flexWrap: "wrap", flex: "1 1 auto" }}>
            {categories.map((c) => {
              const isActive = category === c;
              const pill = CAT_PILL_COLORS_BY_NAME[c] || DEFAULT_PILL;
              const catAccent = CATEGORY_THEMES[c]?.accent || pill.text;
              const themeForLabel = CATEGORY_THEMES[c];
              const label = themeForLabel?.icon ? `${themeForLabel.icon} ${c}` : c;
              return (
                <button key={c} onClick={() => setCategory(c)} style={{
                  padding: "9px 18px", borderRadius: 20, fontSize: 13, fontWeight: 600,
                  cursor: "pointer", transition: "all .3s", border: "none",
                  fontFamily: "'DM Sans', sans-serif",
                  background: isActive ? catAccent : pill.bg,
                  color: isActive ? "#111" : pill.text,
                  boxShadow: isActive ? `0 0 12px ${catAccent}60` : "none",
                }}>{label}</button>
              );
            })}
          </div>

          <select value={sortBy} onChange={(e) => setSortBy(e.target.value)} style={{
            padding: "10px 14px", background: theme.bgCard, border: `1px solid ${theme.border}`,
            borderRadius: 10, color: theme.textMuted, fontSize: 13, cursor: "pointer",
            fontFamily: "'DM Sans', sans-serif", outline: "none", transition: "all .4s ease"
          }}>
            <option value="default">Ordenar</option>
            <option value="priceAsc">Menor precio</option>
            <option value="priceDesc">Mayor precio</option>
          </select>
        </div>

        {/* ── Catálogo completo — grid normal ───────────── */}
        <div style={{ maxWidth: 1100, margin: "0 auto", padding: "16px 20px 0" }}>
          <p style={{ color: theme.textDim, fontSize: 13, margin: 0 }}>
            {filtered.length} producto{filtered.length !== 1 ? "s" : ""}
          </p>
        </div>

        <div className="product-grid">
          {visibleProducts.map((p) => (
            <ProductCard key={p.id} product={p} theme={theme} discount={getDiscount(p.specs)} />
          ))}
          {filtered.length === 0 && (
            <div style={{ gridColumn: "1 / -1", textAlign: "center", padding: "60px 0" }}>
              <p style={{ color: theme.textDim, fontSize: 16 }}>
                {products.length === 0 ? "Aún no hay productos cargados en Loyverse" : "No se encontraron productos"}
              </p>
            </div>
          )}
        </div>

        {/* Sentinel para scroll infinito + botón por si el observer falla */}
        {visibleCount < filtered.length && (
          <div ref={sentinelRef} style={{ maxWidth: 1100, margin: "0 auto", padding: "8px 20px 30px", textAlign: "center" }}>
            <button onClick={() => setVisibleCount((c) => c + BATCH)} style={{
              background: theme.bgCard, border: `1px solid ${theme.border}`, color: theme.textMuted,
              borderRadius: 10, padding: "12px 28px", fontSize: 13, fontWeight: 600, cursor: "pointer",
              fontFamily: "'DM Sans', sans-serif",
            }}>
              Ver más ({filtered.length - visibleCount} restantes)
            </button>
          </div>
        )}
      </div>

      <RecompensasSection products={products} />

      {/* ── Burbuja flotante → scroll a recompensas ── */}
      <button
        onClick={() => document.getElementById("recompensas")?.scrollIntoView({ behavior: "smooth" })}
        title="Ver Recompensas"
        style={{
          position: "fixed", bottom: 80, right: 16, zIndex: 300,
          width: 52, height: 52, borderRadius: "50%",
          background: "linear-gradient(135deg,#7c3aed,#4f46e5)",
          border: "2px solid #a78bfa60",
          boxShadow: "0 4px 20px #7c3aed66",
          color: "#fff", fontSize: 22, cursor: "pointer",
          display: "flex", alignItems: "center", justifyContent: "center",
          animation: "bubbleGlow 2.4s ease-in-out infinite",
          transition: "transform 0.2s",
        }}
        onMouseEnter={e => e.currentTarget.style.transform = "scale(1.15)"}
        onMouseLeave={e => e.currentTarget.style.transform = "scale(1)"}
      >
        💎
      </button>

      {/* ── Burbuja PEZOS — esquina superior derecha ── */}
      {/* Anillos de reventamiento */}
      {pezosBurst && [0, 1, 2].map(i => (
        <div key={i} style={{
          position: "fixed", top: 16, left: 16, zIndex: 299,
          width: 62, height: 62, borderRadius: "50%",
          border: "3px solid #ec4899",
          pointerEvents: "none",
          animation: `burstRing 0.42s ease-out ${i * 0.07}s forwards`,
        }} />
      ))}

      <button
        onClick={handlePezosClick}
        title="¿Qué son los PEZOS?"
        style={{
          position: "fixed", top: 16, left: 16, zIndex: 300,
          width: 62, height: 62, borderRadius: "50%",
          backgroundImage: "url('/pezos.png')",
          backgroundSize: "160%",
          backgroundPosition: "78% 42%",
          border: "2px solid #ffffff50",
          cursor: "pointer",
          padding: 0,
          animation: pezosBurst
            ? "burstBtn 0.42s ease-out forwards"
            : "pezPulse 1.8s ease-in-out infinite",
        }}
      />

      {/* ── Modal PEZOS ── */}
      {pezosModal && (
        <div
          onClick={() => setPezosModal(false)}
          style={{
            position: "fixed", inset: 0, zIndex: 9998,
            background: "rgba(0,0,0,0.88)",
            display: "flex", flexDirection: "column",
            alignItems: "center", justifyContent: "center",
            padding: 16,
          }}
        >
          <div
            onClick={e => e.stopPropagation()}
            style={{
              maxWidth: 420, width: "100%",
              borderRadius: 20, overflow: "hidden",
              boxShadow: "0 0 60px #ec489944, 0 0 60px #3b82f644",
              border: "1px solid #ffffff20",
              display: "flex", flexDirection: "column",
            }}
          >
            <img
              src="/pezos.png"
              alt="PEZOS - Token de Picsis Shop"
              style={{ width: "100%", display: "block" }}
            />
            <div style={{
              background: "#0a0a14",
              padding: "20px 24px",
              display: "flex", flexDirection: "column", gap: 12,
            }}>
              <a
                href={WA_PEZOS}
                target="_blank"
                rel="noopener noreferrer"
                style={{
                  display: "block", textAlign: "center",
                  background: "linear-gradient(135deg,#25d366,#128c7e)",
                  color: "#fff", fontWeight: 800, fontSize: 16,
                  padding: "14px", borderRadius: 12, textDecoration: "none",
                  letterSpacing: 0.3,
                }}
              >
                💬 Pedir información por WhatsApp
              </a>
              <button
                onClick={() => setPezosModal(false)}
                style={{
                  background: "transparent", border: "1px solid #ffffff20",
                  color: "#9ca3af", borderRadius: 10, padding: "10px",
                  cursor: "pointer", fontSize: 14,
                }}
              >
                Cerrar
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ── Burbujas flotantes que suben del nav (sin re-renders) ── */}
      <div ref={bubbleContainerRef} style={{
        position: "fixed", bottom: 0, left: 0, right: 0,
        height: 240, pointerEvents: "none", zIndex: 201, overflow: "hidden",
      }} />

      {/* ── Menú flotante de categorías ────────────────────────── */}
      <nav style={{
        position: "fixed", bottom: 0, left: 0, right: 0, zIndex: 200,
        padding: "10px 12px 14px",
        background: "linear-gradient(to top, rgba(8,8,12,0.97) 60%, rgba(8,8,12,0.82) 85%, transparent 100%)",
        backdropFilter: "blur(14px)",
        WebkitBackdropFilter: "blur(14px)",
      }}>
        <div className="cat-nav" style={{
          display: "flex", gap: 8, overflowX: "auto",
          scrollbarWidth: "none", WebkitOverflowScrolling: "touch",
          padding: "4px 4px 2px",
        }}>
          {categories.map((c) => {
            const isActive = category === c;
            const t      = CATEGORY_THEMES[c] || CATEGORY_THEMES.Todos;
            const accent = t.accent || "#888";
            return (
              <button
                key={c}
                onClick={() => {
                  setCategory(c);
                  window.scrollTo({ top: 0, behavior: "smooth" });
                }}
                style={{
                  "--bub-color": accent + "66",
                  flexShrink: 0,
                  padding: isActive ? "9px 18px" : "7px 14px",
                  borderRadius: 999,
                  // Activa: fondo + borde con su color propio
                  border: `1.5px solid ${isActive ? accent : accent + "40"}`,
                  background: isActive
                    ? `linear-gradient(135deg, ${accent}30 0%, ${accent}12 100%)`
                    : `linear-gradient(135deg, ${accent}12 0%, ${accent}06 100%)`,
                  color: isActive ? accent : accent + "bb",
                  fontSize: isActive ? 13 : 12,
                  fontWeight: isActive ? 700 : 500,
                  cursor: "pointer",
                  transition: "all 0.22s ease",
                  animation: isActive
                    ? "bubblePop 0.3s ease forwards, bubbleGlow 2.4s ease-in-out infinite"
                    : "none",
                  transform: isActive ? "translateY(-2px)" : "none",
                  letterSpacing: isActive ? 0.3 : 0,
                  whiteSpace: "nowrap",
                  boxShadow: isActive ? `0 0 14px ${accent}44` : `0 0 6px ${accent}18`,
                }}
              >
                {t.icon && <span style={{ marginRight: 5 }}>{t.icon}</span>}
                {c}
              </button>
            );
          })}
        </div>
      </nav>
    </>
  );
}
PISCIS_EOF_MARK

cat > SwimmingFish.jsx << 'PISCIS_EOF_MARK'
"use client";
import { useEffect, useRef } from "react";

const RIPPLE_CSS = `
  @keyframes fishSplashBlue {
    0%   { box-shadow: 0 0 0 0 rgba(0,183,255,0.9); }
    60%  { box-shadow: 0 0 40px 20px rgba(0,183,255,0.25); }
    100% { box-shadow: 0 0 0 80px transparent; }
  }
  @keyframes fishSplashPink {
    0%   { box-shadow: 0 0 0 0 rgba(255,59,212,0.9); }
    60%  { box-shadow: 0 0 40px 20px rgba(255,59,212,0.25); }
    100% { box-shadow: 0 0 0 80px transparent; }
  }
  .fish-splash-blue { animation: fishSplashBlue 1s ease-out forwards !important; border-radius: 14px; }
  .fish-splash-pink { animation: fishSplashPink 1s ease-out forwards !important; border-radius: 14px; }
`;

function lerp(a, b, t) { return a + (b - a) * t; }

// ── Sonido de gota cayendo en agua ─────────────────────────────────
function playWaterSound(isBlue) {
  try {
    const ac  = new (window.AudioContext || window.webkitAudioContext)();
    const now = ac.currentTime;

    // Tono principal: sinewave con pitch que cae rápido (característica de gota)
    const osc1 = ac.createOscillator();
    osc1.type = "sine";
    osc1.frequency.setValueAtTime(isBlue ? 680 : 920, now);
    osc1.frequency.exponentialRampToValueAtTime(isBlue ? 140 : 200, now + 0.18);

    const g1 = ac.createGain();
    g1.gain.setValueAtTime(0, now);
    g1.gain.linearRampToValueAtTime(0.09, now + 0.004); // ataque muy rápido
    g1.gain.exponentialRampToValueAtTime(0.001, now + 0.28);

    // Resonancia secundaria — "pling" de la superficie del agua
    const osc2 = ac.createOscillator();
    osc2.type = "sine";
    osc2.frequency.setValueAtTime(isBlue ? 320 : 480, now + 0.01);
    osc2.frequency.exponentialRampToValueAtTime(isBlue ? 70 : 110, now + 0.22);

    const g2 = ac.createGain();
    g2.gain.setValueAtTime(0, now + 0.01);
    g2.gain.linearRampToValueAtTime(0.05, now + 0.015);
    g2.gain.exponentialRampToValueAtTime(0.001, now + 0.35);

    // Pequeño ruido suave para el "splash" — muy atenuado
    const bufSize = Math.floor(ac.sampleRate * 0.06);
    const buf = ac.createBuffer(1, bufSize, ac.sampleRate);
    const d   = buf.getChannelData(0);
    for (let i = 0; i < bufSize; i++) {
      d[i] = (Math.random() * 2 - 1) * (1 - i / bufSize);
    }
    const noise = ac.createBufferSource();
    noise.buffer = buf;
    const bp = ac.createBiquadFilter();
    bp.type = "bandpass"; bp.frequency.value = 2000; bp.Q.value = 2;
    const gn = ac.createGain();
    gn.gain.setValueAtTime(0.018, now);
    gn.gain.exponentialRampToValueAtTime(0.001, now + 0.06);

    osc1.connect(g1); g1.connect(ac.destination);
    osc2.connect(g2); g2.connect(ac.destination);
    noise.connect(bp); bp.connect(gn); gn.connect(ac.destination);

    osc1.start(now);   osc1.stop(now + 0.35);
    osc2.start(now + 0.01); osc2.stop(now + 0.4);
    noise.start(now);

    setTimeout(() => ac.close(), 1200);
  } catch (_) {}
}

// ── Partículas de agua ──────────────────────────────────────────────
class Particle {
  constructor(x, y, color, type) {
    this.x     = x;
    this.y     = y;
    this.color = color;
    this.type  = type; // 'bubble' | 'ripple' | 'splash' | 'drop' | 'wave'
    this.life  = 1;

    if (type === "bubble") {
      this.r     = Math.random() * 10 + 5;          // 5-15px (antes 1.5-5)
      this.vx    = (Math.random() - 0.5) * 2.5;
      this.vy    = -(Math.random() * 2.5 + 1);
      this.decay = 0.4 + Math.random() * 0.25;
    } else if (type === "ripple") {
      this.r     = Math.random() * 10 + 20;         // empieza en 20-30px
      this.grow  = Math.random() * 60 + 70;         // crece 70-130px/s
      this.vx = this.vy = 0;
      this.decay = 0.75;
    } else if (type === "splash") {
      this.r     = Math.random() * 20 + 30;         // empieza 30-50px
      this.grow  = Math.random() * 120 + 130;       // crece 130-250px/s
      this.vx = this.vy = 0;
      this.decay = 0.9;
    } else if (type === "drop") {
      this.r       = Math.random() * 5 + 3;         // 3-8px
      this.vx      = (Math.random() - 0.5) * 8;
      this.vy      = -(Math.random() * 7 + 3);
      this.gravity = 12;
      this.decay   = 0.9;
    } else if (type === "wave") {
      this.r     = Math.random() * 20 + 30;         // 30-50px
      this.grow  = Math.random() * 30 + 20;
      this.skew  = Math.random() * 0.3 + 0.45;      // menos aplastado
      this.vx = this.vy = 0;
      this.decay = 0.6;
    }
  }

  update(dt) {
    this.life -= dt * this.decay;
    this.x += (this.vx || 0) * dt * 60;
    this.y += (this.vy || 0) * dt * 60;
    if (this.gravity) this.vy += this.gravity * dt;
    if (this.grow) this.r += this.grow * dt;
  }

  draw(ctx) {
    if (this.life <= 0) return;
    const a = Math.max(0, this.life);
    ctx.save();
    ctx.shadowColor = this.color;
    ctx.shadowBlur  = 25;                            // glow fuerte

    if (this.type === "bubble") {
      ctx.globalAlpha = a * 0.04;
      ctx.beginPath();
      ctx.arc(this.x, this.y, this.r, 0, Math.PI * 2);
      ctx.fillStyle = this.color;
      ctx.fill();
      ctx.globalAlpha = a * 0.15;
      ctx.beginPath();
      ctx.arc(this.x, this.y, this.r, 0, Math.PI * 2);
      ctx.strokeStyle = this.color;
      ctx.lineWidth   = 1;
      ctx.stroke();
    } else if (this.type === "ripple") {
      ctx.globalAlpha = a * 0.12;
      ctx.beginPath();
      ctx.arc(this.x, this.y, this.r, 0, Math.PI * 2);
      ctx.strokeStyle = this.color;
      ctx.lineWidth   = 1;
      ctx.stroke();
    } else if (this.type === "splash") {
      ctx.globalAlpha = a * 0.14;
      ctx.shadowBlur  = 8;
      ctx.beginPath();
      ctx.arc(this.x, this.y, this.r, 0, Math.PI * 2);
      ctx.strokeStyle = this.color;
      ctx.lineWidth   = 1.5;
      ctx.stroke();
    } else if (this.type === "drop") {
      ctx.globalAlpha = a * 0.18;
      ctx.beginPath();
      ctx.arc(this.x, this.y, this.r, 0, Math.PI * 2);
      ctx.fillStyle = this.color;
      ctx.fill();
    } else if (this.type === "wave") {
      ctx.globalAlpha = a * 0.1;
      ctx.beginPath();
      ctx.ellipse(this.x, this.y, this.r, this.r * this.skew, 0, 0, Math.PI * 2);
      ctx.strokeStyle = this.color;
      ctx.lineWidth   = 1;
      ctx.stroke();
    }
    ctx.restore();
  }
}

// ── Estado y lógica del pez ─────────────────────────────────────────
class FishState {
  constructor({ speed, size, index, splashClass, glowColor, totalFrames }) {
    this.speed       = speed;
    this.size        = size;
    this.index       = index;
    this.splashClass = splashClass;
    this.glowColor   = glowColor;
    this.totalFrames = totalFrames;
    this.frameIndex  = 0;
    this.frameTimer  = 0;
    this.rippleTimer = 0;
    this.bubbleTimer = 0;
    this.waveTimer   = 0;
    this.trail       = [];                       // estela de posiciones
    this.x           = window.innerWidth / 2;
    this.y           = 160;
    this.angle       = 0;
    this.opacity     = 0;
    this.scale       = 0;
    this.swimT       = index * Math.PI;
    this.state       = "EMERGING";
    this.stateTimer  = index * 2.5;
    this.targetCard  = null;
    this.targetX     = this.x;
    this.targetY     = this.y;
  }

  logoX() {
    const hero = document.querySelector(".logoHero");
    const cx   = hero
      ? hero.getBoundingClientRect().left + hero.getBoundingClientRect().width / 2
      : window.innerWidth / 2;
    return cx + (this.index === 0 ? -65 : 65);
  }
  logoY() {
    const hero = document.querySelector(".logoHero");
    if (!hero) return 160;
    const r = hero.getBoundingClientRect();
    return r.top + r.height * 0.52;          // emerge desde el centro del hero
  }

  swimPos(t) {
    const w = window.innerWidth, h = window.innerHeight;
    return {
      x: w / 2 + (this.index === 0 ? -90 : 90) + w * 0.37 * Math.sin(t + this.index * Math.PI),
      y: h / 2 + 80 + h * 0.3 * Math.sin((t + this.index * Math.PI) * 2),
    };
  }

  spawnSplash(particles) {
    // 3 anillos concéntricos
    for (let i = 0; i < 3; i++) {
      setTimeout(() => {
        particles.push(new Particle(this.x, this.y, this.glowColor, "splash"));
      }, i * 80);
    }
    // 8 gotas en arco
    for (let i = 0; i < 8; i++) {
      const p = new Particle(this.x, this.y, this.glowColor, "drop");
      const ang = (i / 8) * Math.PI * 2;
      p.vx = Math.cos(ang) * (Math.random() * 3 + 2);
      p.vy = Math.sin(ang) * (Math.random() * 3 + 2) - 3;
      particles.push(p);
    }
    // 4 burbujas
    for (let i = 0; i < 4; i++) {
      const p = new Particle(
        this.x + (Math.random() - 0.5) * 40,
        this.y + (Math.random() - 0.5) * 40,
        this.glowColor, "bubble"
      );
      p.vy = -(Math.random() * 2 + 1);
      particles.push(p);
    }
    // 1 ola
    particles.push(new Particle(this.x, this.y, this.glowColor, "wave"));
  }

  update(dt, cards, particles) {
    this.stateTimer += dt;
    this.swimT      += dt * this.speed;

    // Ciclar frames a 8fps
    this.frameTimer += dt;
    if (this.frameTimer > 1 / 8) {
      this.frameTimer = 0;
      this.frameIndex = (this.frameIndex + 1) % this.totalFrames;
    }

    const px = this.x, py = this.y;

    switch (this.state) {
      case "EMERGING": {
        this.opacity = Math.min(1, this.opacity + dt * 2);
        this.scale   = Math.min(1, this.scale   + dt * 2);
        this.x = lerp(this.x, this.logoX(), dt * 3);
        this.y = lerp(this.y, this.logoY(), dt * 3);
        if (this.stateTimer > 1.8 + this.index * 1.2) this.state = "SWIMMING";
        break;
      }
      case "SWIMMING": {
        const pos = this.swimPos(this.swimT);
        const sdx = pos.x - this.x, sdy = pos.y - this.y;
        const sd = Math.sqrt(sdx * sdx + sdy * sdy);
        const MAX_SWIM = 55; // px/s — velocidad máxima nadando
        if (sd > 1) {
          const move = Math.min(sd, MAX_SWIM * dt);
          this.x += (sdx / sd) * move;
          this.y += (sdy / sd) * move;
        }
        this.opacity = Math.min(1, this.opacity + dt * 2);
        this.scale   = Math.min(1, this.scale   + dt * 2);
        if (this.stateTimer > 7 + this.index * 3 && cards.length > 0) {
          const vis = cards.filter(c => {
            const r = c.getBoundingClientRect();
            return r.top > 50 && r.bottom < window.innerHeight - 50;
          });
          const pool = vis.length > 0 ? vis : cards;
          this.targetCard = pool[Math.floor(Math.random() * pool.length)];
          this.state = "TARGETING";
          this.stateTimer = 0;
        }
        break;
      }
      case "TARGETING": {
        if (this.targetCard) {
          const r = this.targetCard.getBoundingClientRect();
          this.targetX = r.left + r.width  / 2;
          this.targetY = r.top  + r.height / 2;
        }
        const tdx = this.targetX - this.x;
        const tdy = this.targetY - this.y;
        const td  = Math.sqrt(tdx * tdx + tdy * tdy);
        if (td > 0.5) {
          const step = Math.min(50 * dt, td);
          this.x += (tdx / td) * step;
          this.y += (tdy / td) * step;
        }
        if (td < 40) {
          this.spawnSplash(particles);
          if (this.targetCard) {
            this.targetCard.classList.add(this.splashClass);
            const card = this.targetCard;
            setTimeout(() => card.classList.remove(this.splashClass), 1000);
          }
          this.state = "DIVING";
          this.stateTimer = 0;
        }
        break;
      }
      case "DIVING": {
        this.opacity = Math.max(0, this.opacity - dt * 3.5);
        this.scale   = Math.max(0, this.scale   - dt * 3.5);
        if (this.stateTimer > 1.2) {
          this.x = this.logoX();
          this.y = this.logoY();
          this.state = "RETURNING";
          this.stateTimer = 0;
        }
        break;
      }
      case "RETURNING": {
        this.opacity = Math.min(1, this.opacity + dt * 1.5);
        this.scale   = Math.min(1, this.scale   + dt * 1.5);
        this.x = lerp(this.x, this.logoX(), dt * 2.5);
        this.y = lerp(this.y, this.logoY(), dt * 2.5);
        if (this.stateTimer > 1.5) {
          this.swimT += Math.PI * 0.4;
          this.state = "SWIMMING";
          this.stateTimer = 0;
        }
        break;
      }
    }

    // Estela (trail) — siempre que el pez sea visible
    if (this.opacity > 0.2) {
      this.trail.push({ x: this.x, y: this.y, life: 1 });
      if (this.trail.length > 22) this.trail.shift();
    }

    // Efectos de agua mientras nada
    const spd = Math.sqrt((this.x - px) ** 2 + (this.y - py) ** 2) / dt;
    if (this.opacity > 0.3 && spd > 8) {

      // Burbujas — pocas, sutiles
      this.bubbleTimer += dt;
      if (this.bubbleTimer > 0.28) {
        this.bubbleTimer = 0;
        particles.push(new Particle(
          this.x + (Math.random() - 0.5) * 20,
          this.y + (Math.random() - 0.5) * 20,
          this.glowColor, "bubble"
        ));
      }

      // Ripple suave — poco frecuente
      this.rippleTimer += dt;
      if (this.rippleTimer > 0.7) {
        this.rippleTimer = 0;
        particles.push(new Particle(this.x, this.y, this.glowColor, "ripple"));
      }

      // Olas — mínimas
      this.waveTimer += dt;
      if (this.waveTimer > 1.4) {
        this.waveTimer = 0;
        particles.push(new Particle(this.x, this.y, this.glowColor, "wave"));
      }
    }

    // Ángulo suavizado
    const adx = this.x - px, ady = this.y - py;
    if (Math.abs(adx) + Math.abs(ady) > 0.3) {
      let diff = Math.atan2(ady, adx) - this.angle;
      while (diff >  Math.PI) diff -= 2 * Math.PI;
      while (diff < -Math.PI) diff += 2 * Math.PI;
      this.angle += diff * Math.min(dt * 4, 1);
    }
  }

  draw(ctx, frames) {
    if (this.opacity <= 0 || this.scale <= 0) return;

    // ── Estela de brillo ───────────────────────────────────────────
    const tLen = this.trail.length;
    if (tLen > 1) {
      for (let i = 1; i < tLen; i++) {
        const t  = i / tLen;                      // 0→1 (más viejo→reciente)
        const pt = this.trail[i];
        const r  = t * 14 + 2;                    // radio 2-16px
        ctx.save();
        ctx.globalAlpha = t * this.opacity * 0.06;
        ctx.shadowColor = this.glowColor;
        ctx.shadowBlur  = 30;
        ctx.beginPath();
        ctx.arc(pt.x, pt.y, r, 0, Math.PI * 2);
        ctx.fillStyle = this.glowColor;
        ctx.fill();
        ctx.restore();
      }
    }

    // ── Dibujo del pez ─────────────────────────────────────────────
    const frame = frames[this.frameIndex];
    if (!frame || !frame.complete || !frame.naturalWidth) return;

    const w = this.size;
    const h = (frame.naturalHeight / frame.naturalWidth) * w;
    const facingLeft   = Math.cos(this.angle) < 0;
    const displayAngle = facingLeft ? Math.PI - this.angle : this.angle;

    ctx.save();
    ctx.globalAlpha = this.opacity * 0.6;
    ctx.translate(this.x, this.y);
    ctx.rotate(displayAngle);
    if (facingLeft) ctx.scale(-1, 1);
    ctx.scale(this.scale, this.scale);
    ctx.shadowColor = this.glowColor;
    ctx.shadowBlur  = 18;
    ctx.drawImage(frame, -w / 2, -h / 2, w, h);
    ctx.restore();
  }
}

// ── Componente principal ────────────────────────────────────────────
export default function SwimmingFish() {
  const canvasRef = useRef(null);

  useEffect(() => {
    const style = document.createElement("style");
    style.textContent = RIPPLE_CSS;
    document.head.appendChild(style);

    const canvas = canvasRef.current;
    const ctx    = canvas.getContext("2d");
    const setSize = () => { canvas.width = window.innerWidth; canvas.height = window.innerHeight; };
    setSize();
    window.addEventListener("resize", setSize);

    // Frames diferidos: se crean vacíos y el src se asigna cuando el navegador
    // está libre, para no competir con las imágenes de productos en la carga inicial.
    // draw() ya valida frame.complete/naturalWidth, así que es seguro.
    const azulFrames = Array.from({ length: 10 }, () => new Image());
    const rosaFrames = Array.from({ length: 10 }, () => new Image());
    const loadFrames = () => {
      azulFrames.forEach((img, i) => { img.src = `/frames-azul/azul_${String(i + 1).padStart(2, "0")}.png`; });
      rosaFrames.forEach((img, i) => { img.src = `/frames-rosa/rosa_${String(i + 1).padStart(2, "0")}.png`; });
    };
    let idleId;
    if ("requestIdleCallback" in window) idleId = requestIdleCallback(loadFrames, { timeout: 2500 });
    else idleId = setTimeout(loadFrames, 1200);

    const fish = [
      new FishState({ speed: 0.06, size: 190, index: 0, splashClass: "fish-splash-blue", glowColor: "#00d4ff", totalFrames: 10 }),
      new FishState({ speed: 0.05, size: 240, index: 1, splashClass: "fish-splash-pink", glowColor: "#ff44ee", totalFrames: 10 }),
    ];

    const particles = [];

    // ── Glow suave del dedo/cursor ────────────────────────────────
    let ptrX = -999, ptrY = -999;
    function onMove(e) {
      const pt = e.touches ? e.touches[0] : e;
      ptrX = pt.clientX; ptrY = pt.clientY;
    }
    window.addEventListener("mousemove", onMove);
    window.addEventListener("touchmove", onMove, { passive: true });

    // ── Toque / click sobre un pez ──────────────────────────────────
    function handleTap(e) {
      const cx = e.touches ? e.touches[0].clientX : e.clientX;
      const cy = e.touches ? e.touches[0].clientY : e.clientY;

      fish.forEach((f, i) => {
        const dx = cx - f.x, dy = cy - f.y;
        if (Math.sqrt(dx * dx + dy * dy) < f.size * 0.75) {
          // Sonido de agua
          playWaterSound(i === 0);
          // Splash en posición actual
          f.spawnSplash(particles);
          // Saltar a posición aleatoria visible
          f.x = window.innerWidth  * (0.15 + Math.random() * 0.7);
          f.y = window.innerHeight * (0.2  + Math.random() * 0.55);
          f.swimT   += Math.PI * (0.5 + Math.random());
          f.state    = "SWIMMING";
          f.stateTimer = 0;
        }
      });
    }

    window.addEventListener("click",      handleTap);
    window.addEventListener("touchstart", handleTap, { passive: true });

    let last = performance.now(), animId;

    // Cache de cards: consultar el DOM 60 veces/seg es carísimo en móvil.
    // Se refresca cada 600ms, suficiente para filtros y scroll infinito.
    let cards = [], lastCardScan = 0;

    function loop(now) {
      const dt    = Math.min((now - last) / 1000, 0.05);
      last        = now;
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      if (now - lastCardScan > 600) {
        cards = Array.from(document.querySelectorAll("[data-product-card]"));
        lastCardScan = now;
      }

      // ── Glow del dedo — muy sutil ─────────────────────────────────
      if (ptrX > 0) {
        const color = Math.hypot(fish[0].x - ptrX, fish[0].y - ptrY) <
                      Math.hypot(fish[1].x - ptrX, fish[1].y - ptrY)
          ? "0,212,255" : "255,68,238";
        const grad = ctx.createRadialGradient(ptrX, ptrY, 0, ptrX, ptrY, 130);
        grad.addColorStop(0, `rgba(${color},0.18)`);
        grad.addColorStop(0.5, `rgba(${color},0.06)`);
        grad.addColorStop(1, `rgba(${color},0)`);
        ctx.fillStyle = grad;
        ctx.fillRect(0, 0, canvas.width, canvas.height);
      }

      // Partículas primero (detrás de los peces)
      for (let i = particles.length - 1; i >= 0; i--) {
        particles[i].update(dt);
        if (particles[i].life <= 0) particles.splice(i, 1);
        else particles[i].draw(ctx);
      }

      // Peces encima
      fish[0].update(dt, cards, particles); fish[0].draw(ctx, azulFrames);
      fish[1].update(dt, cards, particles); fish[1].draw(ctx, rosaFrames);

      animId = requestAnimationFrame(loop);
    }

    animId = requestAnimationFrame(loop);
    return () => {
      if ("requestIdleCallback" in window) cancelIdleCallback(idleId);
      else clearTimeout(idleId);
      cancelAnimationFrame(animId);
      window.removeEventListener("resize",     setSize);
      window.removeEventListener("mousemove",  onMove);
      window.removeEventListener("touchmove",  onMove);
      window.removeEventListener("click",      handleTap);
      window.removeEventListener("touchstart", handleTap);
document.head.removeChild(style);
    };
  }, []);

  return (
    <canvas ref={canvasRef} style={{
      position: "fixed", top: 0, left: 0,
      width: "100vw", height: "100vh",
      pointerEvents: "none", zIndex: 1,   // detrás de todo el contenido
    }} />
  );
}
PISCIS_EOF_MARK

cat > app/layout.jsx << 'PISCIS_EOF_MARK'
import "./globals.css";

export const metadata = {
  title: "PICSIS SHOP — Catálogo 2026",
  description: "Compra de contado o elige tu plan a crédito. Informes por WhatsApp.",
};

export default function RootLayout({ children }) {
  return (
    <html lang="es">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link
          href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Playfair+Display:wght@500;600;700&display=swap"
          rel="stylesheet"
        />
      </head>
      <body style={{ margin: 0, background: "#111" }}>{children}</body>
    </html>
  );
}
PISCIS_EOF_MARK

cat > app/loading.jsx << 'PISCIS_EOF_MARK'
// Skeleton instantáneo mientras el servidor consulta Loyverse.
// Aparece de inmediato en vez de pantalla en blanco.
export default function Loading() {
  return (
    <div style={{ minHeight: "100vh", background: "#111", fontFamily: "sans-serif" }}>
      <style>{`@keyframes shine { 0% { opacity:.45 } 50% { opacity:.9 } 100% { opacity:.45 } }`}</style>
      {/* Barra superior */}
      <div style={{ height: 38, background: "#0d1b3a", animation: "shine 1.4s ease-in-out infinite" }} />
      {/* Hero del logo */}
      <div style={{ height: 220, display: "flex", alignItems: "center", justifyContent: "center", background: "radial-gradient(ellipse at 50% 40%, #102040 0%, #030c1c 70%)" }}>
        <div style={{ width: 200, height: 120, borderRadius: 16, background: "#1a2a4a", animation: "shine 1.4s ease-in-out infinite" }} />
      </div>
      {/* Filtros */}
      <div style={{ maxWidth: 1100, margin: "0 auto", padding: "24px 20px 0", display: "flex", gap: 10, flexWrap: "wrap" }}>
        <div style={{ flex: "1 1 240px", height: 44, borderRadius: 10, background: "#1a1a1a", animation: "shine 1.4s ease-in-out infinite" }} />
        {[70, 90, 90, 80].map((w, i) => (
          <div key={i} style={{ width: w, height: 38, borderRadius: 20, background: "#1a1a1a", animation: "shine 1.4s ease-in-out infinite", animationDelay: `${i * 0.12}s` }} />
        ))}
      </div>
      {/* Grid de tarjetas fantasma */}
      <div style={{ maxWidth: 1100, margin: "0 auto", padding: "24px 20px 60px", display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(260px, 1fr))", gap: 20 }}>
        {Array.from({ length: 6 }).map((_, i) => (
          <div key={i} style={{ background: "#1a1a1a", borderRadius: 14, overflow: "hidden", border: "1px solid #2a2a2a", animation: "shine 1.4s ease-in-out infinite", animationDelay: `${i * 0.1}s` }}>
            <div style={{ aspectRatio: "1", background: "#222" }} />
            <div style={{ padding: 18 }}>
              <div style={{ height: 14, width: "75%", borderRadius: 4, background: "#2a2a2a", marginBottom: 10 }} />
              <div style={{ height: 40, borderRadius: 10, background: "#222" }} />
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
PISCIS_EOF_MARK

cat > .gitignore << 'PISCIS_EOF_MARK'
node_modules/
.next/
out/
.env
.env.local
.env*.local
.vercel
*.log
PISCIS_EOF_MARK

echo "→ 2/5 Eliminando código muerto y assets sin uso (~46MB)..."
git rm -q --ignore-unmatch app/Catalog.jsx Catalog.css \
  public/pez-azul.webp public/pez-azul.jpg \
  public/pez-rosa.webp public/pez-rosa.jpg \
  public/picsis-logo.png public/picsis-shop-logo.webm \
  public/picsis-shop-logo.mp4 public/picsis-shop-logo.png \
  public/picsisshoplogo.1.png

echo "→ 3/5 Sacando .next y .env.local del repo (quedan locales)..."
git rm -r -q --cached --ignore-unmatch .next .env.local

echo "→ 4/5 Comprimiendo video del logo si ffmpeg está disponible..."
if command -v ffmpeg >/dev/null 2>&1; then
  ffmpeg -y -v error -i public/logopicsisshop.mp4 \
    -vf "scale=960:-2" -c:v libx264 -crf 28 -preset veryfast -movflags +faststart -an \
    public/logopicsisshop.opt.mp4
  mv public/logopicsisshop.opt.mp4 public/logopicsisshop.mp4
  echo "   Video comprimido: $(du -h public/logopicsisshop.mp4 | cut -f1)"
else
  echo "   ffmpeg no encontrado — opcional: pkg install ffmpeg y vuelve a correr"
fi

echo "→ 5/5 Listo. Verifica con:"
echo "   npm run build"
echo ""
echo "⚠ IMPORTANTE: tu LOYVERSE_TOKEN quedó expuesto en el historial de GitHub."
echo "  Rótalo en Loyverse (Ajustes → Tokens) y actualízalo en Vercel."
