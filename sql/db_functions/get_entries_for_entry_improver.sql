CREATE OR REPLACE FUNCTION get_entries_for_entry_improver(p_limit integer)
RETURNS TABLE (
    entry text,
    lang text,
    in_puzzle boolean
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e."entry",
        e.lang,
        EXISTS (
            SELECT 1
            FROM clue c
            JOIN collection__clue colc ON colc.clue_id = c.id
            WHERE c."entry" = e."entry"
              AND c.lang = e.lang
              AND colc.metadata1 IS NOT NULL
        ) AS in_puzzle
    FROM "entry" e
    WHERE e.reviewed_status IS NULL
    ORDER BY random()
    LIMIT p_limit;
END;
$$;
