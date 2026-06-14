import Catalog from "../Catalog";
import { getProducts, getUniqueCategories } from "../lib/loyverse";

export default async function Page() {
  let products = [];
  let error = null;
  try {
    products = await getProducts();
  } catch (e) {
    error = e.message;
  }
  const categories = getUniqueCategories(products);
  return <Catalog products={products} categories={categories} error={error} />;
}
