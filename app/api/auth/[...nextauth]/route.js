import NextAuth from "next-auth"
import GoogleProvider from "next-auth/providers/google"

const ALLOWED_EMAILS = [
  "email1@gmail.com",
  "email2@gmail.com",
]

const handler = NextAuth({
  providers: [
    GoogleProvider({
      clientId: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    }),
  ],
  callbacks: {
    async signIn({ user }) {
      return ALLOWED_EMAILS.includes(user.email)
    },
  },
  pages: {
    signIn: "/login",
    error: "/acceso-denegado",
  },
})

export function GET(...args) {
  return handler(...args)
}

export function POST(...args) {
  return handler(...args)
}