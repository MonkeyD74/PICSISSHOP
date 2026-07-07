#!/data/data/com.termux/files/usr/bin/bash
# ══════════════════════════════════════════════════════════
#  PISCIS SHOP — Recompensas por número de celular
#  (elimina login usuario/contraseña y USERS_DB)
#  Ejecutar dentro del repo:  bash recompensas-telefono.sh
# ══════════════════════════════════════════════════════════
set -e
if [ ! -d "app/api/recompensas" ]; then
  echo "❌ Ejecuta este script dentro de la carpeta del repo PICSISSHOP"; exit 1
fi
echo "→ 1/2 Escribiendo archivos..."
cat > app/api/recompensas/route.js << 'PISCIS_EOF_MARK'
import { NextResponse } from 'next/server'

// Normaliza a los últimos 10 dígitos (quita +52, espacios, guiones)
const norm = (s) => String(s || '').replace(/\D/g, '').slice(-10)

export async function POST(req) {
  try {
    const { telefono } = await req.json()
    const tel = norm(telefono)
    if (tel.length !== 10)
      return NextResponse.json({ error: 'Ingresa tu número de celular a 10 dígitos' }, { status: 400 })

    const token = process.env.LOYVERSE_TOKEN
    if (!token)
      return NextResponse.json({ error: 'Servicio no configurado' }, { status: 500 })

    // Loyverse no permite filtrar clientes por teléfono en la API,
    // así que se recorren páginas de 250 comparando el número normalizado.
    let cursor = null, found = null, pages = 0
    do {
      const url = new URL('https://api.loyverse.com/v1.0/customers')
      url.searchParams.set('limit', '250')
      if (cursor) url.searchParams.set('cursor', cursor)

      const res = await fetch(url, {
        headers: { Authorization: `Bearer ${token}` },
        next: { revalidate: 60 },
      })
      if (!res.ok)
        return NextResponse.json({ error: 'Error consultando el programa de lealtad' }, { status: 502 })

      const data = await res.json()
      found = (data.customers || []).find((c) => norm(c.phone_number) === tel)
      cursor = data.cursor || null
      pages++
    } while (!found && cursor && pages < 20)

    if (!found)
      return NextResponse.json(
        { error: 'No encontramos ese número. Regístrate en tienda o escríbenos por WhatsApp.' },
        { status: 404 }
      )

    return NextResponse.json({
      nombre: found.name || 'Cliente',
      puntos: found.total_points ?? 0,
      gastado: found.total_spent ?? 0,
    })
  } catch (e) {
    console.error(e)
    return NextResponse.json({ error: 'Error interno' }, { status: 500 })
  }
}
PISCIS_EOF_MARK

cat > components/RecompensasSection.jsx << 'PISCIS_EOF_MARK'
"use client"
import { useState } from "react"

const WA_NUMBER = "523521444391"
const CAT = "RECOMPENSAS"

function PrecioMX(n) {
  return new Intl.NumberFormat("es-MX", { style: "currency", currency: "MXN" }).format(n)
}

function PezosIcon({ size = 24 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 100 100" aria-label="pezos" style={{ display: "inline-block", verticalAlign: "middle" }}>
      <defs>
        <linearGradient id="pzB" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stopColor="#3b82f6" />
          <stop offset="100%" stopColor="#1e3a8a" />
        </linearGradient>
        <linearGradient id="pzP" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stopColor="#ec4899" />
          <stop offset="100%" stopColor="#be185d" />
        </linearGradient>
      </defs>
      <circle cx="50" cy="50" r="48" fill="none" stroke="url(#pzP)" strokeWidth="2.5" />
      <circle cx="50" cy="50" r="45" fill="url(#pzB)" />
      <path d="M50 5 a45 45 0 0 1 0 90 a22.5 22.5 0 0 1 0 -45 a22.5 22.5 0 0 0 0 -45 Z" fill="url(#pzP)" />
      <circle cx="50" cy="27.5" r="7" fill="url(#pzB)" />
      <circle cx="50" cy="72.5" r="7" fill="url(#pzP)" />
    </svg>
  )
}

function Card({ p }) {
  const wa = "https://wa.me/" + WA_NUMBER + "?text=" + encodeURIComponent("Hola, quiero canjear pezos por: " + p.name)
  return (
    <div
      onMouseEnter={e => { e.currentTarget.style.transform = "translateY(-4px)"; e.currentTarget.style.boxShadow = "0 8px 32px #7c3aed44" }}
      onMouseLeave={e => { e.currentTarget.style.transform = "translateY(0)"; e.currentTarget.style.boxShadow = "none" }}
      style={{ background: "linear-gradient(145deg,#1a1a2e,#16213e)", border: "1px solid #7c3aed40", borderRadius: 16, overflow: "hidden", display: "flex", flexDirection: "column", transition: "transform 0.2s,box-shadow 0.2s" }}
    >
      {p.image
        ? <img src={p.image} alt={p.name} style={{ width: "100%", height: 180, objectFit: "cover" }} />
        : <div style={{ width: "100%", height: 180, display: "flex", alignItems: "center", justifyContent: "center", background: "linear-gradient(135deg,#7c3aed22,#4f46e522)" }}><PezosIcon size={56} /></div>
      }
      <div style={{ padding: "14px 16px", flex: 1, display: "flex", flexDirection: "column", gap: 8 }}>
        <p style={{ margin: 0, color: "#e2e8f0", fontWeight: 700, fontSize: 15 }}>{p.name}</p>
        {p.price > 0 && <p style={{ margin: 0, color: "#a78bfa", fontWeight: 800, fontSize: 16 }}>{PrecioMX(p.price)}</p>}
        <div style={{ flex: 1 }} />
        <a href={wa} target="_blank" rel="noopener noreferrer"
          style={{ display: "block", textAlign: "center", background: "linear-gradient(135deg,#7c3aed,#4f46e5)", color: "#fff", fontWeight: 700, fontSize: 13, padding: "10px 0", borderRadius: 10, textDecoration: "none" }}>
          Canjear con pezos
        </a>
      </div>
    </div>
  )
}

export default function RecompensasSection({ products }) {
  const excl = products.filter(p => p.category && p.category.toUpperCase() === CAT)
  const [telefono, setTelefono] = useState("")
  const [est, setEst] = useState(null)

  async function submit(e) {
    e.preventDefault()
    setEst("cargando")
    try {
      const r = await fetch("/api/recompensas", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ telefono })
      })
      const d = await r.json()
      setEst(r.ok ? d : { error: d.error })
    } catch {
      setEst({ error: "Sin conexion. Intenta de nuevo." })
    }
  }

  return (
    <section id="recompensas" style={{ background: "linear-gradient(180deg,#0a0a14,#0d0d1f)", borderTop: "1px solid #7c3aed30", padding: "48px 16px 120px" }}>
      <div style={{ maxWidth: 960, margin: "0 auto" }}>

        <div style={{ textAlign: "center", marginBottom: 40 }}>
          <PezosIcon size={48} />
          <h2 style={{ margin: "8px 0 6px", color: "#e2e8f0", fontSize: "clamp(22px,5vw,32px)", fontWeight: 900 }}>
            Programa de Recompensas
          </h2>
          <p style={{ color: "#a78bfa", margin: 0, fontSize: 15 }}>
            Productos exclusivos · Solo con credito de reembolso
          </p>
          <div style={{ margin: "12px auto 0", width: 60, height: 3, borderRadius: 99, background: "linear-gradient(90deg,#7c3aed,#4f46e5)" }} />
        </div>

        {excl.length > 0 ? (
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill,minmax(200px,1fr))", gap: 20, marginBottom: 56 }}>
            {excl.map(p => <Card key={p.id} p={p} />)}
          </div>
        ) : (
          <div style={{ textAlign: "center", padding: "32px 0 48px", color: "#6b7280", fontSize: 15 }}>
            Proximamente productos exclusivos para canjear con pezos
          </div>
        )}

        <div style={{ borderTop: "1px solid #7c3aed20", margin: "0 0 40px" }} />

        <div style={{ maxWidth: 380, margin: "0 auto" }}>
          <h3 style={{ textAlign: "center", color: "#e2e8f0", fontWeight: 800, fontSize: 20, marginBottom: 6, display: "flex", alignItems: "center", justifyContent: "center", gap: 8 }}>
            <PezosIcon size={24} />
            Consulta tus pezos
            <PezosIcon size={24} />
          </h3>
          <p style={{ textAlign: "center", color: "#9ca3af", fontSize: 14, marginBottom: 24 }}>
            Ingresa tu número de celular para ver tu saldo
          </p>

          {est && est !== "cargando" && !est.error && (
            <div style={{ background: "linear-gradient(135deg,#7c3aed18,#4f46e518)", border: "1px solid #7c3aed60", borderRadius: 16, padding: "24px 20px", textAlign: "center", marginBottom: 24 }}>
              <p style={{ color: "#a78bfa", fontSize: 14, margin: "0 0 8px" }}>Hola, {est.nombre}</p>
              <div style={{ display: "flex", alignItems: "center", justifyContent: "center", gap: 10, margin: "0 0 4px" }}>
                <PezosIcon size={34} />
                <span style={{ color: "#fff", fontSize: 38, fontWeight: 900 }}>
                  {est.puntos.toLocaleString("es-MX")}
                </span>
              </div>
              <p style={{ color: "#7c3aed", fontSize: 13, margin: "0 0 16px", fontWeight: 700 }}>pezos acumulados</p>
              <p style={{ color: "#6b7280", fontSize: 12, margin: 0 }}>Total gastado: {PrecioMX(est.gastado)}</p>
              <button
                onClick={() => { setEst(null); setTelefono("") }}
                style={{ marginTop: 16, background: "transparent", border: "1px solid #7c3aed60", color: "#a78bfa", borderRadius: 8, padding: "6px 16px", cursor: "pointer", fontSize: 13 }}
              >
                Consultar otro número
              </button>
            </div>
          )}

          {(!est || est === "cargando" || est.error) && (
            <form onSubmit={submit} style={{ display: "flex", flexDirection: "column", gap: 14 }}>
              <div>
                <label style={{ color: "#9ca3af", fontSize: 13, display: "block", marginBottom: 6 }}>Número de celular</label>
                <input type="tel" inputMode="numeric" value={telefono}
                  onChange={e => setTelefono(e.target.value.replace(/[^\d\s+-]/g, ""))}
                  placeholder="10 dígitos" required maxLength={16}
                  style={{ width: "100%", padding: "12px 14px", borderRadius: 10, background: "#0f0f1e", border: "1px solid #7c3aed50", color: "#e2e8f0", fontSize: 15, outline: "none", boxSizing: "border-box" }} />
              </div>

              {est && est.error && (
                <p style={{ color: "#f87171", fontSize: 13, margin: 0, background: "#f8717115", border: "1px solid #f8717130", borderRadius: 8, padding: "8px 12px", textAlign: "center" }}>
                  {est.error}
                </p>
              )}

              <button type="submit" disabled={est === "cargando"}
                style={{ background: est === "cargando" ? "#4f46e580" : "linear-gradient(135deg,#7c3aed,#4f46e5)", color: "#fff", fontWeight: 800, fontSize: 15, border: "none", borderRadius: 12, padding: "14px", cursor: est === "cargando" ? "not-allowed" : "pointer" }}>
                {est === "cargando" ? "Consultando..." : "Ver mis pezos"}
              </button>
            </form>
          )}

          <p style={{ textAlign: "center", color: "#4b5563", fontSize: 12, marginTop: 20 }}>
            Sin cuenta?{" "}
            <a href={"https://wa.me/" + WA_NUMBER + "?text=" + encodeURIComponent("Hola, quiero registrarme en recompensas")}
              target="_blank" rel="noopener noreferrer" style={{ color: "#7c3aed", textDecoration: "none" }}>
              Escribenos por WhatsApp
            </a>
          </p>
        </div>
      </div>
    </section>
  )
}
PISCIS_EOF_MARK

cat > app/recompensas/page.jsx << 'PISCIS_EOF_MARK'
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
  const [telefono, setTelefono] = useState("");
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
        body: JSON.stringify({ telefono }),
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
          <div style={{ display: "flex", alignItems: "center", justifyContent: "center", gap: 8, marginTop: 6 }}><PezosIcon size={22} /><span style={{ color: "#aaa", fontSize: 15, fontWeight: 600 }}>Consulta tus pezos</span><PezosIcon size={22} /></div>
        </div>

        {!data ? (
          <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
            <input value={telefono} onChange={(e) => setTelefono(e.target.value.replace(/[^\d\s+-]/g, ""))} onKeyDown={(e) => e.key === "Enter" && consultar()} type="tel" inputMode="numeric" maxLength={16} placeholder="Número de celular (10 dígitos)" style={inputStyle} />
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
            <button onClick={() => { setData(null); setTelefono(""); }} style={{ marginTop: 10, padding: "10px 0", width: "100%", borderRadius: 10, border: "1px solid #2a2a3a", background: "transparent", color: "#aaa", fontSize: 13, fontWeight: 600, cursor: "pointer" }}>
              Salir
            </button>
          </div>
        )}
      </div>

      {showInfo && (
        <div onClick={() => setShowInfo(false)} style={{ position: "fixed", inset: 0, background: "rgba(0,0,0,0.8)", backdropFilter: "blur(4px)", display: "flex", alignItems: "center", justifyContent: "center", padding: 20, zIndex: 50 }}>
          <div onClick={(e) => e.stopPropagation()} style={{ position: "relative", maxWidth: 500, width: "100%" }}>
            <img src="/pezos.png" alt="Como funcionan los pezos" style={{ width: "100%", height: "auto", borderRadius: 14, display: "block" }} /><a href="/#recompensas" style={{ display: "block", textAlign: "center", marginTop: 14, padding: "13px 0", borderRadius: 10, background: "linear-gradient(90deg,#3b82f6,#ec4899)", color: "#fff", fontWeight: 700, fontSize: 15, textDecoration: "none" }}>Consultar mis pezos</a>
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
PISCIS_EOF_MARK

cat > package.json << 'PISCIS_EOF_MARK'
{
  "name": "picsis-shop",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start"
  },
  "dependencies": {
    "next": "^14.2.0",
    "react": "^18.3.0",
    "react-dom": "^18.3.0",
    "swiper": "^11.0.0"
  }
}
PISCIS_EOF_MARK

cat > package-lock.json << 'PISCIS_EOF_MARK'
{
  "name": "picsis-shop",
  "version": "1.0.0",
  "lockfileVersion": 3,
  "requires": true,
  "packages": {
    "": {
      "name": "picsis-shop",
      "version": "1.0.0",
      "dependencies": {
        "next": "^14.2.0",
        "react": "^18.3.0",
        "react-dom": "^18.3.0",
        "swiper": "^11.0.0"
      }
    },
    "node_modules/@next/env": {
      "version": "14.2.35",
      "resolved": "https://registry.npmjs.org/@next/env/-/env-14.2.35.tgz",
      "integrity": "sha512-DuhvCtj4t9Gwrx80dmz2F4t/zKQ4ktN8WrMwOuVzkJfBilwAwGr6v16M5eI8yCuZ63H9TTuEU09Iu2HqkzFPVQ==",
      "license": "MIT"
    },
    "node_modules/@next/swc-darwin-arm64": {
      "version": "14.2.33",
      "resolved": "https://registry.npmjs.org/@next/swc-darwin-arm64/-/swc-darwin-arm64-14.2.33.tgz",
      "integrity": "sha512-HqYnb6pxlsshoSTubdXKu15g3iivcbsMXg4bYpjL2iS/V6aQot+iyF4BUc2qA/J/n55YtvE4PHMKWBKGCF/+wA==",
      "cpu": [
        "arm64"
      ],
      "license": "MIT",
      "optional": true,
      "os": [
        "darwin"
      ],
      "engines": {
        "node": ">= 10"
      }
    },
    "node_modules/@next/swc-darwin-x64": {
      "version": "14.2.33",
      "resolved": "https://registry.npmjs.org/@next/swc-darwin-x64/-/swc-darwin-x64-14.2.33.tgz",
      "integrity": "sha512-8HGBeAE5rX3jzKvF593XTTFg3gxeU4f+UWnswa6JPhzaR6+zblO5+fjltJWIZc4aUalqTclvN2QtTC37LxvZAA==",
      "cpu": [
        "x64"
      ],
      "license": "MIT",
      "optional": true,
      "os": [
        "darwin"
      ],
      "engines": {
        "node": ">= 10"
      }
    },
    "node_modules/@next/swc-linux-arm64-gnu": {
      "version": "14.2.33",
      "resolved": "https://registry.npmjs.org/@next/swc-linux-arm64-gnu/-/swc-linux-arm64-gnu-14.2.33.tgz",
      "integrity": "sha512-JXMBka6lNNmqbkvcTtaX8Gu5by9547bukHQvPoLe9VRBx1gHwzf5tdt4AaezW85HAB3pikcvyqBToRTDA4DeLw==",
      "cpu": [
        "arm64"
      ],
      "license": "MIT",
      "optional": true,
      "os": [
        "linux"
      ],
      "engines": {
        "node": ">= 10"
      }
    },
    "node_modules/@next/swc-linux-arm64-musl": {
      "version": "14.2.33",
      "resolved": "https://registry.npmjs.org/@next/swc-linux-arm64-musl/-/swc-linux-arm64-musl-14.2.33.tgz",
      "integrity": "sha512-Bm+QulsAItD/x6Ih8wGIMfRJy4G73tu1HJsrccPW6AfqdZd0Sfm5Imhgkgq2+kly065rYMnCOxTBvmvFY1BKfg==",
      "cpu": [
        "arm64"
      ],
      "license": "MIT",
      "optional": true,
      "os": [
        "linux"
      ],
      "engines": {
        "node": ">= 10"
      }
    },
    "node_modules/@next/swc-linux-x64-gnu": {
      "version": "14.2.33",
      "resolved": "https://registry.npmjs.org/@next/swc-linux-x64-gnu/-/swc-linux-x64-gnu-14.2.33.tgz",
      "integrity": "sha512-FnFn+ZBgsVMbGDsTqo8zsnRzydvsGV8vfiWwUo1LD8FTmPTdV+otGSWKc4LJec0oSexFnCYVO4hX8P8qQKaSlg==",
      "cpu": [
        "x64"
      ],
      "license": "MIT",
      "optional": true,
      "os": [
        "linux"
      ],
      "engines": {
        "node": ">= 10"
      }
    },
    "node_modules/@next/swc-linux-x64-musl": {
      "version": "14.2.33",
      "resolved": "https://registry.npmjs.org/@next/swc-linux-x64-musl/-/swc-linux-x64-musl-14.2.33.tgz",
      "integrity": "sha512-345tsIWMzoXaQndUTDv1qypDRiebFxGYx9pYkhwY4hBRaOLt8UGfiWKr9FSSHs25dFIf8ZqIFaPdy5MljdoawA==",
      "cpu": [
        "x64"
      ],
      "license": "MIT",
      "optional": true,
      "os": [
        "linux"
      ],
      "engines": {
        "node": ">= 10"
      }
    },
    "node_modules/@next/swc-win32-arm64-msvc": {
      "version": "14.2.33",
      "resolved": "https://registry.npmjs.org/@next/swc-win32-arm64-msvc/-/swc-win32-arm64-msvc-14.2.33.tgz",
      "integrity": "sha512-nscpt0G6UCTkrT2ppnJnFsYbPDQwmum4GNXYTeoTIdsmMydSKFz9Iny2jpaRupTb+Wl298+Rh82WKzt9LCcqSQ==",
      "cpu": [
        "arm64"
      ],
      "license": "MIT",
      "optional": true,
      "os": [
        "win32"
      ],
      "engines": {
        "node": ">= 10"
      }
    },
    "node_modules/@next/swc-win32-ia32-msvc": {
      "version": "14.2.33",
      "resolved": "https://registry.npmjs.org/@next/swc-win32-ia32-msvc/-/swc-win32-ia32-msvc-14.2.33.tgz",
      "integrity": "sha512-pc9LpGNKhJ0dXQhZ5QMmYxtARwwmWLpeocFmVG5Z0DzWq5Uf0izcI8tLc+qOpqxO1PWqZ5A7J1blrUIKrIFc7Q==",
      "cpu": [
        "ia32"
      ],
      "license": "MIT",
      "optional": true,
      "os": [
        "win32"
      ],
      "engines": {
        "node": ">= 10"
      }
    },
    "node_modules/@next/swc-win32-x64-msvc": {
      "version": "14.2.33",
      "resolved": "https://registry.npmjs.org/@next/swc-win32-x64-msvc/-/swc-win32-x64-msvc-14.2.33.tgz",
      "integrity": "sha512-nOjfZMy8B94MdisuzZo9/57xuFVLHJaDj5e/xrduJp9CV2/HrfxTRH2fbyLe+K9QT41WBLUd4iXX3R7jBp0EUg==",
      "cpu": [
        "x64"
      ],
      "license": "MIT",
      "optional": true,
      "os": [
        "win32"
      ],
      "engines": {
        "node": ">= 10"
      }
    },
    "node_modules/@swc/counter": {
      "version": "0.1.3",
      "resolved": "https://registry.npmjs.org/@swc/counter/-/counter-0.1.3.tgz",
      "integrity": "sha512-e2BR4lsJkkRlKZ/qCHPw9ZaSxc0MVUd7gtbtaB7aMvHeJVYe8sOB8DBZkP2DtISHGSku9sCK6T6cnY0CtXrOCQ==",
      "license": "Apache-2.0"
    },
    "node_modules/@swc/helpers": {
      "version": "0.5.5",
      "resolved": "https://registry.npmjs.org/@swc/helpers/-/helpers-0.5.5.tgz",
      "integrity": "sha512-KGYxvIOXcceOAbEk4bi/dVLEK9z8sZ0uBB3Il5b1rhfClSpcX0yfRO0KmTkqR2cnQDymwLB+25ZyMzICg/cm/A==",
      "license": "Apache-2.0",
      "dependencies": {
        "@swc/counter": "^0.1.3",
        "tslib": "^2.4.0"
      }
    },
    "node_modules/busboy": {
      "version": "1.6.0",
      "resolved": "https://registry.npmjs.org/busboy/-/busboy-1.6.0.tgz",
      "integrity": "sha512-8SFQbg/0hQ9xy3UNTB0YEnsNBbWfhf7RtnzpL7TkBiTBRfrQ9Fxcnz7VJsleJpyp6rVLvXiuORqjlHi5q+PYuA==",
      "dependencies": {
        "streamsearch": "^1.1.0"
      },
      "engines": {
        "node": ">=10.16.0"
      }
    },
    "node_modules/caniuse-lite": {
      "version": "1.0.30001799",
      "resolved": "https://registry.npmjs.org/caniuse-lite/-/caniuse-lite-1.0.30001799.tgz",
      "integrity": "sha512-hG1bReV+OUU+MOqK4t/ZWI0tZOyz3rqS9XuhOUz1cIcbwBKjOyJEJuw9ER5JuNyqxNk8u/JUVbGibBOL1yrjFw==",
      "funding": [
        {
          "type": "opencollective",
          "url": "https://opencollective.com/browserslist"
        },
        {
          "type": "tidelift",
          "url": "https://tidelift.com/funding/github/npm/caniuse-lite"
        },
        {
          "type": "github",
          "url": "https://github.com/sponsors/ai"
        }
      ],
      "license": "CC-BY-4.0"
    },
    "node_modules/client-only": {
      "version": "0.0.1",
      "resolved": "https://registry.npmjs.org/client-only/-/client-only-0.0.1.tgz",
      "integrity": "sha512-IV3Ou0jSMzZrd3pZ48nLkT9DA7Ag1pnPzaiQhpW7c3RbcqqzvzzVu+L8gfqMp/8IM2MQtSiqaCxrrcfu8I8rMA==",
      "license": "MIT"
    },
    "node_modules/graceful-fs": {
      "version": "4.2.11",
      "resolved": "https://registry.npmjs.org/graceful-fs/-/graceful-fs-4.2.11.tgz",
      "integrity": "sha512-RbJ5/jmFcNNCcDV5o9eTnBLJ/HszWV0P73bc+Ff4nS/rJj+YaS6IGyiOL0VoBYX+l1Wrl3k63h/KrH+nhJ0XvQ==",
      "license": "ISC"
    },
    "node_modules/js-tokens": {
      "version": "4.0.0",
      "resolved": "https://registry.npmjs.org/js-tokens/-/js-tokens-4.0.0.tgz",
      "integrity": "sha512-RdJUflcE3cUzKiMqQgsCu06FPu9UdIJO0beYbPhHN4k6apgJtifcoCtT9bcxOpYBtpD2kCM6Sbzg4CausW/PKQ==",
      "license": "MIT"
    },
    "node_modules/loose-envify": {
      "version": "1.4.0",
      "resolved": "https://registry.npmjs.org/loose-envify/-/loose-envify-1.4.0.tgz",
      "integrity": "sha512-lyuxPGr/Wfhrlem2CL/UcnUc1zcqKAImBDzukY7Y5F/yQiNdko6+fRLevlw1HgMySw7f611UIY408EtxRSoK3Q==",
      "license": "MIT",
      "dependencies": {
        "js-tokens": "^3.0.0 || ^4.0.0"
      },
      "bin": {
        "loose-envify": "cli.js"
      }
    },
    "node_modules/nanoid": {
      "version": "3.3.12",
      "resolved": "https://registry.npmjs.org/nanoid/-/nanoid-3.3.12.tgz",
      "integrity": "sha512-ZB9RH/39qpq5Vu6Y+NmUaFhQR6pp+M2Xt76XBnEwDaGcVAqhlvxrl3B2bKS5D3NH3QR76v3aSrKaF/Kiy7lEtQ==",
      "funding": [
        {
          "type": "github",
          "url": "https://github.com/sponsors/ai"
        }
      ],
      "license": "MIT",
      "bin": {
        "nanoid": "bin/nanoid.cjs"
      },
      "engines": {
        "node": "^10 || ^12 || ^13.7 || ^14 || >=15.0.1"
      }
    },
    "node_modules/next": {
      "version": "14.2.35",
      "resolved": "https://registry.npmjs.org/next/-/next-14.2.35.tgz",
      "integrity": "sha512-KhYd2Hjt/O1/1aZVX3dCwGXM1QmOV4eNM2UTacK5gipDdPN/oHHK/4oVGy7X8GMfPMsUTUEmGlsy0EY1YGAkig==",
      "license": "MIT",
      "dependencies": {
        "@next/env": "14.2.35",
        "@swc/helpers": "0.5.5",
        "busboy": "1.6.0",
        "caniuse-lite": "^1.0.30001579",
        "graceful-fs": "^4.2.11",
        "postcss": "8.4.31",
        "styled-jsx": "5.1.1"
      },
      "bin": {
        "next": "dist/bin/next"
      },
      "engines": {
        "node": ">=18.17.0"
      },
      "optionalDependencies": {
        "@next/swc-darwin-arm64": "14.2.33",
        "@next/swc-darwin-x64": "14.2.33",
        "@next/swc-linux-arm64-gnu": "14.2.33",
        "@next/swc-linux-arm64-musl": "14.2.33",
        "@next/swc-linux-x64-gnu": "14.2.33",
        "@next/swc-linux-x64-musl": "14.2.33",
        "@next/swc-win32-arm64-msvc": "14.2.33",
        "@next/swc-win32-ia32-msvc": "14.2.33",
        "@next/swc-win32-x64-msvc": "14.2.33"
      },
      "peerDependencies": {
        "@opentelemetry/api": "^1.1.0",
        "@playwright/test": "^1.41.2",
        "react": "^18.2.0",
        "react-dom": "^18.2.0",
        "sass": "^1.3.0"
      },
      "peerDependenciesMeta": {
        "@opentelemetry/api": {
          "optional": true
        },
        "@playwright/test": {
          "optional": true
        },
        "sass": {
          "optional": true
        }
      }
    },
    "node_modules/picocolors": {
      "version": "1.1.1",
      "resolved": "https://registry.npmjs.org/picocolors/-/picocolors-1.1.1.tgz",
      "integrity": "sha512-xceH2snhtb5M9liqDsmEw56le376mTZkEX/jEb/RxNFyegNul7eNslCXP9FDj/Lcu0X8KEyMceP2ntpaHrDEVA==",
      "license": "ISC"
    },
    "node_modules/postcss": {
      "version": "8.4.31",
      "resolved": "https://registry.npmjs.org/postcss/-/postcss-8.4.31.tgz",
      "integrity": "sha512-PS08Iboia9mts/2ygV3eLpY5ghnUcfLV/EXTOW1E2qYxJKGGBUtNjN76FYHnMs36RmARn41bC0AZmn+rR0OVpQ==",
      "funding": [
        {
          "type": "opencollective",
          "url": "https://opencollective.com/postcss/"
        },
        {
          "type": "tidelift",
          "url": "https://tidelift.com/funding/github/npm/postcss"
        },
        {
          "type": "github",
          "url": "https://github.com/sponsors/ai"
        }
      ],
      "license": "MIT",
      "dependencies": {
        "nanoid": "^3.3.6",
        "picocolors": "^1.0.0",
        "source-map-js": "^1.0.2"
      },
      "engines": {
        "node": "^10 || ^12 || >=14"
      }
    },
    "node_modules/react": {
      "version": "18.3.1",
      "resolved": "https://registry.npmjs.org/react/-/react-18.3.1.tgz",
      "integrity": "sha512-wS+hAgJShR0KhEvPJArfuPVN1+Hz1t0Y6n5jLrGQbkb4urgPE/0Rve+1kMB1v/oWgHgm4WIcV+i7F2pTVj+2iQ==",
      "license": "MIT",
      "dependencies": {
        "loose-envify": "^1.1.0"
      },
      "engines": {
        "node": ">=0.10.0"
      }
    },
    "node_modules/react-dom": {
      "version": "18.3.1",
      "resolved": "https://registry.npmjs.org/react-dom/-/react-dom-18.3.1.tgz",
      "integrity": "sha512-5m4nQKp+rZRb09LNH59GM4BxTh9251/ylbKIbpe7TpGxfJ+9kv6BLkLBXIjjspbgbnIBNqlI23tRnTWT0snUIw==",
      "license": "MIT",
      "dependencies": {
        "loose-envify": "^1.1.0",
        "scheduler": "^0.23.2"
      },
      "peerDependencies": {
        "react": "^18.3.1"
      }
    },
    "node_modules/scheduler": {
      "version": "0.23.2",
      "resolved": "https://registry.npmjs.org/scheduler/-/scheduler-0.23.2.tgz",
      "integrity": "sha512-UOShsPwz7NrMUqhR6t0hWjFduvOzbtv7toDH1/hIrfRNIDBnnBWd0CwJTGvTpngVlmwGCdP9/Zl/tVrDqcuYzQ==",
      "license": "MIT",
      "dependencies": {
        "loose-envify": "^1.1.0"
      }
    },
    "node_modules/source-map-js": {
      "version": "1.2.1",
      "resolved": "https://registry.npmjs.org/source-map-js/-/source-map-js-1.2.1.tgz",
      "integrity": "sha512-UXWMKhLOwVKb728IUtQPXxfYU+usdybtUrK/8uGE8CQMvrhOpwvzDBwj0QhSL7MQc7vIsISBG8VQ8+IDQxpfQA==",
      "license": "BSD-3-Clause",
      "engines": {
        "node": ">=0.10.0"
      }
    },
    "node_modules/streamsearch": {
      "version": "1.1.0",
      "resolved": "https://registry.npmjs.org/streamsearch/-/streamsearch-1.1.0.tgz",
      "integrity": "sha512-Mcc5wHehp9aXz1ax6bZUyY5afg9u2rv5cqQI3mRrYkGC8rW2hM02jWuwjtL++LS5qinSyhj2QfLyNsuc+VsExg==",
      "engines": {
        "node": ">=10.0.0"
      }
    },
    "node_modules/styled-jsx": {
      "version": "5.1.1",
      "resolved": "https://registry.npmjs.org/styled-jsx/-/styled-jsx-5.1.1.tgz",
      "integrity": "sha512-pW7uC1l4mBZ8ugbiZrcIsiIvVx1UmTfw7UkC3Um2tmfUq9Bhk8IiyEIPl6F8agHgjzku6j0xQEZbfA5uSgSaCw==",
      "license": "MIT",
      "dependencies": {
        "client-only": "0.0.1"
      },
      "engines": {
        "node": ">= 12.0.0"
      },
      "peerDependencies": {
        "react": ">= 16.8.0 || 17.x.x || ^18.0.0-0"
      },
      "peerDependenciesMeta": {
        "@babel/core": {
          "optional": true
        },
        "babel-plugin-macros": {
          "optional": true
        }
      }
    },
    "node_modules/swiper": {
      "version": "11.2.10",
      "resolved": "https://registry.npmjs.org/swiper/-/swiper-11.2.10.tgz",
      "integrity": "sha512-RMeVUUjTQH+6N3ckimK93oxz6Sn5la4aDlgPzB+rBrG/smPdCTicXyhxa+woIpopz+jewEloiEE3lKo1h9w2YQ==",
      "funding": [
        {
          "type": "patreon",
          "url": "https://www.patreon.com/swiperjs"
        },
        {
          "type": "open_collective",
          "url": "http://opencollective.com/swiper"
        }
      ],
      "license": "MIT",
      "engines": {
        "node": ">= 4.7.0"
      }
    },
    "node_modules/tslib": {
      "version": "2.8.1",
      "resolved": "https://registry.npmjs.org/tslib/-/tslib-2.8.1.tgz",
      "integrity": "sha512-oJFu94HQb+KVduSUQL7wnpmqnfmLsOA/nAh6b6EH0wCEoK0/mPeXU6c3wKDV83MkOuHPRHtSXKKU99IBazS/2w==",
      "license": "0BSD"
    }
  }
}
PISCIS_EOF_MARK

echo "→ 2/2 Listo."
echo ""
echo "Siguiente:"
echo "  git add . && git commit -m 'Recompensas por numero de celular' && git push"
echo ""
echo "Después del push puedes BORRAR de Vercel la variable USERS_DB"
echo "(y GOOGLE_CLIENT_ID/SECRET, NEXTAUTH_* si existen — ya no se usan)."
