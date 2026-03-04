import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

export class WebhookService {
    private static async generateSignature(payload: string, secret: string): Promise<string> {
        const encoder = new TextEncoder();
        const keyData = encoder.encode(secret);
        const data = encoder.encode(payload);

        const key = await crypto.subtle.importKey(
            "raw",
            keyData,
            { name: "HMAC", hash: "SHA-256" },
            false,
            ["sign"]
        );

        const signature = await crypto.subtle.sign("HMAC", key, data);
        return Array.from(new Uint8Array(signature))
            .map((b) => b.toString(16).padStart(2, "0"))
            .join("");
    }

    static async dispatch(
        supabaseUrl: string,
        supabaseServiceRoleKey: string,
        organizationId: string,
        eventType: string,
        payload: any
    ) {
        const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

        // 1. Get active webhooks for the organization
        const { data: webhooks, error } = await supabase
            .from("webhooks")
            .select("id, url, secret")
            .eq("organization_id", organizationId)
            .eq("is_active", true)
            .contains("events", [eventType]);

        if (error || !webhooks) return;

        const payloadString = JSON.stringify({
            event_type: eventType,
            timestamp: new Date().toISOString(),
            data: payload,
        });

        // 2. Dispatch to each webhook
        const promises = webhooks.map(async (webhook) => {
            const start = Date.now();
            let status = 0;
            let body = "";
            let errorMessage = "";

            try {
                const signature = await this.generateSignature(payloadString, webhook.secret);

                const response = await fetch(webhook.url, {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                        "X-QuizApp-Signature": signature,
                        "X-QuizApp-Event": eventType,
                    },
                    body: payloadString,
                });

                status = response.status;
                body = await response.text();
            } catch (e) {
                errorMessage = (e as Error).message;
            }

            // 3. Log results
            await supabase.from("webhook_logs").insert({
                webhook_id: webhook.id,
                event_type: eventType,
                payload: payload,
                response_status: status,
                response_body: body.substring(0, 1000), // Cap body size
                error_message: errorMessage,
                execution_time_ms: Date.now() - start,
            });
        });

        await Promise.allSettled(promises);
    }
}
