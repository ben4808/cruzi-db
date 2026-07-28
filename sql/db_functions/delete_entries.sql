CREATE OR REPLACE FUNCTION delete_entries(p_entries jsonb)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    deleted_count integer;
BEGIN
    IF p_entries IS NULL OR jsonb_typeof(p_entries) <> 'array' OR jsonb_array_length(p_entries) = 0 THEN
        RETURN 0;
    END IF;

    WITH requested AS (
        SELECT DISTINCT
            trim(i->>'entry') AS entry,
            trim(i->>'lang') AS lang
        FROM jsonb_array_elements(p_entries) AS i
        WHERE COALESCE(NULLIF(trim(i->>'entry'), ''), '') <> ''
          AND COALESCE(NULLIF(trim(i->>'lang'), ''), '') <> ''
    )
    DELETE FROM "entry" e
    USING requested r
    WHERE e."entry" = r.entry
      AND e.lang = r.lang;

    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$;
