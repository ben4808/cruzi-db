CREATE OR REPLACE FUNCTION get_entries_without_familiarity_top_50()
RETURNS TABLE (
    entry text,
    lang text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e."entry",
        e.lang
    FROM "entry" e
    WHERE e.familiarity_score IS NULL
    ORDER BY e."entry", e.lang
    LIMIT 50;
END;
$$;
