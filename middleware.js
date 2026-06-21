import { NextResponse } from 'next/server'

const USER = 'picsis'
const PASSWORD = 'shop2024'

export function middleware(req) {
  const authHeader = req.headers.get('authorization')

  if (authHeader) {
    const base64 = authHeader.split(' ')[1]
    const decoded = atob(base64)
    const [user, password] = decoded.split(':')

    if (user === USER && password === PASSWORD) {
      return NextResponse.next()
    }
  }

  return new NextResponse('Acceso denegado', {
    status: 401,
    headers: {
      'WWW-Authenticate': 'Basic realm="Piscisshop"',
    },
  })
}

export const config = {
  matcher: ['/((?!_next|favicon.ico).*)'],
}
