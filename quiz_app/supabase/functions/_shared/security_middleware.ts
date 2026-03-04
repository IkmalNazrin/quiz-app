/**
 * Security Middleware for Supabase Edge Functions.
 * 
 * Rate limiting and WAF-level protections (IP reputation, DDoS,
 * bot detection) are handled at the infrastructure layer (Cloudflare/Supabase).
 * This middleware handles only application-level security checks.
 */

const BLOCKED_REGIONS = (Deno.env.get("BLOCKED_REGIONS") ?? "").split(",").map((r: string) => r.trim()).filter(Boolean);

export async function securityMiddleware(req: Request) {
    // Geo-blocking via CDN-injected header (Cloudflare: CF-IPCountry)
    // Only effective when deployed behind Cloudflare; no-op locally.
    const country = req.headers.get('cf-ipcountry');

    if (country && BLOCKED_REGIONS.includes(country)) {
        return new Response('Access denied for your region', { status: 403 });
    }

    return null; // All checks passed
}
