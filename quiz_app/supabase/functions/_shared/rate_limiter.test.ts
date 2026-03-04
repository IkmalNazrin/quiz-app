import { assertEquals, assertNotEquals } from "https://deno.land/std@0.168.0/testing/asserts.ts";
import { rateLimit } from "./rate_limiter.ts";

Deno.test("rateLimit - allows requests under limit", () => {
    const identifier = "user_1";
    // Reset window manually if possible, but we'll use unique identifiers for now

    const res1 = rateLimit(identifier, 2, 60000);
    assertEquals(res1, null);

    const res2 = rateLimit(identifier, 2, 60000);
    assertEquals(res2, null);
});

Deno.test("rateLimit - blocks requests over limit", () => {
    const identifier = "user_2";

    rateLimit(identifier, 1, 60000); // 1st is OK
    const res2 = rateLimit(identifier, 1, 60000); // 2nd should trip limit

    assertNotEquals(res2, null);
    assertEquals(res2?.status, 429);
});
