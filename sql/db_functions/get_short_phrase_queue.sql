CREATE OR REPLACE FUNCTION get_short_phrase_queue(p_limit integer)
RETURNS TABLE (
    prompt text,
    lang text,
    "length" integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        spq.prompt,
        spq.lang,
        spq."length"
    FROM short_phrase_queue spq
    ORDER BY spq.added_at ASC
    LIMIT p_limit;
END;
$$;
