CREATE OR REPLACE FUNCTION insert_scrabble_entries (
    p_entries jsonb
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO "entry" ("entry", lang, "length", display_text)
    SELECT
      trim((e->>'entry')::text),
      COALESCE(NULLIF(trim((e->>'lang')::text), ''), 'en'),
      COALESCE((e->>'length')::integer, length(trim((e->>'entry')::text))),
      COALESCE(NULLIF(trim((e->>'display_text')::text), ''), trim((e->>'entry')::text))
    FROM jsonb_array_elements(p_entries) AS e
    WHERE COALESCE(NULLIF(trim(e->>'entry'), ''), '') <> ''
    ON CONFLICT ("entry", lang) DO NOTHING;

    INSERT INTO entry_tags ("entry", lang, tag)
    SELECT
      trim((e->>'entry')::text),
      COALESCE(NULLIF(trim((e->>'lang')::text), ''), 'en'),
      'scrabble'
    FROM jsonb_array_elements(p_entries) AS e
    WHERE COALESCE(NULLIF(trim(e->>'entry'), ''), '') <> ''
    ON CONFLICT ("entry", lang, tag) DO NOTHING;
END;
$$;
