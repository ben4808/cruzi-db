CREATE OR REPLACE FUNCTION add_short_phrase_queue_entries (
    p_items jsonb
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO short_phrase_queue (prompt, lang, "length")
    SELECT
        trim((i->>'prompt')::text),
        trim((i->>'lang')::text),
        (i->>'length')::int
    FROM jsonb_array_elements(p_items) AS i
    WHERE COALESCE(NULLIF(trim(i->>'prompt'), ''), '') <> ''
      AND COALESCE(NULLIF(trim(i->>'lang'), ''), '') <> ''
      AND (i->>'length') IS NOT NULL
    ON CONFLICT (prompt, lang) DO NOTHING;
END;
$$;
