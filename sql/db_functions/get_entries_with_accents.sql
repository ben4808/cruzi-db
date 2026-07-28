CREATE OR REPLACE FUNCTION get_entries_with_accents(p_limit integer)
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
    WHERE e.lang = 'en'
      AND e."entry" <> strip_entry_accents(e."entry")
    ORDER BY e."entry", e.lang
    LIMIT p_limit;
END;
$$;
