CREATE OR REPLACE FUNCTION get_entries_for_entry_sentence_generator(
    p_limit integer
)
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
        COALESCE(NULLIF(trim(e.display_text), ''), e."entry") AS display_text
    FROM "entry" e
    WHERE e.length = 3
      AND e.familiarity_bucket = 'Ubiquitous'
      AND NOT EXISTS (
          SELECT 1
          FROM entry_sentence es
          WHERE es."entry" = e."entry"
      )
    ORDER BY random()
    LIMIT p_limit;
END;
$$;
