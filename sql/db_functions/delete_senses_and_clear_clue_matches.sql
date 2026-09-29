CREATE OR REPLACE FUNCTION delete_senses_and_clear_clue_matches(p_sense_ids jsonb)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_sense_ids IS NULL OR jsonb_typeof(p_sense_ids) <> 'array' OR jsonb_array_length(p_sense_ids) = 0 THEN
        RETURN;
    END IF;

    UPDATE clue c
    SET sense_id = NULL
    WHERE c.sense_id IN (
        SELECT jsonb_array_elements_text(p_sense_ids)
    );

    DELETE FROM sense s
    WHERE s.id IN (
        SELECT jsonb_array_elements_text(p_sense_ids)
    );
END;
$$;
