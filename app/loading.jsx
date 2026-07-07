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
