DO $$ 
DECLARE
    uid1 uuid := '11111111-1111-1111-1111-111111111111';
    uid2 uuid := '22222222-2222-2222-2222-222222222222';
    uid3 uuid := '33333333-3333-3333-3333-333333333333';
BEGIN
    -- Insert into auth.users (minimal fields needed to satisfy FK constraints)
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
    ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name;

    -- Insert into public.responders
    INSERT INTO public.responders (user_id, type, availability, latitude, longitude, last_location_update)
    VALUES
    (uid1, 'medical', 'available', 8.5520, 39.2900, now()),
    (uid2, 'security', 'available', 8.5600, 39.2950, now()),
    (uid3, 'security', 'available', 8.5550, 39.2850, now())
    ON CONFLICT (id) DO NOTHING;
END $$;
