CREATE OR REPLACE FUNCTION delete_example_sentences_for_senses(p_sense_ids jsonb)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    deleted_count integer;
BEGIN
    DELETE FROM example_sentence_translation est
    WHERE est.example_sentence_id IN (
        SELECT es.id
        FROM example_sentence es
        WHERE es.sense_id IN (
            SELECT jsonb_array_elements_text(p_sense_ids)
        )
    );

    DELETE FROM example_sentence es
    WHERE es.sense_id IN (
        SELECT jsonb_array_elements_text(p_sense_ids)
    );

    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$;
