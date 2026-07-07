import "./globals.css";

export const metadata = {
  title: "PICSIS SHOP — Catálogo 2026",
  description: "Compra de contado o elige tu plan a crédito. Informes por WhatsApp.",
};

export default function RootLayout({ children }) {
  return (
    <html lang="es">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link
          href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Playfair+Display:wght@500;600;700&display=swap"
          rel="stylesheet"
        />
      </head>
      <body style={{ margin: 0, background: "#111" }}>{children}</body>
    </html>
  );
}
