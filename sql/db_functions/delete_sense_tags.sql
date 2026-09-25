CREATE OR REPLACE FUNCTION delete_sense_tags (
    p_tags jsonb
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_tags IS NULL OR jsonb_typeof(p_tags) <> 'array' OR jsonb_array_length(p_tags) = 0 THEN
        RETURN;
    END IF;

    DELETE FROM sense_tags st
    USING jsonb_array_elements(p_tags) AS t
    WHERE st.sense_id = trim((t->>'sense_id')::text)
      AND st.tag = trim((t->>'tag')::text)
      AND COALESCE(NULLIF(trim(t->>'sense_id'), ''), '') <> ''
      AND COALESCE(NULLIF(trim(t->>'tag'), ''), '') <> '';
END;
$$;
