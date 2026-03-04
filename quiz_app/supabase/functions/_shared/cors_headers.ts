const ALLOWED_ORIGINS = (Deno.env.get("ALLOWED_ORIGINS") ?? "")
    .split(",").map(s => s.trim()).filter(Boolean);

export function getCorsHeaders(req: Request): Record<string, string> {
    const origin = req.headers.get("Origin") ?? "";
    const isAllowed = ALLOWED_ORIGINS && ALLOWED_ORIGINS.length > 0 ? ALLOWED_ORIGINS.includes(origin) : false;
    return {
        "Access-Control-Allow-Origin": isAllowed && origin ? origin : "",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Vary": "Origin, Accept-Encoding",
        "Cache-Control": "no-cache, no-store, must-revalidate",
    };
}
