CREATE OR REPLACE FUNCTION enqueue_sense_reference_items(p_items jsonb)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_items IS NULL OR jsonb_typeof(p_items) <> 'array' OR jsonb_array_length(p_items) = 0 THEN
        RETURN;
    END IF;

    INSERT INTO sense_reference_queue (puzzle_id, sense_id)
    SELECT DISTINCT
        NULLIF(btrim(elem->>'puzzle_id'), ''),
        btrim(elem->>'sense_id')
    FROM jsonb_array_elements(p_items) AS elem
    WHERE COALESCE(btrim(elem->>'sense_id'), '') <> ''
      AND NOT EXISTS (
          SELECT 1
          FROM sense_reference sr
          WHERE sr.sense_id = btrim(elem->>'sense_id')
      )
      AND NOT EXISTS (
          SELECT 1
          FROM sense_reference_queue q
          WHERE q.sense_id = btrim(elem->>'sense_id')
            AND q.puzzle_id IS NOT DISTINCT FROM NULLIF(btrim(elem->>'puzzle_id'), '')
      );
END;
$$;
