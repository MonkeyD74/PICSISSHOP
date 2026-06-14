export const dynamic = "force-dynamic";

export async function GET() {
  const token = process.env.LOYVERSE_TOKEN;
  
  if (!token) {
    return Response.json({ 
      error: "LOYVERSE_TOKEN no está configurado en Vercel",
      tokenExists: false 
    }, { status: 500 });
  }
  
  try {
    const res = await fetch("https://api.loyverse.com/v1.0/items?limit=5", {
      headers: { Authorization: `Bearer ${token}` },
      cache: "no-store",
    });
    
    const data = await res.json();
    
    return Response.json({
      tokenExists: true,
      tokenLength: token.length,
      status: res.status,
      itemCount: data.items?.length ?? 0,
      sample: data.items?.[0] ?? null,
      raw: data,
    });
  } catch (e) {
    return Response.json({ 
      tokenExists: true, 
      error: e.message 
    }, { status: 500 });
  }
}
