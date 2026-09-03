CREATE OR REPLACE FUNCTION get_entries_for_entry_parser(
    p_limit integer,
    p_pattern text DEFAULT NULL
)
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
    WHERE COALESCE(e.reviewed_status, '') NOT LIKE '1%'
      AND e.length = 5
      AND (p_pattern IS NULL OR p_pattern = '' OR e.entry LIKE p_pattern)
    ORDER BY random()
    LIMIT p_limit;
END;
$$;
