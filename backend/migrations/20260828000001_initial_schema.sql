-- =============================================================================
-- CampusSafe — Initial Database Schema
-- Migration: 20260828000001_initial_schema
-- =============================================================================

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================================
-- PROFILES
-- Linked 1:1 to auth.users via the shared UUID.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email       TEXT NOT NULL,
    full_name   TEXT NOT NULL,
    phone       TEXT,
    role        TEXT NOT NULL DEFAULT 'student'
                    CHECK (role IN ('student','medical_responder','security_responder','operator','administrator','staff')),
    campus_block    TEXT,
    emergency_info  TEXT,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- CAMPUS BLOCKS
-- Represents physical campus locations/buildings.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.campus_blocks (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        TEXT NOT NULL,
    description TEXT,
    latitude    DOUBLE PRECISION,
    longitude   DOUBLE PRECISION,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- INCIDENTS
-- Central emergency/safety incident entity.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.incidents (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reporter_id             UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    assigned_responder_id   UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    type        TEXT NOT NULL
                    CHECK (type IN ('medical','security','fire','accident','other')),
    status      TEXT NOT NULL DEFAULT 'created'
                    CHECK (status IN ('created','received','assigned','responding','arrived','resolved','cancelled','failed')),
    priority    INTEGER NOT NULL DEFAULT 2 CHECK (priority BETWEEN 1 AND 5),
    latitude    DOUBLE PRECISION,
    longitude   DOUBLE PRECISION,
    location_description TEXT,
    campus_block         TEXT,
    description          TEXT,
    source  TEXT NOT NULL DEFAULT 'mobile'
                CHECK (source IN ('mobile','guest_report','iot','dashboard')),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    assigned_at     TIMESTAMPTZ,
    responded_at    TIMESTAMPTZ,
    arrived_at      TIMESTAMPTZ,
    resolved_at     TIMESTAMPTZ
);

-- =============================================================================
-- INCIDENT STATUS HISTORY
-- Immutable audit trail of status transitions.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.incident_status_history (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    incident_id UUID NOT NULL REFERENCES public.incidents(id) ON DELETE CASCADE,
    old_status  TEXT,
    new_status  TEXT NOT NULL,
    changed_by  UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    note        TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- SAFETY REPORTS
-- Non-SOS anonymous/identified reports.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.safety_reports (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reporter_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    is_anonymous BOOLEAN NOT NULL DEFAULT FALSE,
    type        TEXT NOT NULL
                    CHECK (type IN ('suspicious_activity','security_concern','fire_hazard','safety_concern','other')),
    status      TEXT NOT NULL DEFAULT 'submitted'
                    CHECK (status IN ('submitted','under_review','resolved','dismissed')),
    description TEXT NOT NULL,
    latitude    DOUBLE PRECISION,
    longitude   DOUBLE PRECISION,
    location_description TEXT,
    image_url   TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- DEVICES (IoT)
-- Represents ESP32 and other physical devices.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.devices (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id       TEXT NOT NULL UNIQUE,   -- e.g. "SOS-ENG-01"
    device_type     TEXT NOT NULL
                        CHECK (device_type IN ('sos_station','environmental_node','security_node','warning_node','unknown')),
    campus_block    TEXT,
    campus_block_id UUID REFERENCES public.campus_blocks(id) ON DELETE SET NULL,
    firmware_version TEXT,
    is_online       BOOLEAN NOT NULL DEFAULT FALSE,
    last_seen_at    TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- DEVICE EVENTS
-- Events generated by IoT devices.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.device_events (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id   TEXT NOT NULL,              -- matches devices.device_id
    event_type  TEXT NOT NULL
                    CHECK (event_type IN ('SOS_TRIGGERED','RFID_ACCESS','MOTION_DETECTED',
                                          'TEMPERATURE_EVENT','HUMIDITY_EVENT','SMOKE_DETECTED',
                                          'DOOR_OPENED','ACCESS_GRANTED','ACCESS_DENIED','HEARTBEAT','OTHER')),
    payload     JSONB,
    latitude    DOUBLE PRECISION,
    longitude   DOUBLE PRECISION,
    location_id TEXT,
    incident_id UUID REFERENCES public.incidents(id) ON DELETE SET NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- NOTIFICATION TOKENS
-- Stores FCM device tokens for push notification delivery.
-- One user can have many devices/tokens.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.notification_tokens (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    token       TEXT NOT NULL,
    platform    TEXT NOT NULL DEFAULT 'android'
                    CHECK (platform IN ('android','ios','web')),
    active      BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_seen_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, token)
);

-- =============================================================================
-- NOTIFICATIONS
-- Record of notifications sent (for auditing/history).
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.notifications (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipient_id    UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    incident_id     UUID REFERENCES public.incidents(id) ON DELETE SET NULL,
    title           TEXT NOT NULL,
    body            TEXT,
    data            JSONB,
    delivered       BOOLEAN NOT NULL DEFAULT FALSE,
    delivery_error  TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- INDEXES
-- =============================================================================
CREATE INDEX IF NOT EXISTS idx_incidents_status        ON public.incidents(status);
CREATE INDEX IF NOT EXISTS idx_incidents_reporter      ON public.incidents(reporter_id);
CREATE INDEX IF NOT EXISTS idx_incidents_responder     ON public.incidents(assigned_responder_id);
CREATE INDEX IF NOT EXISTS idx_incidents_created       ON public.incidents(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_incident_history_id     ON public.incident_status_history(incident_id);
CREATE INDEX IF NOT EXISTS idx_safety_reports_reporter ON public.safety_reports(reporter_id);
CREATE INDEX IF NOT EXISTS idx_device_events_device    ON public.device_events(device_id);
CREATE INDEX IF NOT EXISTS idx_device_events_created   ON public.device_events(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notification_tokens_user ON public.notification_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_notification_tokens_active ON public.notification_tokens(user_id, active);
CREATE INDEX IF NOT EXISTS idx_notifications_recipient ON public.notifications(recipient_id);

-- =============================================================================
-- UPDATED_AT TRIGGER
-- =============================================================================
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trg_incidents_updated_at
    BEFORE UPDATE ON public.incidents
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trg_safety_reports_updated_at
    BEFORE UPDATE ON public.safety_reports
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trg_devices_updated_at
    BEFORE UPDATE ON public.devices
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER trg_notification_tokens_updated_at
    BEFORE UPDATE ON public.notification_tokens
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- =============================================================================
-- INCIDENT STATUS HISTORY TRIGGER
-- Automatically records every incident status change.
-- =============================================================================
CREATE OR REPLACE FUNCTION public.record_incident_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO public.incident_status_history(incident_id, old_status, new_status)
        VALUES (NEW.id, OLD.status, NEW.status);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_incident_status_history
    AFTER UPDATE ON public.incidents
    FOR EACH ROW EXECUTE FUNCTION public.record_incident_status_change();

-- =============================================================================
-- PROFILE AUTO-CREATE TRIGGER
-- Creates a profile row whenever a user signs up via Supabase Auth.
-- =============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        'student'
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_auth_new_user
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
