-- =============================================================================
-- CampusSafe — Development Seed Data
-- Migration: 20260828000003_seed_data
-- DO NOT apply to production without removing personal data.
-- =============================================================================

-- Campus blocks
INSERT INTO public.campus_blocks (id, name, description, latitude, longitude) VALUES
  ('a1000000-0000-0000-0000-000000000001', 'Engineering Block', 'Main engineering faculty building complex', NULL, NULL),
  ('a1000000-0000-0000-0000-000000000002', 'Main Library', 'Central university library', NULL, NULL),
  ('a1000000-0000-0000-0000-000000000003', 'Chemistry Lab Block', 'Science faculty labs', NULL, NULL),
  ('a1000000-0000-0000-0000-000000000004', 'Student Union Hub', 'Student union and cafeteria', NULL, NULL),
  ('a1000000-0000-0000-0000-000000000005', 'Medical Centre', 'Campus health and medical centre', NULL, NULL),
  ('a1000000-0000-0000-0000-000000000006', 'Administration Block', 'University administrative offices', NULL, NULL),
  ('a1000000-0000-0000-0000-000000000007', 'Sports Complex', 'Indoor and outdoor sports facilities', NULL, NULL),
  ('a1000000-0000-0000-0000-000000000008', 'North Residences', 'Student residential halls (north)', NULL, NULL)
ON CONFLICT (id) DO NOTHING;

-- Seed IoT devices (placeholder — firmware not yet implemented)
INSERT INTO public.devices (device_id, device_type, campus_block, campus_block_id) VALUES
  ('SOS-ENG-01',  'sos_station',       'Engineering Block', 'a1000000-0000-0000-0000-000000000001'),
  ('SOS-LIB-01',  'sos_station',       'Main Library',      'a1000000-0000-0000-0000-000000000002'),
  ('ENV-CHEM-01', 'environmental_node','Chemistry Lab Block','a1000000-0000-0000-0000-000000000003'),
  ('SEC-NORTH-01','security_node',     'North Residences',  'a1000000-0000-0000-0000-000000000008')
ON CONFLICT (device_id) DO NOTHING;
