DROP POLICY IF EXISTS "Guest incident create" ON public.incidents;

CREATE POLICY "Guest incident create"
    ON public.incidents FOR INSERT
    WITH CHECK (
        auth.role() = 'anon'
        AND reporter_id IS NULL
    );
