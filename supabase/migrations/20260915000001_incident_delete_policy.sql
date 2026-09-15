-- =============================================================================
-- CampusSafe — Incident Delete Policy
-- Migration: 20260915000001_incident_delete_policy
-- Allows the reporter (user who created the incident) to delete their own
-- incident. This supports false-alarm / accidental SOS removal.
-- =============================================================================

-- Allow the reporter to delete their own incident
CREATE POLICY "Reporter incident delete"
    ON public.incidents FOR DELETE
    USING (reporter_id = auth.uid());
