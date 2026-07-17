CREATE OR REPLACE FUNCTION get_entries_for_familiarity_generator_top_50()
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
    WHERE e.loading_status = 'P'
    ORDER BY e."entry", e.lang
    LIMIT 50;
END;
$$;
