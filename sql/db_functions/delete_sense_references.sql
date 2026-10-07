CREATE OR REPLACE FUNCTION delete_sense_references(p_sense_ids jsonb)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_sense_ids IS NULL OR jsonb_typeof(p_sense_ids) <> 'array' OR jsonb_array_length(p_sense_ids) = 0 THEN
        RETURN;
    END IF;

    DELETE FROM sense_reference sr
    WHERE sr.sense_id IN (
        SELECT jsonb_array_elements_text(p_sense_ids)
    );
END;
$$;
