import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-client@2";

const ALLOWED_ORIGINS = (Deno.env.get("ALLOWED_ORIGINS") ?? "").split(",").map(s => s.trim()).filter(Boolean);

function getCorsHeaders(req: Request) {
    const origin = req.headers.get("Origin") ?? "";
    const isAllowed = ALLOWED_ORIGINS.includes(origin);
    return {
        "Access-Control-Allow-Origin": isAllowed ? origin : (ALLOWED_ORIGINS[0] ?? ""),
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
        "Vary": "Origin, Accept-Encoding",
        "Cache-Control": "max-age=60, s-maxage=120", // Allow intermediate edge caches for 1-2 minutes to prevent DDOS
    };
}

serve(async (req) => {
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: getCorsHeaders(req) });
    }

    try {
        const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
        const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";

        const supabase = createClient(supabaseUrl, supabaseAnonKey);

        // Verify Database availability (Simple ping)
        const start = Date.now();
        const { error } = await supabase.from('profiles').select('id').limit(1);
        const latency = Date.now() - start;

        if (error) throw error;

        return new Response(JSON.stringify({
            status: "healthy",
            timestamp: new Date().toISOString(),
            db_latency: `${latency}ms`
        }), {
            headers: { ...getCorsHeaders(req), "Content-Type": "application/json" },
            status: 200,
        });

    } catch (error) {
        return new Response(JSON.stringify({ status: "unhealthy", error: (error as Error).message }), {
            headers: { ...getCorsHeaders(req), "Content-Type": "application/json" },
            status: 503,
        });
    }
});
