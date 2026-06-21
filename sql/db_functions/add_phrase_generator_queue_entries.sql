CREATE OR REPLACE FUNCTION add_phrase_generator_queue_entries (
    p_items jsonb
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO phrase_generator_queue (prompt, lang)
    SELECT
        trim((i->>'prompt')::text),
        trim((i->>'lang')::text)
    FROM jsonb_array_elements(p_items) AS i
    WHERE COALESCE(NULLIF(trim(i->>'prompt'), ''), '') <> ''
      AND COALESCE(NULLIF(trim(i->>'lang'), ''), '') <> '';
END;
$$;
