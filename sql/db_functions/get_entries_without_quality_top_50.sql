CREATE OR REPLACE FUNCTION get_entries_without_quality_top_50()
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
    WHERE e.quality_score IS NULL
      AND e.display_text IS NOT NULL
      AND TRIM(e.display_text) <> ''
      AND NOT EXISTS (
          SELECT 1
          FROM entry_tags et
          WHERE et."entry" = e."entry" AND et.lang = e.lang
      )
    ORDER BY e."entry", e.lang
    LIMIT 50;
END;
$$;
