CREATE OR REPLACE FUNCTION get_entries_for_quality_generator_top_50(
    p_limit integer,
    p_pattern text DEFAULT NULL
)
RETURNS TABLE (
    entry text,
    lang text,
    display_text text,
    unity_bucket text,
    familiarity_bucket text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e."entry",
        e.lang,
        e.display_text,
        e.unity_bucket,
        e.familiarity_bucket
    FROM "entry" e
    WHERE e.reviewed_status = '123'
      AND (e.length = 4 OR e.length = 3 OR e.length = 5)
      AND e.display_text IS NOT NULL
      AND TRIM(e.display_text) <> ''
      AND e.unity_bucket IS NOT NULL
      AND TRIM(e.unity_bucket) <> ''
      AND e.familiarity_bucket IS NOT NULL
      AND TRIM(e.familiarity_bucket) <> ''
      AND e.entry_type IS DISTINCT FROM 'Nonsense'
      AND e.unity_bucket IS DISTINCT FROM 'Nonsense'
      AND (p_pattern IS NULL OR p_pattern = '' OR e.entry LIKE p_pattern)
    ORDER BY random()
    LIMIT p_limit;
END;
$$;
