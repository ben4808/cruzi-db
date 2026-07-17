CREATE OR REPLACE FUNCTION get_phrase_generator_results_random_50()
RETURNS TABLE (
    phrase_generator_queue_id integer,
    phrase text,
    lang text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        pgr.phrase_generator_queue_id,
        pgr.phrase,
        pgq.lang
    FROM phrase_generator_result pgr
    INNER JOIN phrase_generator_queue pgq
        ON pgq.id = pgr.phrase_generator_queue_id
    WHERE pgr.phrase NOT LIKE '\_\_PHRASE\_GENERATOR\_%' ESCAPE '\'
    ORDER BY random()
    LIMIT 50;
END;
$$;
