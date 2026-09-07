CREATE OR REPLACE FUNCTION add_entry_tags (
    p_tags jsonb
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    -- Inserts new tags. When "value" is provided, conflict increments the existing
    -- numeric value by 1 (used for NYT era appearance counts). When "value" is null,
    -- conflict is a no-op (existing tag-only callers).
    INSERT INTO entry_tags ("entry", lang, tag, "value")
    SELECT
        trim((t->>'entry')::text),
        trim((t->>'lang')::text),
        trim((t->>'tag')::text),
        NULLIF(trim((t->>'value')::text), '')
    FROM jsonb_array_elements(p_tags) AS t
    WHERE COALESCE(NULLIF(trim(t->>'entry'), ''), '') <> ''
      AND COALESCE(NULLIF(trim(t->>'lang'), ''), '') <> ''
      AND COALESCE(NULLIF(trim(t->>'tag'), ''), '') <> ''
    ON CONFLICT ("entry", lang, tag) DO UPDATE SET
        "value" = CASE
            WHEN EXCLUDED."value" ~ '^-?[0-9]+$'
                 AND COALESCE(NULLIF(entry_tags."value", ''), '0') ~ '^-?[0-9]+$'
            THEN (COALESCE(NULLIF(entry_tags."value", '')::integer, 0) + 1)::text
            ELSE EXCLUDED."value"
        END
    WHERE EXCLUDED."value" IS NOT NULL;
END;
$$;
