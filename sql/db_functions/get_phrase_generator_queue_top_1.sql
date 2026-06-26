CREATE OR REPLACE FUNCTION get_phrase_generator_queue_top_1()
RETURNS TABLE (
    id integer,
    prompt text,
    lang text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        pgq.id,
        pgq.prompt,
        pgq.lang
    FROM phrase_generator_queue pgq
    WHERE NOT EXISTS (
        SELECT 1
        FROM phrase_generator_result pgr
        WHERE pgr.phrase_generator_queue_id = pgq.id
    )
    ORDER BY pgq.added_at ASC
    LIMIT 1;
END;
$$;
