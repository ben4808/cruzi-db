CREATE OR REPLACE FUNCTION delete_inflected_entries_for_base_entries(p_entries jsonb)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_entries IS NULL OR jsonb_typeof(p_entries) <> 'array' OR jsonb_array_length(p_entries) = 0 THEN
        RETURN;
    END IF;

    DELETE FROM inflected_entry ie
    USING jsonb_array_elements(p_entries) AS elem
    WHERE ie.base_entry = btrim(elem->>'entry')
      AND ie.lang = btrim(elem->>'lang');
END;
$$;
