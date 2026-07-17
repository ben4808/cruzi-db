CREATE OR REPLACE FUNCTION get_entries_without_unity_bucket_top_50()
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
    WHERE e.unity_bucket IS NULL
      AND e.display_text IS NOT NULL
      AND TRIM(e.display_text) <> ''
    ORDER BY e."entry", e.lang
    LIMIT 50;
END;
$$;
