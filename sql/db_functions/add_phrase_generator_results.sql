CREATE OR REPLACE FUNCTION add_phrase_generator_results (
    p_queue_id integer,
    p_phrases jsonb
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO phrase_generator_result (phrase_generator_queue_id, phrase)
    SELECT
        p_queue_id,
        trim(phrase_value)
    FROM jsonb_array_elements_text(p_phrases) AS phrase_value
    WHERE COALESCE(NULLIF(trim(phrase_value), ''), '') <> ''
    ON CONFLICT (phrase_generator_queue_id, phrase) DO NOTHING;
END;
$$;
