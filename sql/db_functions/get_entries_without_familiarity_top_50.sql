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
      AND NOT EXISTS (
          SELECT 1
          FROM entry_tags et
          WHERE et."entry" = e."entry" AND et.lang = e.lang AND et.tag = 'scrabble'
      )
    ORDER BY e."entry", e.lang
    LIMIT 50;
END;
$$;
