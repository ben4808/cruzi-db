CREATE OR REPLACE FUNCTION reset_entry_display_fields(p_entries jsonb)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    updated_count integer;
BEGIN
    UPDATE "entry" e
    SET
        display_text = NULL,
        idiomacity_score = NULL,
        familiarity_score = NULL,
        quality_score = NULL,
        entry_type = NULL,
        root_entry = NULL
    WHERE (e."entry", e.lang) IN (
        SELECT
            (elem->>'entry')::text,
            (elem->>'lang')::text
        FROM jsonb_array_elements(p_entries) AS elem
    );

    GET DIAGNOSTICS updated_count = ROW_COUNT;
    RETURN updated_count;
END;
$$;
