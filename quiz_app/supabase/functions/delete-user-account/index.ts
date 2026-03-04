import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { securityMiddleware } from "../_shared/security_middleware.ts";
import { rateLimit } from "../_shared/rate_limiter.ts";

import { getCorsHeaders } from "../_shared/cors_headers.ts";

serve(async (req) => {
    // Handle CORS
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: getCorsHeaders(req) });
    }

    try {
        const securityBlock = await securityMiddleware(req);
        if (securityBlock) return securityBlock;

        const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
        const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
        const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

        // 1. Validate User Identity (using Anon Key client with user's Auth Header)
        const userClient = createClient(supabaseUrl, supabaseAnonKey, {
            global: { headers: { Authorization: req.headers.get("Authorization")! } }
        });

        const { data: { user }, error: userError } = await userClient.auth.getUser();
        if (userError || !user) throw new Error("Unauthorized");

        const rateLimitBlock = await rateLimit(user.id, 3, 300_000); // Strict limit for account deletion
        if (rateLimitBlock) return rateLimitBlock;

        console.log(`Deletion requested for user: ${user.id.substring(0, 8)}...`);

        // 2. Perform Admin Actions (using Service Role Client)
        const adminClient = createClient(supabaseUrl, supabaseServiceKey);

        // A. Log the event explicitly before deletion
        await adminClient.from("security_audit_logs").insert({
            user_id: user.id,
            event_type: "ACCOUNT_DELETION_INITIATED",
            details: { reason: "User requested deletion", timestamp: new Date().toISOString() }
        });

        // B. Anonymize public profile data (per ADR 021)
        const { error: anonError } = await adminClient
            .from('users')
            .update({ name: 'Deleted User', email: null, avatar_url: null })
            .eq('id', user.id);

        if (anonError) {
            console.error('Anonymization failed, aborting deletion:', anonError.message);
            throw new Error('Account deletion failed during anonymization');
        }

        // C. Delete from auth.users (This will trigger cascading deletes in public tables if configured)
        const { error: deleteError } = await adminClient.auth.admin.deleteUser(user.id);

        if (deleteError) throw deleteError;

        console.log(`Successfully deleted user: [REDACTED]`);

        return new Response(JSON.stringify({ message: "Account deleted successfully" }), {
            headers: { ...getCorsHeaders(req), "Content-Type": "application/json" },
            status: 200,
        });

    } catch (error) {
        let status = 400;
        const msg = (error as Error).message;
        if (msg === "Unauthorized") status = 401;
        console.error(`Deletion error: ${msg}`);
        return new Response(JSON.stringify({ error: msg }), {
            headers: { ...getCorsHeaders(req), "Content-Type": "application/json" },
            status,
        });
    }
});
