CREATE OR REPLACE FUNCTION delete_sense_reference_queue_items(p_ids jsonb)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_ids IS NULL OR jsonb_typeof(p_ids) <> 'array' OR jsonb_array_length(p_ids) = 0 THEN
        RETURN;
    END IF;

    DELETE FROM sense_reference_queue q
    WHERE q.id IN (
        SELECT ex.id::integer
        FROM jsonb_array_elements_text(p_ids) AS ex(id)
        WHERE ex.id ~ '^[0-9]+$'
    );
END;
$$;
