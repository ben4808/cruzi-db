CREATE OR REPLACE FUNCTION get_phrase_generator_queue(p_limit integer)
RETURNS TABLE (
    prompt text,
    lang text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        pgq.prompt,
        pgq.lang
    FROM phrase_generator_queue pgq
    ORDER BY pgq.added_at ASC
    LIMIT p_limit;
END;
$$;
