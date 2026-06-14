export const metadata = {
  title: "PICSIS SHOP",
  description: "Catálogo PICSIS SHOP — Pide informes por WhatsApp",
};

export default function RootLayout({ children }) {
  return (
    <html lang="es">
      <body style={{ margin: 0 }}>{children}</body>
    </html>
  );
}
