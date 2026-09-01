CREATE OR REPLACE FUNCTION public.auto_assign_responder_after()
RETURNS TRIGGER
SECURITY DEFINER
AS $$
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
