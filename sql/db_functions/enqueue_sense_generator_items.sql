CREATE OR REPLACE FUNCTION enqueue_sense_generator_items(p_items jsonb)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_items IS NULL OR jsonb_typeof(p_items) <> 'array' OR jsonb_array_length(p_items) = 0 THEN
        RETURN;
    END IF;

    INSERT INTO sense_generator_queue (puzzle_id, "entry", lang, hint)
    SELECT DISTINCT
        NULLIF(btrim(elem->>'puzzle_id'), ''),
        btrim(elem->>'entry'),
        btrim(elem->>'lang'),
        NULLIF(btrim(elem->>'hint'), '')
    FROM jsonb_array_elements(p_items) AS elem
    WHERE COALESCE(btrim(elem->>'entry'), '') <> ''
      AND COALESCE(btrim(elem->>'lang'), '') <> ''
      AND NOT EXISTS (
          SELECT 1
          FROM sense_generator_queue q
          WHERE q.puzzle_id IS NOT DISTINCT FROM NULLIF(btrim(elem->>'puzzle_id'), '')
            AND q."entry" = btrim(elem->>'entry')
            AND q.lang = btrim(elem->>'lang')
            AND q.hint IS NOT DISTINCT FROM NULLIF(btrim(elem->>'hint'), '')
      );
END;
$$;
