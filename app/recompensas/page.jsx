"use client";
import { useState } from "react";

function PezosIcon({ size = 24 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 100 100" aria-label="pezos">
      <defs>
        <linearGradient id="pzBlue" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stopColor="#3b82f6" />
          <stop offset="100%" stopColor="#1e3a8a" />
        </linearGradient>
        <linearGradient id="pzPink" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stopColor="#ec4899" />
          <stop offset="100%" stopColor="#be185d" />
        </linearGradient>
      </defs>
      <circle cx="50" cy="50" r="48" fill="none" stroke="url(#pzPink)" strokeWidth="2.5" />
      <circle cx="50" cy="50" r="45" fill="url(#pzBlue)" />
      <path d="M50 5 a45 45 0 0 1 0 90 a22.5 22.5 0 0 1 0 -45 a22.5 22.5 0 0 0 0 -45 Z" fill="url(#pzPink)" />
      <circle cx="50" cy="27.5" r="7" fill="url(#pzBlue)" />
      <circle cx="50" cy="72.5" r="7" fill="url(#pzPink)" />
    </svg>
  );
}

const fmtMXN = (n) =>
  new Intl.NumberFormat("es-MX", { style: "currency", currency: "MXN" }).format(n);

export default function Recompensas() {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [data, setData] = useState(null);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);
  const [showInfo, setShowInfo] = useState(false);

  async function consultar() {
    setLoading(true);
    setError(null);
    setData(null);
    try {
      const res = await fetch("/api/recompensas", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username, password }),
      });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error || "Error al consultar");
      setData(json);
    } catch (e) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div style={{ minHeight: "100vh", background: "#0a0a12", color: "#f0f0f0", fontFamily: "'DM Sans', sans-serif", display: "flex", alignItems: "center", justifyContent: "center", padding: 20 }}>
      <div style={{ width: "100%", maxWidth: 380 }}>
        <div style={{ textAlign: "center", marginBottom: 28 }}>
          <PezosIcon size={72} />
          <h1 style={{ fontSize: 26, fontWeight: 700, margin: "12px 0 4px", background: "linear-gradient(90deg,#3b82f6,#ec4899)", WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent" }}>
            Mis Pezos
          </h1>
          <p style={{ color: "#888", fontSize: 13, margin: 0 }}>Consulta tus recompensas acumuladas</p>
        </div>

        {!data ? (
          <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
            <input value={username} onChange={(e) => setUsername(e.target.value)} placeholder="Usuario" style={inputStyle} />
            <input value={password} onChange={(e) => setPassword(e.target.value)} onKeyDown={(e) => e.key === "Enter" && consultar()} type="password" placeholder="Contrasena" style={inputStyle} />
            <button onClick={consultar} disabled={loading} style={{ padding: "13px 0", borderRadius: 10, border: "none", fontWeight: 700, fontSize: 14, cursor: loading ? "default" : "pointer", color: "#fff", background: "linear-gradient(90deg,#3b82f6,#ec4899)", opacity: loading ? 0.6 : 1 }}>
              {loading ? "Consultando..." : "Ver mis pezos"}
            </button>
            {error && <p style={{ color: "#ff7777", fontSize: 13, textAlign: "center", margin: "4px 0 0" }}>{error}</p>}
          </div>
        ) : (
          <div style={{ background: "#14141f", border: "1px solid #2a2a3a", borderRadius: 16, padding: 28, textAlign: "center" }}>
            <p style={{ color: "#aaa", fontSize: 14, margin: "0 0 4px" }}>Hola,</p>
            <p style={{ fontSize: 20, fontWeight: 600, margin: "0 0 20px" }}>{data.nombre}</p>
            <div style={{ display: "flex", alignItems: "center", justifyContent: "center", gap: 10, marginBottom: 8 }}>
              <PezosIcon size={40} />
              <span style={{ fontSize: 44, fontWeight: 800 }}>{(data.puntos ?? 0).toLocaleString("es-MX")}</span>
            </div>
            <p style={{ color: "#888", fontSize: 13, letterSpacing: 2, textTransform: "uppercase", margin: "0 0 24px" }}>pezos acumulados</p>
            <div style={{ borderTop: "1px solid #2a2a3a", paddingTop: 16, color: "#777", fontSize: 13 }}>
              Total gastado: <strong style={{ color: "#bbb" }}>{fmtMXN(data.gastado ?? 0)}</strong>
            </div>
            <button onClick={() => setShowInfo(true)} style={{ marginTop: 18, padding: "11px 0", width: "100%", borderRadius: 10, border: "none", background: "linear-gradient(90deg,#3b82f6,#ec4899)", color: "#fff", fontSize: 13, fontWeight: 700, cursor: "pointer" }}>
              Como funciona?
            </button>
            <button onClick={() => { setData(null); setPassword(""); }} style={{ marginTop: 10, padding: "10px 0", width: "100%", borderRadius: 10, border: "1px solid #2a2a3a", background: "transparent", color: "#aaa", fontSize: 13, fontWeight: 600, cursor: "pointer" }}>
              Salir
            </button>
          </div>
        )}
      </div>

      {showInfo && (
        <div onClick={() => setShowInfo(false)} style={{ position: "fixed", inset: 0, background: "rgba(0,0,0,0.8)", backdropFilter: "blur(4px)", display: "flex", alignItems: "center", justifyContent: "center", padding: 20, zIndex: 50 }}>
          <div onClick={(e) => e.stopPropagation()} style={{ position: "relative", maxWidth: 500, width: "100%" }}>
            <img src="/pezos.png" alt="Como funcionan los pezos" style={{ width: "100%", height: "auto", borderRadius: 14, display: "block" }} />
            <button onClick={() => setShowInfo(false)} style={{ position: "absolute", top: 10, right: 10, width: 34, height: 34, borderRadius: "50%", border: "none", background: "rgba(0,0,0,0.6)", color: "#fff", fontSize: 18, cursor: "pointer", lineHeight: 1 }}>X</button>
          </div>
        </div>
      )}
    </div>
  );
}

const inputStyle = {
  padding: "13px 16px",
  borderRadius: 10,
  border: "1px solid #2a2a3a",
  background: "#14141f",
  color: "#f0f0f0",
  fontSize: 14,
  outline: "none",
};
