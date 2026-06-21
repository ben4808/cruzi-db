CREATE OR REPLACE FUNCTION get_entries_without_idiomacity_top_50()
RETURNS TABLE (
    entry text,
    lang text,
    display_text text,
    entry_type text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e."entry",
        e.lang,
        e.display_text,
        e.entry_type
    FROM "entry" e
    WHERE e.idiomacity_score IS NULL
    ORDER BY e."entry", e.lang
    LIMIT 50;
END;
$$;
