import "./globals.css";

export const metadata = {
  title: "PICSIS SHOP — Catálogo 2026",
  description: "Compra de contado o elige tu plan a crédito. Informes por WhatsApp.",
};

export default function RootLayout({ children }) {
  return (
    <html lang="es">
      <body style={{ margin: 0, background: "#111" }}>{children}</body>
    </html>
  );
}
