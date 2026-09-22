-- 1. Fix responder availability check constraint
ALTER TABLE public.responders DROP CONSTRAINT IF EXISTS responders_availability_check;
ALTER TABLE public.responders ADD CONSTRAINT responders_availability_check 
  CHECK (availability IN ('available', 'busy', 'offline', 'responding', 'arrived'));

-- 2. Add missing RLS DELETE policy on incidents
CREATE POLICY "Operator incident delete"
    ON public.incidents FOR DELETE
    USING (public.is_operator());
