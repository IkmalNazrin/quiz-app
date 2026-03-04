import { assertEquals } from "https://deno.land/std@0.168.0/testing/asserts.ts";
import { validateGameAction } from "./validators.ts";

Deno.test("validateGameAction - Valid submit-answer", () => {
    const result = validateGameAction({
        action: "submit-answer",
        gamePin: "123456",
        payload: { answerIndex: 2 }
    });
    assertEquals(result.valid, true);
});

Deno.test("validateGameAction - Invalid action", () => {
    const result = validateGameAction({
        action: "hack-game",
        gamePin: "123456"
    });
    assertEquals(result.valid, false);
    assertEquals(result.error?.includes("Invalid action"), true);
});

Deno.test("validateGameAction - Invalid game pin format", () => {
    const result = validateGameAction({
        action: "submit-answer",
        gamePin: "1234" // Too short
    });
    assertEquals(result.valid, false);
    assertEquals(result.error?.includes("Invalid game pin format"), true);
});

Deno.test("validateGameAction - Invalid answerIndex out of bounds", () => {
    const result = validateGameAction({
        action: "submit-answer",
        gamePin: "123456",
        payload: { answerIndex: 15 }
    });
    assertEquals(result.valid, false);
    assertEquals(result.error?.includes("answerIndex must be 0-9"), true);
});

Deno.test("validateGameAction - Valid start-round", () => {
    const result = validateGameAction({
        action: "start-round",
        gamePin: "123456",
        payload: { questionIndex: 1, duration: 30 }
    });
    assertEquals(result.valid, true);
});

Deno.test("validateGameAction - Missing payload on start-round", () => {
    const result = validateGameAction({
        action: "start-round",
        gamePin: "123456"
    });
    assertEquals(result.valid, false);
    assertEquals(result.error?.includes("start-round requires questionIndex and duration"), true);
});
