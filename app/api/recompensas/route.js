import { NextResponse } from 'next/server'

export async function POST(req) {
  try {
    const { username, password } = await req.json()
    if (!username || !password)
      return NextResponse.json({ error: 'Ingresa usuario y contraseña' }, { status: 400 })

    const usersRaw = process.env.USERS_DB
    if (!usersRaw)
      return NextResponse.json({ error: 'Base de datos no configurada' }, { status: 500 })

    const users = JSON.parse(usersRaw)
    const found = users.find(u => u.username === username && u.password === password)
    if (!found)
      return NextResponse.json({ error: 'Usuario o contraseña incorrectos' }, { status: 401 })

    const res = await fetch(
      `https://api.loyverse.com/v1.0/customers/${found.loyverse_id}`,
      { headers: { Authorization: `Bearer ${process.env.LOYVERSE_TOKEN}` }, next: { revalidate: 60 } }
    )
    if (!res.ok)
      return NextResponse.json({ error: 'No se encontró el cliente en Loyverse' }, { status: 502 })

    const c = await res.json()
    return NextResponse.json({ nombre: c.name || found.username, puntos: c.total_points ?? 0, gastado: c.total_spent ?? 0 })
  } catch (e) {
    console.error(e)
    return NextResponse.json({ error: 'Error interno' }, { status: 500 })
  }
}
