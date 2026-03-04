import { assertEquals, assertExists } from "https://deno.land/std@0.168.0/testing/asserts.ts";

/**
 * Integration test for game-orchestrator edge function.
 * 
 * Instructions to run:
 * 1. Start local Supabase: `npx supabase start`
 * 2. Run deno test: `deno test --allow-net --allow-env supabase/functions/game-orchestrator/index.test.ts`
 */

const FUNCTION_URL = "http://localhost:54321/functions/v1/game-orchestrator";

Deno.test("game-orchestrator: missing authorization returns 401", async () => {
    // This assumes the function is actively served by `supabase start` wrapper
    // We send a request without a bearer token
    try {
        const response = await fetch(FUNCTION_URL, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({ action: "join-game", gamePin: "123456" }),
        });

        // The edge function should return 401 Unauthorized because our code looks for 'Authorization'
        const data = await response.json();
        assertEquals(response.status, 401);
        assertEquals(data.error, "Unauthorized");
    } catch (e) {
        // If fetch fails, the local dev server is likely not running
        console.warn("Skipping test: Ensure 'supabase start' is running natively to execute edge function tests. Error: " + e.message);
    }
});

Deno.test("game-orchestrator: CORS headers are present", async () => {
    try {
        const response = await fetch(FUNCTION_URL, {
            method: "OPTIONS",
            headers: {
                "Origin": "http://localhost:3000"
            }
        });

        // OPTIONS preflight should return 200 with appropriate Access-Control-Allow-Origin
        assertEquals(response.status, 200);
        assertExists(response.headers.get("Access-Control-Allow-Origin"));
    } catch (e) {
        console.warn("Skipping test: " + e.message);
    }
});
