"use client"
import { useState } from "react"

const WA_NUMBER = "523521444391"
const CAT = "RECOMPENSAS"

function PrecioMX(n) {
  return new Intl.NumberFormat("es-MX", { style: "currency", currency: "MXN" }).format(n)
}

function Card({ p }) {
  const wa = "https://wa.me/" + WA_NUMBER + "?text=" + encodeURIComponent("Hola, quiero canjear puntos por: " + p.name)
  return (
    <div
      onMouseEnter={e => { e.currentTarget.style.transform = "translateY(-4px)"; e.currentTarget.style.boxShadow = "0 8px 32px #7c3aed44" }}
      onMouseLeave={e => { e.currentTarget.style.transform = "translateY(0)"; e.currentTarget.style.boxShadow = "none" }}
      style={{ background: "linear-gradient(145deg,#1a1a2e,#16213e)", border: "1px solid #7c3aed40", borderRadius: 16, overflow: "hidden", display: "flex", flexDirection: "column", transition: "transform 0.2s,box-shadow 0.2s" }}
    >
      {p.image
        ? <img src={p.image} alt={p.name} style={{ width: "100%", height: 180, objectFit: "cover" }} />
        : <div style={{ width: "100%", height: 180, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 48, background: "linear-gradient(135deg,#7c3aed22,#4f46e522)" }}>💎</div>
      }
      <div style={{ padding: "14px 16px", flex: 1, display: "flex", flexDirection: "column", gap: 8 }}>
        <p style={{ margin: 0, color: "#e2e8f0", fontWeight: 700, fontSize: 15 }}>{p.name}</p>
        {p.price > 0 && <p style={{ margin: 0, color: "#a78bfa", fontWeight: 800, fontSize: 16 }}>{PrecioMX(p.price)}</p>}
        <div style={{ flex: 1 }} />
        <a href={wa} target="_blank" rel="noopener noreferrer"
          style={{ display: "block", textAlign: "center", background: "linear-gradient(135deg,#7c3aed,#4f46e5)", color: "#fff", fontWeight: 700, fontSize: 13, padding: "10px 0", borderRadius: 10, textDecoration: "none" }}>
          💬 Canjear con puntos
        </a>
      </div>
    </div>
  )
}

export default function RecompensasSection({ products }) {
  const excl = products.filter(p => p.category && p.category.toUpperCase() === CAT)
  const [form, setForm] = useState({ username: "", password: "" })
  const [est, setEst] = useState(null)
  const [showP, setShowP] = useState(false)

  async function submit(e) {
    e.preventDefault()
    setEst("cargando")
    try {
      const r = await fetch("/api/recompensas", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(form)
      })
      const d = await r.json()
      setEst(r.ok ? d : { error: d.error })
    } catch {
      setEst({ error: "Sin conexión. Intenta de nuevo." })
    }
  }

  return (
    <section id="recompensas" style={{ background: "linear-gradient(180deg,#0a0a14,#0d0d1f)", borderTop: "1px solid #7c3aed30", padding: "48px 16px 120px" }}>
      <div style={{ maxWidth: 960, margin: "0 auto" }}>

        <div style={{ textAlign: "center", marginBottom: 40 }}>
          <span style={{ fontSize: 36 }}>💎</span>
          <h2 style={{ margin: "8px 0 6px", color: "#e2e8f0", fontSize: "clamp(22px,5vw,32px)", fontWeight: 900 }}>
            Programa de Recompensas
          </h2>
          <p style={{ color: "#a78bfa", margin: 0, fontSize: 15 }}>
            Productos exclusivos · Solo con crédito de reembolso
          </p>
          <div style={{ margin: "12px auto 0", width: 60, height: 3, borderRadius: 99, background: "linear-gradient(90deg,#7c3aed,#4f46e5)" }} />
        </div>

        {excl.length > 0 ? (
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill,minmax(200px,1fr))", gap: 20, marginBottom: 56 }}>
            {excl.map(p => <Card key={p.id} p={p} />)}
          </div>
        ) : (
          <div style={{ textAlign: "center", padding: "32px 0 48px", color: "#6b7280", fontSize: 15 }}>
            Próximamente productos exclusivos para canjear con puntos
          </div>
        )}

        <div style={{ borderTop: "1px solid #7c3aed20", margin: "0 0 40px" }} />

        <div style={{ maxWidth: 380, margin: "0 auto" }}>
          <h3 style={{ textAlign: "center", color: "#e2e8f0", fontWeight: 800, fontSize: 20, marginBottom: 6 }}>
            Consulta tus puntos
          </h3>
          <p style={{ textAlign: "center", color: "#9ca3af", fontSize: 14, marginBottom: 24 }}>
            Ingresa tus credenciales para ver tu saldo
          </p>

          {est && est !== "cargando" && !est.error && (
            <div style={{ background: "linear-gradient(135deg,#7c3aed18,#4f46e518)", border: "1px solid #7c3aed60", borderRadius: 16, padding: "24px 20px", textAlign: "center", marginBottom: 24 }}>
              <p style={{ color: "#a78bfa", fontSize: 14, margin: "0 0 8px" }}>Hola, {est.nombre} 👋</p>
              <p style={{ color: "#fff", fontSize: 38, fontWeight: 900, margin: "0 0 4px" }}>
                {est.puntos.toLocaleString("es-MX")}
              </p>
              <p style={{ color: "#7c3aed", fontSize: 13, margin: "0 0 16px", fontWeight: 700 }}>puntos acumulados</p>
              <p style={{ color: "#6b7280", fontSize: 12, margin: 0 }}>Total gastado: {PrecioMX(est.gastado)}</p>
              <button
                onClick={() => { setEst(null); setForm({ username: "", password: "" }) }}
                style={{ marginTop: 16, background: "transparent", border: "1px solid #7c3aed60", color: "#a78bfa", borderRadius: 8, padding: "6px 16px", cursor: "pointer", fontSize: 13 }}
              >
                Cerrar sesión
              </button>
            </div>
          )}

          {(!est || est === "cargando" || est.error) && (
            <form onSubmit={submit} style={{ display: "flex", flexDirection: "column", gap: 14 }}>
              <div>
                <label style={{ color: "#9ca3af", fontSize: 13, display: "block", marginBottom: 6 }}>Usuario</label>
                <input type="text" value={form.username}
                  onChange={e => setForm(f => ({ ...f, username: e.target.value }))}
                  placeholder="tu usuario" required
                  style={{ width: "100%", padding: "12px 14px", borderRadius: 10, background: "#0f0f1e", border: "1px solid #7c3aed50", color: "#e2e8f0", fontSize: 15, outline: "none", boxSizing: "border-box" }} />
              </div>
              <div>
                <label style={{ color: "#9ca3af", fontSize: 13, display: "block", marginBottom: 6 }}>Contraseña</label>
                <div style={{ position: "relative" }}>
                  <input type={showP ? "text" : "password"} value={form.password}
                    onChange={e => setForm(f => ({ ...f, password: e.target.value }))}
                    placeholder="••••••••" required
                    style={{ width: "100%", padding: "12px 42px 12px 14px", borderRadius: 10, background: "#0f0f1e", border: "1px solid #7c3aed50", color: "#e2e8f0", fontSize: 15, outline: "none", boxSizing: "border-box" }} />
                  <button type="button" onClick={() => setShowP(v => !v)}
                    style={{ position: "absolute", right: 12, top: "50%", transform: "translateY(-50%)", background: "none", border: "none", cursor: "pointer", color: "#7c3aed", fontSize: 16, padding: 0 }}>
                    {showP ? "🙈" : "👁️"}
                  </button>
                </div>
              </div>

              {est && est.error && (
                <p style={{ color: "#f87171", fontSize: 13, margin: 0, background: "#f8717115", border: "1px solid #f8717130", borderRadius: 8, padding: "8px 12px", textAlign: "center" }}>
                  {est.error}
                </p>
              )}

              <button type="submit" disabled={est === "cargando"}
                style={{ background: est === "cargando" ? "#4f46e580" : "linear-gradient(135deg,#7c3aed,#4f46e5)", color: "#fff", fontWeight: 800, fontSize: 15, border: "none", borderRadius: 12, padding: "14px", cursor: est === "cargando" ? "not-allowed" : "pointer" }}>
                {est === "cargando" ? "Consultando..." : "Ver mis puntos 💎"}
              </button>
            </form>
          )}

          <p style={{ textAlign: "center", color: "#4b5563", fontSize: 12, marginTop: 20 }}>
            ¿Sin cuenta?{" "}
            <a href={"https://wa.me/" + WA_NUMBER + "?text=" + encodeURIComponent("Hola, quiero registrarme en recompensas")}
              target="_blank" rel="noopener noreferrer" style={{ color: "#7c3aed", textDecoration: "none" }}>
              Escríbenos por WhatsApp
            </a>
          </p>
        </div>
      </div>
    </section>
  )
}
