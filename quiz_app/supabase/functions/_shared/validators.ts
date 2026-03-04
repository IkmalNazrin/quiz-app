export function validateGameAction(body: any): { valid: boolean; error?: string } {
    const ALLOWED_ACTIONS = ["start-round", "end-round", "submit-answer", "end-game"];

    if (!body || typeof body !== "object") return { valid: false, error: "Invalid request body" };
    if (!body.action || !ALLOWED_ACTIONS.includes(body.action)) {
        return { valid: false, error: `Invalid action. Allowed: ${ALLOWED_ACTIONS.join(", ")}` };
    }
    if (!body.gamePin || typeof body.gamePin !== "string" || body.gamePin.length !== 6) {
        return { valid: false, error: "Invalid game pin format" };
    }

    // Action-specific validation
    if (body.action === "submit-answer") {
        const p = body.payload;
        if (!p || typeof p.answerIndex !== "number" || p.answerIndex < 0 || p.answerIndex > 9) {
            return { valid: false, error: "answerIndex must be 0-9" };
        }
    }
    if (body.action === "start-round") {
        const p = body.payload;
        if (!p || typeof p.questionIndex !== "number" || typeof p.duration !== "number") {
            return { valid: false, error: "start-round requires questionIndex and duration" };
        }
        if (p.duration < 5 || p.duration > 300) {
            return { valid: false, error: "duration must be 5-300 seconds" };
        }
    }

    return { valid: true };
}
