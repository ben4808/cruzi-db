CREATE OR REPLACE FUNCTION get_entries_for_spoken_familiarity_generator_top_50()
RETURNS TABLE (
    entry text,
    lang text,
    display_text text,
    familiarity_score int,
    unity_bucket text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e."entry",
        e.lang,
        e.display_text,
        e.familiarity_score,
        e.unity_bucket
    FROM "entry" e
    WHERE e.loading_status = 'P'
    ORDER BY e."entry", e.lang
    LIMIT 50;
END;
$$;
