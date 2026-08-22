CREATE OR REPLACE FUNCTION get_entries_for_entry_parser_top_50(p_limit integer)
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
    WHERE COALESCE(e.reviewed_status, '') NOT IN ('R', 'Failed parse')
      AND COALESCE(e.reviewed_status, '') NOT LIKE '1%'
      AND EXISTS (
          SELECT 1
          FROM entry_tags et
          WHERE et."entry" = e."entry" AND et.lang = e.lang AND et.tag = 'nyt'
      )
    ORDER BY random()
    LIMIT p_limit;
END;
$$;
