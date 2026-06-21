CREATE OR REPLACE FUNCTION get_entries_low_idiomacity_top_150()
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
    WHERE e.idiomacity_score IS NOT NULL
      AND e.idiomacity_score < 3
    ORDER BY e."entry", e.lang
    LIMIT 150;
END;
$$;
