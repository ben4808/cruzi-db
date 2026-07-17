CREATE OR REPLACE FUNCTION delete_phrase_generator_results (
    p_results jsonb
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    deleted_count integer;
BEGIN
    DELETE FROM phrase_generator_result pgr
    USING (
        SELECT DISTINCT
            (i->>'phrase_generator_queue_id')::integer AS phrase_generator_queue_id,
            trim(i->>'phrase') AS phrase
        FROM jsonb_array_elements(p_results) AS i
        WHERE COALESCE(NULLIF(trim(i->>'phrase_generator_queue_id'), ''), '') <> ''
          AND COALESCE(NULLIF(trim(i->>'phrase'), ''), '') <> ''
    ) requested
    WHERE pgr.phrase_generator_queue_id = requested.phrase_generator_queue_id
      AND pgr.phrase = requested.phrase;

    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$;
