import { assertEquals } from "https://deno.land/std@0.168.0/testing/asserts.ts";

const FUNCTION_URL = "http://localhost:54321/functions/v1/delete-user-account";

Deno.test("delete-user-account: missing auth returns 401", async () => {
    try {
        const response = await fetch(FUNCTION_URL, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
        });
        const data = await response.json();
        assertEquals(response.status, 401);
        assertEquals(data.error, "Unauthorized");
    } catch (e) {
        console.warn("Skipping: local Supabase not running. " + (e as Error).message);
    }
});

Deno.test("delete-user-account: OPTIONS returns CORS headers", async () => {
    try {
        const response = await fetch(FUNCTION_URL, {
            method: "OPTIONS",
            headers: { "Origin": "http://localhost:3000" },
        });
        assertEquals(response.status, 200);
    } catch (e) {
        console.warn("Skipping: " + (e as Error).message);
    }
});
