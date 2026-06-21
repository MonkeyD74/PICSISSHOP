export { default } from "next-auth/middleware"

export const config = {
  matcher: [
    "/((?!login|acceso-denegado|api/auth|_next|favicon.ico).*)",
  ],
}