-- =============================================================================
-- PROXIMITY DISPATCH ENGINE
-- Adds responder tracking and auto-dispatch trigger.
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.responders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('medical','security')),
    availability TEXT NOT NULL DEFAULT 'offline' CHECK (availability IN ('available','busy','offline')),
    current_incident_id UUID REFERENCES public.incidents(id) ON DELETE SET NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    last_location_update TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS Policies
ALTER TABLE public.responders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Responders are viewable by everyone" ON public.responders
  FOR SELECT USING (true);

CREATE POLICY "Responders can update their own status" ON public.responders
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Responders can insert their own profile" ON public.responders
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Operators can update any responder" ON public.responders
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE profiles.id = auth.uid() AND profiles.role IN ('operator', 'administrator'))
  );

-- Enable realtime
alter publication supabase_realtime add table public.responders;

-- Haversine distance function (pure SQL/PLpgSQL for no-dependency proximity)
CREATE OR REPLACE FUNCTION public.haversine_distance(lat1 FLOAT, lon1 FLOAT, lat2 FLOAT, lon2 FLOAT)
RETURNS FLOAT AS $$
DECLARE
    radius FLOAT := 6371; -- Earth's radius in kilometers
    dlat FLOAT;
    dlon FLOAT;
    a FLOAT;
    c FLOAT;
BEGIN
    IF lat1 IS NULL OR lon1 IS NULL OR lat2 IS NULL OR lon2 IS NULL THEN
        RETURN NULL;
    END IF;

    dlat := radians(lat2 - lat1);
    dlon := radians(lon2 - lon1);
    
    a := sin(dlat/2) * sin(dlat/2) +
         cos(radians(lat1)) * cos(radians(lat2)) *
         sin(dlon/2) * sin(dlon/2);
         
    c := 2 * atan2(sqrt(a), sqrt(1-a));
    
    RETURN radius * c * 1000; -- Return in meters
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Trigger function to auto-assign nearest responder
CREATE OR REPLACE FUNCTION public.auto_dispatch_responder()
RETURNS TRIGGER AS $$
DECLARE
    nearest_responder_id UUID;
    req_type TEXT;
BEGIN
    -- Only auto-dispatch if not already assigned
    IF NEW.assigned_responder_id IS NOT NULL THEN
        RETURN NEW;
    END IF;

    -- Determine required responder type
    IF NEW.type IN ('medical', 'accident') THEN
        req_type := 'medical';
    ELSE
        req_type := 'security';
    END IF;

    -- Find nearest available responder of correct type
    SELECT id INTO nearest_responder_id
    FROM public.responders
    WHERE type = req_type
      AND availability = 'available'
      AND current_incident_id IS NULL
      AND latitude IS NOT NULL
      AND longitude IS NOT NULL
    ORDER BY haversine_distance(NEW.latitude, NEW.longitude, latitude, longitude) ASC
    LIMIT 1;

    -- If found, assign and mark busy
    IF nearest_responder_id IS NOT NULL THEN
        NEW.assigned_responder_id := (SELECT user_id FROM public.responders WHERE id = nearest_responder_id);
        
        -- Update responder status
        UPDATE public.responders
        SET availability = 'busy',
            current_incident_id = NEW.id
        WHERE id = nearest_responder_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_auto_dispatch
BEFORE INSERT ON public.incidents
FOR EACH ROW
EXECUTE FUNCTION public.auto_dispatch_responder();
