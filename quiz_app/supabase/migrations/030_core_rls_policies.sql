-- ==========================================
-- Migration: 030_core_rls_policies
-- Date: 2026-03-08
-- Description: Adds RLS policies for all core domain tables.
--   RLS was enabled (migrations 005, 006) but no policies existed,
--   meaning all access via the anon/authenticated key was silently denied.
--   This migration establishes least-privilege access for all tables.
-- Related ADR: ADR-026 (Security Remediation), ADR-021 (Client Security Hardening)
-- ==========================================

-- ===========================================================
-- TABLE: profiles
-- Policy: Public read (user directory), self-write only.
-- ===========================================================
DROP POLICY IF EXISTS "Anyone can view profiles" ON public.profiles;
CREATE POLICY "Anyone can view profiles"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT
  TO authenticated
  WITH CHECK (id = auth.uid());

DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- DELETE is handled exclusively by delete_user_account() SECURITY DEFINER function.
-- No direct delete policy is granted to prevent accidental data loss.

-- ===========================================================
-- TABLE: quizzes
-- Policy: Read public or own; full CRUD on own quizzes only.
-- ===========================================================
DROP POLICY IF EXISTS "Anyone can view public or own quizzes" ON public.quizzes;
CREATE POLICY "Anyone can view public or own quizzes"
  ON public.quizzes FOR SELECT
  TO authenticated
  USING (is_public = true OR owner_id = auth.uid());

DROP POLICY IF EXISTS "Owner can insert quizzes" ON public.quizzes;
CREATE POLICY "Owner can insert quizzes"
  ON public.quizzes FOR INSERT
  TO authenticated
  WITH CHECK (owner_id = auth.uid());

DROP POLICY IF EXISTS "Owner can update own quizzes" ON public.quizzes;
CREATE POLICY "Owner can update own quizzes"
  ON public.quizzes FOR UPDATE
  TO authenticated
  USING (owner_id = auth.uid())
  WITH CHECK (owner_id = auth.uid());

DROP POLICY IF EXISTS "Owner can delete own quizzes" ON public.quizzes;
CREATE POLICY "Owner can delete own quizzes"
  ON public.quizzes FOR DELETE
  TO authenticated
  USING (owner_id = auth.uid());

-- ===========================================================
-- TABLE: questions
-- Policy: Read if quiz is visible; write if quiz owner.
-- ===========================================================
DROP POLICY IF EXISTS "Read questions of visible quizzes" ON public.questions;
CREATE POLICY "Read questions of visible quizzes"
  ON public.questions FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.quizzes q
      WHERE q.id = quiz_id
        AND (q.is_public = true OR q.owner_id = auth.uid())
    )
  );

DROP POLICY IF EXISTS "Quiz owner can insert questions" ON public.questions;
CREATE POLICY "Quiz owner can insert questions"
  ON public.questions FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.quizzes q
      WHERE q.id = quiz_id AND q.owner_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Quiz owner can update questions" ON public.questions;
CREATE POLICY "Quiz owner can update questions"
  ON public.questions FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.quizzes q
      WHERE q.id = quiz_id AND q.owner_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Quiz owner can delete questions" ON public.questions;
CREATE POLICY "Quiz owner can delete questions"
  ON public.questions FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.quizzes q
      WHERE q.id = quiz_id AND q.owner_id = auth.uid()
    )
  );

-- ===========================================================
-- TABLE: game_sessions
-- Policy: All authenticated users can read (needed for join-by-PIN).
--   Only host can write/update session state.
-- ===========================================================
DROP POLICY IF EXISTS "Authenticated users can view game sessions" ON public.game_sessions;
CREATE POLICY "Authenticated users can view game sessions"
  ON public.game_sessions FOR SELECT
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS "Users can create game sessions" ON public.game_sessions;
CREATE POLICY "Users can create game sessions"
  ON public.game_sessions FOR INSERT
  TO authenticated
  WITH CHECK (host_id = auth.uid());

DROP POLICY IF EXISTS "Host can update own session" ON public.game_sessions;
CREATE POLICY "Host can update own session"
  ON public.game_sessions FOR UPDATE
  TO authenticated
  USING (host_id = auth.uid());

DROP POLICY IF EXISTS "Host can delete own session" ON public.game_sessions;
CREATE POLICY "Host can delete own session"
  ON public.game_sessions FOR DELETE
  TO authenticated
  USING (host_id = auth.uid());

-- ===========================================================
-- TABLE: game_participants
-- Policy: Read all in any session (for lobby/leaderboard).
--   Users can insert themselves only (join session).
--   Scores are updated via increment_participant_score() SECURITY DEFINER.
-- ===========================================================
DROP POLICY IF EXISTS "View participants in sessions" ON public.game_participants;
CREATE POLICY "View participants in sessions"
  ON public.game_participants FOR SELECT
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS "Users can join sessions" ON public.game_participants;
CREATE POLICY "Users can join sessions"
  ON public.game_participants FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can leave sessions" ON public.game_participants;
CREATE POLICY "Users can leave sessions"
  ON public.game_participants FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- NOTE: No UPDATE policy here. Scores are mutated only via the
-- increment_participant_score() SECURITY DEFINER RPC, which bypasses RLS safely.

-- ===========================================================
-- TABLE: game_answers
-- Policy: Users can submit and view only their own answers.
--   Answers are immutable (no UPDATE/DELETE policies).
--   The UNIQUE constraint (migration 027) prevents double-submission.
-- ===========================================================
DROP POLICY IF EXISTS "Users can view own answers" ON public.game_answers;
CREATE POLICY "Users can view own answers"
  ON public.game_answers FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can submit own answers" ON public.game_answers;
CREATE POLICY "Users can submit own answers"
  ON public.game_answers FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- ===========================================================
-- TABLE: challenges
-- Policy: Only challenger and opponent can see and interact.
-- ===========================================================
DROP POLICY IF EXISTS "Users can view own challenges" ON public.challenges;
CREATE POLICY "Users can view own challenges"
  ON public.challenges FOR SELECT
  TO authenticated
  USING (challenger_id = auth.uid() OR opponent_id = auth.uid());

DROP POLICY IF EXISTS "Users can create challenges" ON public.challenges;
CREATE POLICY "Users can create challenges"
  ON public.challenges FOR INSERT
  TO authenticated
  WITH CHECK (challenger_id = auth.uid());

DROP POLICY IF EXISTS "Involved users can update challenges" ON public.challenges;
CREATE POLICY "Involved users can update challenges"
  ON public.challenges FOR UPDATE
  TO authenticated
  USING (challenger_id = auth.uid() OR opponent_id = auth.uid());

DROP POLICY IF EXISTS "Challenger can delete challenge" ON public.challenges;
CREATE POLICY "Challenger can delete challenge"
  ON public.challenges FOR DELETE
  TO authenticated
  USING (challenger_id = auth.uid());

-- ===========================================================
-- TABLE: leaderboard
-- Policy: Public read (global leaderboard). Self-write for entries.
-- ===========================================================
DROP POLICY IF EXISTS "Anyone can view leaderboard" ON public.leaderboard;
CREATE POLICY "Anyone can view leaderboard"
  ON public.leaderboard FOR SELECT
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS "Users can insert own leaderboard entry" ON public.leaderboard;
CREATE POLICY "Users can insert own leaderboard entry"
  ON public.leaderboard FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can update own leaderboard entry" ON public.leaderboard;
CREATE POLICY "Users can update own leaderboard entry"
  ON public.leaderboard FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid());

-- ===========================================================
-- TABLE: organizations
-- Policy: Public read (org directory). Owner-only write.
-- ===========================================================
DROP POLICY IF EXISTS "Anyone can view organizations" ON public.organizations;
CREATE POLICY "Anyone can view organizations"
  ON public.organizations FOR SELECT
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS "Users can create organizations" ON public.organizations;
CREATE POLICY "Users can create organizations"
  ON public.organizations FOR INSERT
  TO authenticated
  WITH CHECK (owner_id = auth.uid());

DROP POLICY IF EXISTS "Owner can update organization" ON public.organizations;
CREATE POLICY "Owner can update organization"
  ON public.organizations FOR UPDATE
  TO authenticated
  USING (owner_id = auth.uid())
  WITH CHECK (owner_id = auth.uid());

DROP POLICY IF EXISTS "Owner can delete organization" ON public.organizations;
CREATE POLICY "Owner can delete organization"
  ON public.organizations FOR DELETE
  TO authenticated
  USING (owner_id = auth.uid());

-- ===========================================================
-- TABLE: organization_members
-- Policy: Members can see others in the same org.
--   Owner can add/remove. Members can leave.
-- ===========================================================
DROP POLICY IF EXISTS "Members can view org membership" ON public.organization_members;
CREATE POLICY "Members can view org membership"
  ON public.organization_members FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.organization_members om
      WHERE om.organization_id = organization_members.organization_id
        AND om.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Org owner or self can add members" ON public.organization_members;
CREATE POLICY "Org owner or self can add members"
  ON public.organization_members FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id = auth.uid()  -- Self-join
    OR EXISTS (
      SELECT 1 FROM public.organizations o
      WHERE o.id = organization_id AND o.owner_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Owner or self can remove membership" ON public.organization_members;
CREATE POLICY "Owner or self can remove membership"
  ON public.organization_members FOR DELETE
  TO authenticated
  USING (
    user_id = auth.uid()  -- Leave org
    OR EXISTS (
      SELECT 1 FROM public.organizations o
      WHERE o.id = organization_id AND o.owner_id = auth.uid()
    )
  );

-- ===========================================================
-- TABLE: webhook_configs
-- Policy: Org owner full access only.
-- ===========================================================
DROP POLICY IF EXISTS "Org owner can manage webhooks" ON public.webhook_configs;
CREATE POLICY "Org owner can manage webhooks"
  ON public.webhook_configs FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.organizations o
      WHERE o.id = organization_id AND o.owner_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.organizations o
      WHERE o.id = organization_id AND o.owner_id = auth.uid()
    )
  );
