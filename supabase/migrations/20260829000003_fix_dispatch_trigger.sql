DROP TRIGGER IF EXISTS trigger_auto_dispatch ON public.incidents;
DROP FUNCTION IF EXISTS public.auto_dispatch_responder();

CREATE OR REPLACE FUNCTION public.auto_assign_responder_before()
RETURNS TRIGGER AS $$
DECLARE
    nearest_responder_id UUID;
    req_type TEXT;
BEGIN
    IF NEW.assigned_responder_id IS NOT NULL THEN
        RETURN NEW;
    END IF;

    IF NEW.type IN ('medical', 'accident') THEN
        req_type := 'medical';
    ELSE
        req_type := 'security';
    END IF;

    SELECT id INTO nearest_responder_id
    FROM public.responders
    WHERE type = req_type
      AND availability = 'available'
      AND current_incident_id IS NULL
      AND latitude IS NOT NULL
      AND longitude IS NOT NULL
    ORDER BY haversine_distance(NEW.latitude, NEW.longitude, latitude, longitude) ASC
    LIMIT 1;

    IF nearest_responder_id IS NOT NULL THEN
        NEW.assigned_responder_id := (SELECT user_id FROM public.responders WHERE id = nearest_responder_id);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_auto_assign_before
BEFORE INSERT ON public.incidents
FOR EACH ROW
EXECUTE FUNCTION public.auto_assign_responder_before();

CREATE OR REPLACE FUNCTION public.auto_assign_responder_after()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.assigned_responder_id IS NOT NULL THEN
        UPDATE public.responders
        SET availability = 'busy',
            current_incident_id = NEW.id
        WHERE user_id = NEW.assigned_responder_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_auto_assign_after
AFTER INSERT ON public.incidents
FOR EACH ROW
EXECUTE FUNCTION public.auto_assign_responder_after();
