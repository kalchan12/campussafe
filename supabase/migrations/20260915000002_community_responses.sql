-- =============================================================================
-- CampusSafe — Incident Community Responses & Eyewitness Reports
-- Migration: 20260915000002_community_responses
-- Allows nearby civilians/students to offer assistance (first aid, escorting)
-- for medical/accident emergencies, and submit eyewitness updates for security.
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.incident_community_responses (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    incident_id     UUID NOT NULL REFERENCES public.incidents(id) ON DELETE CASCADE,
    responder_id    UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    responder_name  TEXT,
    response_type   TEXT NOT NULL
        CHECK (response_type IN ('offering_assistance', 'escorting_to_safety', 'first_aid_provided', 'eyewitness_report', 'other_assistance')),
    message         TEXT NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_comm_resp_incident ON public.incident_community_responses(incident_id);
CREATE INDEX IF NOT EXISTS idx_comm_resp_created ON public.incident_community_responses(created_at DESC);

-- Enable RLS
ALTER TABLE public.incident_community_responses ENABLE ROW LEVEL SECURITY;

-- Everyone can read community responses for active incidents
CREATE POLICY "Community responses read"
    ON public.incident_community_responses FOR SELECT
    USING (true);

-- Authenticated users can insert community responses
CREATE POLICY "Community responses insert authenticated"
    ON public.incident_community_responses FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- Anonymous/guest users can submit eyewitness reports
CREATE POLICY "Community responses insert anon"
    ON public.incident_community_responses FOR INSERT
    WITH CHECK (
        auth.role() = 'anon'
        AND responder_id IS NULL
    );

-- Enable realtime for community responses
ALTER PUBLICATION supabase_realtime ADD TABLE public.incident_community_responses;
