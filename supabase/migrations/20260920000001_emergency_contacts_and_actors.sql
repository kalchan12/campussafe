-- Migration: 20260920000001_emergency_contacts_and_actors.sql
-- Description: Adds emergency contact columns (parent phone/name and campus admin phone)
-- to public.profiles and updates new-user triggers.

-- 1. Add structured emergency contact columns to profiles table
ALTER TABLE public.profiles
    ADD COLUMN IF NOT EXISTS parent_phone TEXT,
    ADD COLUMN IF NOT EXISTS parent_name TEXT,
    ADD COLUMN IF NOT EXISTS campus_admin_phone TEXT NOT NULL DEFAULT '0920304050';

-- 2. Add comment documenting the two primary campus actors
COMMENT ON COLUMN public.profiles.role IS 'User actor in the campus safety system: primary actors are student and staff; internal operators/responders are medical_responder, security_responder, operator, administrator.';
COMMENT ON COLUMN public.profiles.parent_phone IS 'Emergency contact phone number for the user parent or guardian.';
COMMENT ON COLUMN public.profiles.parent_name IS 'Emergency contact name for the user parent or guardian.';
COMMENT ON COLUMN public.profiles.campus_admin_phone IS 'Emergency contact phone number for the university emergency administration/dispatch (default: 0920304050).';

-- 3. Update auth signup trigger to capture emergency contacts from user metadata if provided
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (
        id,
        email,
        full_name,
        phone,
        role,
        parent_phone,
        parent_name,
        campus_admin_phone,
        emergency_info
    )
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        NEW.raw_user_meta_data->>'phone',
        COALESCE(NEW.raw_user_meta_data->>'role', 'student'),
        NEW.raw_user_meta_data->>'parent_phone',
        NEW.raw_user_meta_data->>'parent_name',
        COALESCE(NEW.raw_user_meta_data->>'campus_admin_phone', '0920304050'),
        NEW.raw_user_meta_data->>'emergency_info'
    )
    ON CONFLICT (id) DO UPDATE SET
        full_name = EXCLUDED.full_name,
        phone = COALESCE(EXCLUDED.phone, public.profiles.phone),
        role = COALESCE(EXCLUDED.role, public.profiles.role),
        parent_phone = COALESCE(EXCLUDED.parent_phone, public.profiles.parent_phone),
        parent_name = COALESCE(EXCLUDED.parent_name, public.profiles.parent_name),
        campus_admin_phone = COALESCE(EXCLUDED.campus_admin_phone, public.profiles.campus_admin_phone),
        updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
