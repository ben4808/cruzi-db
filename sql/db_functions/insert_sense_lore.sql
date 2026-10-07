CREATE OR REPLACE FUNCTION insert_sense_lore(p_items jsonb)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_items IS NULL OR jsonb_typeof(p_items) <> 'array' OR jsonb_array_length(p_items) = 0 THEN
        RETURN;
    END IF;

    INSERT INTO sense_lore (
        sense_id,
        lore_text
    )
    SELECT
        btrim(elem->>'sense_id'),
        btrim(elem->>'lore_text')
    FROM jsonb_array_elements(p_items) AS elem
    WHERE COALESCE(btrim(elem->>'sense_id'), '') <> ''
      AND COALESCE(btrim(elem->>'lore_text'), '') <> '';
END;
$$;
