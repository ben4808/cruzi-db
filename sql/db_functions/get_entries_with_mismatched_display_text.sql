CREATE OR REPLACE FUNCTION get_entries_with_mismatched_display_text(p_limit integer)
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
    WHERE e.display_text IS NOT NULL
      AND TRIM(e.display_text) <> ''
      AND normalize_display_text_to_entry_key(e.display_text) <> e."entry"
    ORDER BY e."entry", e.lang
    LIMIT p_limit;
END;
$$;
