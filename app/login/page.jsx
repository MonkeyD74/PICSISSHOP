"use client"
import { signIn } from "next-auth/react"

export default function Login() {
  return (
    <div style={{ display: "flex", justifyContent: "center", alignItems: "center", height: "100vh", flexDirection: "column" }}>
      <h1>Piscisshop</h1>
      <p>Catálogo privado — solo acceso autorizado</p>
      <button 
        onClick={() => signIn("google", { callbackUrl: "/" })}
        style={{ padding: "12px 24px", fontSize: "16px", cursor: "pointer", marginTop: "20px" }}
      >
        Entrar con Google
      </button>
    </div>
  )
}