-- Create 3 mock responders in auth.users? We can't easily do that without calling auth API. 
-- But wait, profiles are linked to auth.users. 
-- Let's just create 3 fake users in auth.users and public.profiles.
DO $$ 
DECLARE
    uid1 uuid := gen_random_uuid();
    uid2 uuid := gen_random_uuid();
    uid3 uuid := gen_random_uuid();
BEGIN
    -- Insert into auth.users (minimal fields needed)
    INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, role, aud, confirmation_token)
    VALUES 
    (uid1, '00000000-0000-0000-0000-000000000000', 'med1@campus.edu', 'secret', now(), '{"provider":"email","providers":["email"]}', '{"full_name": "Medic One"}', now(), now(), 'authenticated', 'authenticated', ''),
    (uid2, '00000000-0000-0000-0000-000000000000', 'sec1@campus.edu', 'secret', now(), '{"provider":"email","providers":["email"]}', '{"full_name": "Security One"}', now(), now(), 'authenticated', 'authenticated', ''),
    (uid3, '00000000-0000-0000-0000-000000000000', 'sec2@campus.edu', 'secret', now(), '{"provider":"email","providers":["email"]}', '{"full_name": "Security Two"}', now(), now(), 'authenticated', 'authenticated', '')
    ON CONFLICT (id) DO NOTHING;

    -- Insert into public.profiles
    INSERT INTO public.profiles (id, full_name, email, role, phone, campus_block)
    VALUES
    (uid1, 'Medical Responder Alex', 'med1@campus.edu', 'medical_responder', '555-1011', 'Medical Center'),
    (uid2, 'Security Officer Bob', 'sec1@campus.edu', 'security_responder', '555-1012', 'North Gate'),
    (uid3, 'Security Officer Charlie', 'sec2@campus.edu', 'security_responder', '555-1013', 'South Gate')
    ON CONFLICT (id) DO NOTHING;

    -- Insert into public.responders
    INSERT INTO public.responders (id, status, last_latitude, last_longitude, last_heartbeat)
    VALUES
    (uid1, 'available', 8.5520, 39.2900, now()),
    (uid2, 'available', 8.5600, 39.2950, now()),
    (uid3, 'available', 8.5550, 39.2850, now())
    ON CONFLICT (id) DO UPDATE SET 
        status = 'available',
        last_latitude = EXCLUDED.last_latitude,
        last_longitude = EXCLUDED.last_longitude,
        last_heartbeat = now();
END $$;
