import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

export async function rateLimit(
    identifier: string,
    maxRequests: number = 30,
    windowMs: number = 60_000
): Promise<Response | null> {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

    if (!supabaseUrl || !supabaseServiceKey) {
        console.error("Missing Supabase credentials for rate limiting.");
        return new Response(JSON.stringify({ error: "Service unavailable" }), { status: 503 }); // fail-closed
    }

    const adminClient = createClient(supabaseUrl, supabaseServiceKey);
    const windowSec = Math.ceil(windowMs / 1000);

    try {
        const { data, error } = await adminClient.rpc("check_rate_limit", {
            p_identifier: identifier,
            p_max_requests: maxRequests,
            p_window_seconds: windowSec
        });

        if (error) throw error;

        if (data && !data.allowed) {
            return new Response(
                JSON.stringify({ error: "Rate limit exceeded" }),
                {
                    status: 429,
                    headers: {
                        "Content-Type": "application/json",
                        "Retry-After": String(data.retry_after || windowSec)
                    }
                }
            );
        }
    } catch (e) {
        console.error("Rate limiter unavailable:", (e as Error).message);
        return new Response(JSON.stringify({ error: "Service unavailable" }), { status: 503 }); // fail-closed
    }

    return null;
}
