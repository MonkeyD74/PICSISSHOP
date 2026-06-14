"use client";

import { useState, useMemo } from "react";

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
};

const CAT_PILL_COLORS_BY_NAME = {
  Todos: { bg: "#1e1e1e", text: "#888" },
  Hombres: { bg: "rgba(77,171,247,0.12)", text: "#4dabf7" },
  Mujeres: { bg: "rgba(244,114,182,0.12)", text: "#f472b6" },
  Calzado: { bg: "rgba(255,215,0,0.10)", text: "#FFD700" },
  Electrónica: { bg: "rgba(0,212,255,0.10)", text: "#00d4ff" },
  Hogar: { bg: "rgba(255,159,67,0.10)", text: "#ff9f43" },
  Deportes: { bg: "rgba(0,230,118,0.10)", text: "#00e676" },
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

// Número de WhatsApp: 52 (MX) + 10 dígitos. Sin el "1" legacy de móviles.
// Si tu número antes funcionaba con "521...", cambia esta línea a "5213481239175".
const WA_NUMBER = "523481239175";

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

function ProductCard({ product, theme }) {
  const [hovered, setHovered] = useState(false);
  const [selectedSize, setSelectedSize] = useState(product.sizes[0] || null);
  const [showSpecs, setShowSpecs] = useState(false);
  const [imgError, setImgError] = useState(false);

  const isCalzado = product.category === "Calzado";
  const tier = isCalzado ? getShoeTier(product.price) : null;
  const priceColor = isCalzado ? tier.color : theme.accent;
  const cardBorder = isCalzado ? `2px solid ${tier.color}` : `1px solid ${theme.border}`;
  const cardShadow = hovered
    ? isCalzado ? `0 8px 32px ${tier.glow}, 0 0 0 1px ${tier.color}30` : `0 12px 40px rgba(0,0,0,.4)`
    : isCalzado ? `0 0 20px ${tier.glow.replace(/[\d.]+\)$/, "0.12)")}` : "none";

  const waURL = buildWhatsAppURL(product, selectedSize);
  const imgSrc = !product.image || imgError ? PLACEHOLDER_IMG : product.image;
  const hasSpecs = Object.keys(product.specs || {}).length > 0;

  return (
    <div onMouseEnter={() => setHovered(true)} onMouseLeave={() => setHovered(false)} style={{
      background: theme.bgCard, borderRadius: 14, overflow: "hidden", border: cardBorder,
      transition: "all .4s ease", transform: hovered ? "translateY(-4px)" : "none", boxShadow: cardShadow,
    }}>
      <div style={{ position: "relative", overflow: "hidden", aspectRatio: "1", background: theme.bg }}>
        <img src={imgSrc} alt={product.name} onError={() => setImgError(true)} style={{ width: "100%", height: "100%", objectFit: "cover", transition: "transform .5s ease", transform: hovered ? "scale(1.08)" : "scale(1)" }} />
        <span style={{
          position: "absolute", top: 12, left: 12, background: isCalzado ? tier.color : theme.accent,
          color: "#111", fontSize: 10, fontWeight: 700, padding: "4px 10px", borderRadius: 20,
          textTransform: "uppercase", letterSpacing: 1, zIndex: 2
        }}>{product.category}</span>
        {isCalzado && <TierBadge tier={tier} />}
        {isCalzado && <div style={{ position: "absolute", bottom: 0, left: 0, right: 0, height: "40%", background: `linear-gradient(transparent, ${tier.color}10)`, pointerEvents: "none" }} />}
      </div>

      <div style={{ padding: "18px 18px 20px" }}>
        <h3 style={{ color: theme.text, fontSize: 15, margin: "0 0 6px", fontWeight: 600, fontFamily: "'Playfair Display', serif", lineHeight: 1.3 }}>{product.name}</h3>
        <p style={{ color: priceColor, fontSize: 22, fontWeight: 700, margin: "0 0 12px" }}>{fmt(product.price)}</p>

        {product.sizes.length > 0 && (
          <div style={{ marginBottom: 14 }}>
            <p style={{ color: theme.textDim, fontSize: 11, margin: "0 0 6px", textTransform: "uppercase", letterSpacing: 1 }}>Tallas</p>
            <div style={{ display: "flex", gap: 6, flexWrap: "wrap" }}>
              {product.sizes.map((s) => (
                <button key={s} onClick={() => setSelectedSize(s)} style={{
                  background: selectedSize === s ? (isCalzado ? tier.color : theme.accent) : theme.bgElevated,
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

        <a href={waURL} target="_blank" rel="noopener noreferrer" style={{
          display: "flex", alignItems: "center", justifyContent: "center", gap: 6,
          width: "100%", padding: "12px 0", background: "#25D366", color: "#fff",
          border: "none", borderRadius: 8, fontWeight: 700, fontSize: 13,
          cursor: "pointer", textDecoration: "none", boxSizing: "border-box",
          transition: "opacity .2s"
        }}>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="#fff"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z" /></svg>
          Pedir informes
        </a>
      </div>
    </div>
  );
}

export default function Catalog({ products, categories, error }) {
  const [category, setCategory] = useState("Todos");
  const [search, setSearch] = useState("");
  const [sortBy, setSortBy] = useState("default");

  const theme = CATEGORY_THEMES[category] || CATEGORY_THEMES.Todos;

  const filtered = useMemo(() => {
    let list = products;
    if (category !== "Todos") list = list.filter((p) => p.category === category);
    if (search) list = list.filter((p) => p.name.toLowerCase().includes(search.toLowerCase()));
    if (sortBy === "priceAsc") list = [...list].sort((a, b) => a.price - b.price);
    if (sortBy === "priceDesc") list = [...list].sort((a, b) => b.price - a.price);
    return list;
  }, [category, search, sortBy, products]);

  return (
    <>
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Playfair+Display:wght@500;600;700&display=swap');
        @keyframes fadeIn { from { opacity: 0 } to { opacity: 1 } }
        * { box-sizing: border-box; }
        input::placeholder { color: ${theme.textDim}; }
        ::-webkit-scrollbar { width: 6px; }
        ::-webkit-scrollbar-track { background: ${theme.bg}; }
        ::-webkit-scrollbar-thumb { background: ${theme.border}; border-radius: 3px; }
      `}</style>

      <div style={{
        minHeight: "100vh", background: theme.bg, color: theme.text,
        fontFamily: "'DM Sans', sans-serif", transition: "background .5s ease, color .5s ease"
      }}>
        {/* Header con logo (WebM con alpha real + PNG fallback para Safari) */}
        <div style={{ padding: "24px 24px 28px", textAlign: "center", background: theme.gradient, borderBottom: `1px solid ${theme.border}`, transition: "background .5s ease", position: "relative", overflow: "hidden" }}>
          <video
            autoPlay loop muted playsInline
            poster="/picsis-shop-logo.png"
            style={{
              width: "min(240px, 55vw)",
              height: "auto",
              aspectRatio: "1 / 1",
              objectFit: "contain",
              display: "block",
              margin: "0 auto -8px",
              pointerEvents: "none",
              filter: "drop-shadow(0 0 30px rgba(255,200,80,0.18))",
            }}
          >
            <source src="/picsis-shop-logo.webm" type="video/webm" />
            {/* Fallback para navegadores sin soporte de WebM con alpha (Safari < 16) */}
            <img src="/picsis-shop-logo.png" alt="PICSIS SHOP Logo" style={{ width: "100%" }} />
          </video>

          <h1 style={{
            fontFamily: "'Playfair Display', serif",
            fontSize: "clamp(28px, 6vw, 46px)",
            fontWeight: 700,
            margin: "0 0 4px",
            letterSpacing: "0.18em",
            background: "linear-gradient(90deg, #b8862b 0%, #fceaa3 25%, #d49c3a 50%, #fce19d 75%, #b8862b 100%)",
            WebkitBackgroundClip: "text",
            WebkitTextFillColor: "transparent",
            backgroundClip: "text",
            textShadow: "0 2px 24px rgba(255,200,80,0.12)",
          }}>
            PICSIS SHOP
          </h1>

          <p style={{ color: theme.accent, fontSize: 11, letterSpacing: 4, textTransform: "uppercase", margin: "12px 0 4px", fontWeight: 600, transition: "color .4s ease" }}>
            {theme.subtitle}
          </p>
          <p style={{ color: theme.text, fontSize: 17, margin: "0 0 6px", fontFamily: "'Playfair Display', serif", fontWeight: 500, transition: "color .4s ease" }}>
            {theme.title}
          </p>
          <p style={{ color: theme.textDim, fontSize: 13, margin: 0, maxWidth: 400, marginInline: "auto", transition: "color .4s ease" }}>
            Encuentra lo que buscas. Informes y compra por WhatsApp.
          </p>
        </div>

        {/* Banner de error de Loyverse */}
        {error && (
          <div style={{ maxWidth: 1100, margin: "0 auto", padding: "20px 20px 0" }}>
            <div style={{ background: "rgba(255,100,100,0.08)", border: "1px solid rgba(255,100,100,0.3)", borderRadius: 12, padding: "14px 20px", color: "#ff9999", fontSize: 13 }}>
              <strong>⚠ Error al cargar productos de Loyverse:</strong> {error}
            </div>
          </div>
        )}

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
              const themeForLabel = CATEGORY_THEMES[c];
              const label = themeForLabel?.icon ? `${themeForLabel.icon} ${c}` : c;
              return (
                <button key={c} onClick={() => setCategory(c)} style={{
                  padding: "9px 18px", borderRadius: 20, fontSize: 13, fontWeight: 600,
                  cursor: "pointer", transition: "all .3s", border: "none",
                  fontFamily: "'DM Sans', sans-serif",
                  background: isActive ? theme.accent : pill.bg,
                  color: isActive ? "#111" : pill.text,
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

        <div style={{ maxWidth: 1100, margin: "0 auto", padding: "16px 20px 0" }}>
          <p style={{ color: theme.textDim, fontSize: 13, margin: 0 }}>{filtered.length} producto{filtered.length !== 1 ? "s" : ""}</p>
        </div>

        {/* Grid */}
        <div style={{ maxWidth: 1100, margin: "0 auto", padding: "16px 20px 60px", display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(260px, 1fr))", gap: 20 }}>
          {filtered.map((p) => <ProductCard key={p.id} product={p} theme={theme} />)}
          {filtered.length === 0 && (
            <div style={{ gridColumn: "1 / -1", textAlign: "center", padding: "60px 0" }}>
              <p style={{ color: theme.textDim, fontSize: 16 }}>
                {products.length === 0 ? "Aún no hay productos cargados en Loyverse" : "No se encontraron productos"}
              </p>
            </div>
          )}
        </div>
      </div>
    </>
  );
}
