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
