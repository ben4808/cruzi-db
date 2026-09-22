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
        entry_type = NULL,
        unity_bucket = NULL,
        unity_score = NULL,
        familiarity_bucket = NULL,
        familiarity_score = NULL,
        quality_bucket = NULL,
        quality_score = NULL,
        is_vulgar = NULL,
        reviewed_status = NULL
    WHERE (e."entry", e.lang) IN (
        SELECT
            (elem->>'entry')::text,
            (elem->>'lang')::text
        FROM jsonb_array_elements(p_entries) AS elem
    );

    GET DIAGNOSTICS updated_count = ROW_COUNT;

    DELETE FROM inflected_entry ie
    WHERE (ie.inflected_entry, ie.lang) IN (
        SELECT
            (elem->>'entry')::text,
            (elem->>'lang')::text
        FROM jsonb_array_elements(p_entries) AS elem
    );

    RETURN updated_count;
END;
$$;
