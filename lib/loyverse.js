// Helper para consumir la API de Loyverse desde el servidor
// El token va en la variable de entorno LOYVERSE_TOKEN (configurada en Vercel)
const LOYVERSE_API = "https://api.loyverse.com/v1.0";

async function loyverseFetch(path) {
  const token = process.env.LOYVERSE_TOKEN;
  if (!token) throw new Error("LOYVERSE_TOKEN env variable is not set");
  const res = await fetch(`${LOYVERSE_API}${path}`, {
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    // Next.js cachea la respuesta 5 min (ISR). Cambia revalidate si quieres más/menos frescura.
    next: { revalidate: 300 },
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`Loyverse ${path} → ${res.status}: ${body.slice(0, 200)}`);
  }
  return res.json();
}

// Parsea la descripción de Loyverse buscando líneas "Clave: Valor"
// Para que aparezcan specs en el catálogo, escribe la descripción del producto así en Loyverse:
//   Material: Piel genuina
//   Color: Negro
//   Talla: Variable
function parseSpecs(description) {
  if (!description) return {};
  const specs = {};
  for (const line of description.split(/\r?\n/)) {
    const m = line.match(/^\s*([^:]+?)\s*:\s*(.+)\s*$/);
    if (m) specs[m[1]] = m[2];
  }
  return specs;
}

// Loyverse guarda los precios en varios lugares según el "pricing_type".
// Esta función los busca en orden de prioridad y devuelve el primero que encuentre.
function getVariantPrice(variant) {
  // 1) Pricing FIXED a nivel de variante
  if (variant?.default_price != null) {
    return Number(variant.default_price);
  }
  // 2) Pricing por tienda (cuando default_pricing_type es "VARIABLE")
  //    Toma el primer store con precio definido.
  const store = (variant?.stores || []).find((s) => s?.price != null);
  if (store) {
    return Number(store.price);
  }
  // 3) Sin precio
  return 0;
}

export async function getProducts() {
  // Categorías e items en paralelo
  const [categoriesData, itemsData] = await Promise.all([
    loyverseFetch("/categories?limit=250"),
    loyverseFetch("/items?limit=250"),
  ]);

  // category_id → nombre legible
  const categoryMap = Object.fromEntries(
    (categoriesData.categories || []).map((c) => [c.id, c.name])
  );

  return (itemsData.items || [])
    .filter((item) => !item.deleted_at)
    .map((item) => {
      const variants = item.variants || [];
      const firstVariant = variants[0];

      // Tallas: si hay más de una variante, los option1_value son las tallas
      const sizes =
        variants.length > 1
          ? variants.map((v) => v.option1_value).filter(Boolean)
          : [];

      return {
        id: item.id,
        name: item.item_name || "Sin nombre",
        category: categoryMap[item.category_id] || "Otros",
        price: getVariantPrice(firstVariant),
        image: item.image_url || "",
        sizes,
        specs: parseSpecs(item.description),
      };
    });
}

export function getUniqueCategories(products) {
  const set = new Set(products.map((p) => p.category));
  return ["Todos", ...Array.from(set).sort()];
}
