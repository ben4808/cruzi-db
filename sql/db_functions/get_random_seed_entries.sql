DROP FUNCTION IF EXISTS get_random_seed_entries(integer, text, integer, text);

CREATE OR REPLACE FUNCTION get_random_seed_entries(
    p_length integer,
    p_familiarity_bucket text DEFAULT 'General Knowledge',
    p_count integer DEFAULT 10,
    p_lang text DEFAULT 'en'
)
RETURNS TABLE (
    entry text,
    lang text,
    display_text text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e."entry",
        e.lang,
        e.display_text
    FROM "entry" e
    WHERE e.lang = p_lang
      AND e."length" = p_length
      AND e.familiarity_bucket = p_familiarity_bucket
      AND e."entry" ~ '^[A-Z]+$'
      AND e.display_text IS NOT NULL AND btrim(e.display_text) <> ''
      AND e.classification IS DISTINCT FROM 'Nonsense'
      AND e.unity_bucket IS DISTINCT FROM 'Non-unit'
      AND e.unity_bucket IS DISTINCT FROM 'Nonsense'
      AND NOT EXISTS (
          SELECT 1
          FROM entry_tags et
          WHERE et."entry" = e."entry"
            AND et.lang = e.lang
            AND et.tag IN ('breakfast_test', 'vulgar')
      )
    ORDER BY random()
    LIMIT p_count;
END;
$$;
