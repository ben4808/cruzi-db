CREATE OR REPLACE FUNCTION add_sense_tags (
    p_tags jsonb
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_tags IS NULL OR jsonb_typeof(p_tags) <> 'array' OR jsonb_array_length(p_tags) = 0 THEN
        RETURN;
    END IF;

    INSERT INTO sense_tags (sense_id, tag, "value")
    SELECT
        trim((t->>'sense_id')::text),
        trim((t->>'tag')::text),
        NULLIF(trim((t->>'value')::text), '')
    FROM jsonb_array_elements(p_tags) AS t
    WHERE COALESCE(NULLIF(trim(t->>'sense_id'), ''), '') <> ''
      AND COALESCE(NULLIF(trim(t->>'tag'), ''), '') <> ''
    ON CONFLICT (sense_id, tag) DO UPDATE SET
        "value" = EXCLUDED."value";
END;
$$;
