CREATE OR REPLACE FUNCTION get_entries_for_entry_parser_top_50()
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
    WHERE e.loading_status = 'Ready'
      AND (e.display_text IS NULL OR TRIM(e.display_text) = '')
      and not exists (
        select 1 from entry_tags et 
        where et.entry = e.entry and et.tag = 'scrabble'
      )
    ORDER BY e."entry", e.lang
    LIMIT 50;
END;
$$;
