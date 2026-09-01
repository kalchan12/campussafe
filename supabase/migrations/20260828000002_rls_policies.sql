-- =============================================================================
-- CampusSafe — Row Level Security Policies
-- Migration: 20260828000002_rls_policies
-- Apply AFTER 20260828000001_initial_schema
-- =============================================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.incidents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.incident_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.safety_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.device_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campus_blocks ENABLE ROW LEVEL SECURITY;

-- =============================================================================
-- Helper: check role for the calling user
-- =============================================================================
CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS TEXT AS $$
    SELECT role FROM public.profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.is_responder()
RETURNS BOOLEAN AS $$
    SELECT current_user_role() IN ('medical_responder','security_responder');
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.is_operator()
RETURNS BOOLEAN AS $$
    SELECT current_user_role() IN ('operator','administrator');
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- =============================================================================
-- PROFILES
-- =============================================================================
-- Anyone authenticated can read their own profile
CREATE POLICY "Own profile read"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

-- Operators and admins can read all profiles
CREATE POLICY "Operator profile read"
    ON public.profiles FOR SELECT
    USING (public.is_operator());

-- Responders can read profiles (for incident context, limited fields enforced by app layer)
CREATE POLICY "Responder profile read"
    ON public.profiles FOR SELECT
    USING (public.is_responder());

-- Users can update their own profile
CREATE POLICY "Own profile update"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

-- Profile insert is done by the trigger / repository only
CREATE POLICY "Profile insert by owner"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- =============================================================================
-- CAMPUS BLOCKS
-- =============================================================================
-- All authenticated users can read campus blocks
CREATE POLICY "Campus blocks read"
    ON public.campus_blocks FOR SELECT
    USING (auth.role() = 'authenticated');

-- Only operators can modify campus blocks
CREATE POLICY "Operator campus block write"
    ON public.campus_blocks FOR ALL
    USING (public.is_operator());

-- =============================================================================
-- INCIDENTS
-- =============================================================================
-- Students can see their own incidents
CREATE POLICY "Student own incidents"
    ON public.incidents FOR SELECT
    USING (reporter_id = auth.uid());

-- Responders can see all active incidents (to be assigned)
CREATE POLICY "Responder incidents read"
    ON public.incidents FOR SELECT
    USING (public.is_responder());

-- Operators can see all incidents
CREATE POLICY "Operator incidents read"
    ON public.incidents FOR SELECT
    USING (public.is_operator());

-- Authenticated users can create incidents
CREATE POLICY "Incident create"
    ON public.incidents FOR INSERT
    WITH CHECK (
        auth.role() = 'authenticated'
        AND reporter_id = auth.uid()
    );

-- Responders can update incidents assigned to them
CREATE POLICY "Responder incident update"
    ON public.incidents FOR UPDATE
    USING (
        public.is_responder()
        AND (assigned_responder_id = auth.uid() OR assigned_responder_id IS NULL)
    );

-- Operators can update any incident
CREATE POLICY "Operator incident update"
    ON public.incidents FOR UPDATE
    USING (public.is_operator());

-- Allow anonymous incident creation (guest SOS) via source = 'guest_report'
-- Note: This requires the anon role to have insert permission with a NULL reporter_id
CREATE POLICY "Guest incident create"
    ON public.incidents FOR INSERT
    WITH CHECK (
        auth.role() = 'anon'
        AND reporter_id IS NULL
        AND source = 'guest_report'
    );

-- =============================================================================
-- INCIDENT STATUS HISTORY
-- =============================================================================
-- Same visibility as incidents
CREATE POLICY "Incident history read own"
    ON public.incident_status_history FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.incidents
            WHERE incidents.id = incident_status_history.incident_id
            AND incidents.reporter_id = auth.uid()
        )
    );

CREATE POLICY "Incident history read responder"
    ON public.incident_status_history FOR SELECT
    USING (public.is_responder() OR public.is_operator());

-- =============================================================================
-- SAFETY REPORTS
-- =============================================================================
-- Users can read their own non-anonymous reports
CREATE POLICY "Own safety reports read"
    ON public.safety_reports FOR SELECT
    USING (reporter_id = auth.uid() AND NOT is_anonymous);

-- Operators/responders see all reports
CREATE POLICY "Operator safety reports read"
    ON public.safety_reports FOR SELECT
    USING (public.is_operator() OR public.is_responder());

-- Authenticated users can create reports
CREATE POLICY "Safety report create authenticated"
    ON public.safety_reports FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- Anon users can create anonymous reports
CREATE POLICY "Safety report create anon"
    ON public.safety_reports FOR INSERT
    WITH CHECK (
        auth.role() = 'anon'
        AND is_anonymous = TRUE
        AND reporter_id IS NULL
    );

-- =============================================================================
-- DEVICES
-- =============================================================================
-- All authenticated users can read device info
CREATE POLICY "Devices read"
    ON public.devices FOR SELECT
    USING (auth.role() = 'authenticated');

-- Only operators can write devices
CREATE POLICY "Operator devices write"
    ON public.devices FOR ALL
    USING (public.is_operator());

-- IoT devices use service role to write — no policy needed for service role

-- =============================================================================
-- DEVICE EVENTS
-- =============================================================================
CREATE POLICY "Device events read"
    ON public.device_events FOR SELECT
    USING (public.is_responder() OR public.is_operator());

-- =============================================================================
-- NOTIFICATION TOKENS
-- =============================================================================
-- Users manage only their own tokens
CREATE POLICY "Own notification tokens"
    ON public.notification_tokens FOR ALL
    USING (user_id = auth.uid());

-- Operators can read all tokens (for administrative purposes)
CREATE POLICY "Operator notification tokens read"
    ON public.notification_tokens FOR SELECT
    USING (public.is_operator());

-- =============================================================================
-- NOTIFICATIONS
-- =============================================================================
-- Users see their own notifications
CREATE POLICY "Own notifications read"
    ON public.notifications FOR SELECT
    USING (recipient_id = auth.uid());

-- Operators see all
CREATE POLICY "Operator notifications read"
    ON public.notifications FOR SELECT
    USING (public.is_operator());

-- =============================================================================
-- ENABLE REALTIME
-- =============================================================================
ALTER PUBLICATION supabase_realtime ADD TABLE public.incidents;
ALTER PUBLICATION supabase_realtime ADD TABLE public.incident_status_history;
ALTER PUBLICATION supabase_realtime ADD TABLE public.safety_reports;
ALTER PUBLICATION supabase_realtime ADD TABLE public.devices;
ALTER PUBLICATION supabase_realtime ADD TABLE public.device_events;
