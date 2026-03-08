import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { WebhookService } from "../_shared/webhook_service.ts";
import { securityMiddleware } from "../_shared/security_middleware.ts";
import { validateGameAction } from "../_shared/validators.ts";
import { rateLimit } from "../_shared/rate_limiter.ts";
import { UnauthorizedError, ForbiddenError, NotFoundError, AppError } from "../_shared/errors.ts";

import { getCorsHeaders } from "../_shared/cors_headers.ts";
serve(async (req) => {
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: getCorsHeaders(req) });
    }

    try {
        const securityBlock = await securityMiddleware(req);
        if (securityBlock) return securityBlock;

        const supabaseClient = createClient(
            Deno.env.get("SUPABASE_URL") ?? "",
            Deno.env.get("SUPABASE_ANON_KEY") ?? "",
            { global: { headers: { Authorization: req.headers.get("Authorization")! } } }
        );

        const { data: { user }, error: userError } = await supabaseClient.auth.getUser();
        if (userError || !user) throw new UnauthorizedError();

        const rateLimitBlock = await rateLimit(user.id);
        if (rateLimitBlock) return rateLimitBlock;

        const body = await req.json();

        const validation = validateGameAction(body);
        if (!validation.valid) {
            return new Response(JSON.stringify({ error: validation.error }), {
                headers: { ...getCorsHeaders(req), "Content-Type": "application/json" },
                status: 400,
            });
        }

        const { action, gamePin, payload } = body;

        // 1. Validate Session & Permissions
        const { data: session, error: sessionError } = await supabaseClient
            .from("game_sessions")
            .select("id, host_id, status, organization_id, current_question_index, quiz_id, round_ends_at")
            .eq("game_pin", gamePin)
            .single();

        if (sessionError || !session) throw new NotFoundError("Game session not found");
        if (action !== "submit-answer" && session.host_id !== user.id) {
            throw new ForbiddenError("Only the host can perform this action");
        }

        let result = {};

        if (action === "submit-answer") {
            const { userId, answerIndex, isDoubleDown } = payload;

            if (userId !== user.id) throw new Error("Cannot submit answer for another user");
            if (session.status !== "playing") throw new Error("Round is not active");
            if (session.round_ends_at && new Date() > new Date(session.round_ends_at)) {
                throw new Error("Round has already ended");
            }

            const { data: question, error: qError } = await supabaseClient
                .from("questions")
                .select("correct_index, timer_seconds")
                .eq("quiz_id", session.quiz_id)
                .eq("order_index", session.current_question_index)
                .single();

            if (qError || !question) throw new NotFoundError("Question not found");

            const isCorrect = answerIndex === question.correct_index;
            let points = isCorrect ? 100 : 0;

            if (isDoubleDown && isCorrect) points *= 2;
            else if (isDoubleDown && !isCorrect) points = -100;

            const { error: insertError } = await supabaseClient
                .from("game_answers")
                .insert({
                    session_id: session.id,
                    user_id: user.id,
                    question_index: session.current_question_index,
                    is_correct: isCorrect,
                    answer_index: answerIndex,
                    points: points,
                });

            // Update game_participants score atomically via SECURITY DEFINER RPC
            // to defend against read-then-write race conditions.
            if (!insertError && points !== 0) {
                const { error: scoreError } = await supabaseClient.rpc(
                    "increment_participant_score",
                    { p_session_id: session.id, p_user_id: user.id, p_points: points }
                );
                if (scoreError) console.error("Score update failed:", scoreError.message);
            }

            result = { points, isCorrect };

        } else if (action === "start-round") {
            const { questionIndex, duration } = payload;
            const roundEndsAt = new Date(Date.now() + duration * 1000).toISOString();

            const { error: updateError } = await supabaseClient
                .from("game_sessions")
                .update({
                    status: "playing",
                    current_question_index: questionIndex,
                    round_started_at: new Date().toISOString(),
                    round_ends_at: roundEndsAt,
                })
                .eq("id", session.id);

            if (updateError) throw updateError;
            result = { roundEndsAt };

            // Dispatch Webhook
            if (session.organization_id) {
                WebhookService.dispatch(
                    Deno.env.get("SUPABASE_URL")!,
                    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
                    session.organization_id,
                    "round.started",
                    { gamePin, questionIndex, roundEndsAt }
                ).catch(console.error);
            }

        } else if (action === "end-round") {
            const { error: updateError } = await supabaseClient
                .from("game_sessions")
                .update({ status: "roundOver" })
                .eq("id", session.id);

            if (updateError) throw updateError;

            // Fetch results to broadcast
            const { data: answers } = await supabaseClient
                .from("game_answers")
                .select("user_id, is_correct")
                .eq("session_id", session.id);

            result = { status: "roundOver", answers };

            // Dispatch Webhook
            if (session.organization_id) {
                WebhookService.dispatch(
                    Deno.env.get("SUPABASE_URL")!,
                    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
                    session.organization_id,
                    "round.ended",
                    { gamePin, answers }
                ).catch(console.error);
            }
        } else if (action === "end-game") {
            const { error: updateError } = await supabaseClient
                .from("game_sessions")
                .update({ status: "completed", ended_at: new Date().toISOString() })
                .eq("id", session.id);

            if (updateError) throw updateError;

            // Fetch final standings
            const { data: participants } = await supabaseClient
                .from("game_participants")
                .select("user_id, score, team_name")
                .eq("session_id", session.id)
                .order("score", { ascending: false });

            result = { status: "completed", standings: participants };

            // Dispatch Webhook
            if (session.organization_id) {
                WebhookService.dispatch(
                    Deno.env.get("SUPABASE_URL")!,
                    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
                    session.organization_id,
                    "game.completed",
                    { gamePin, standings: participants }
                ).catch(console.error);
            }
        }

        return new Response(JSON.stringify(result), {
            headers: { ...getCorsHeaders(req), "Content-Type": "application/json" },
            status: 200,
        });
    } catch (error) {
        const message = (error as Error).message;
        const status = error instanceof AppError ? (error as AppError).statusCode : 400;

        return new Response(JSON.stringify({ error: message }), {
            headers: { ...getCorsHeaders(req), "Content-Type": "application/json" },
            status,
        });
    }
});
