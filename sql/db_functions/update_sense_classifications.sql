CREATE OR REPLACE FUNCTION update_sense_classifications(
    p_updates jsonb
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_updates IS NULL OR jsonb_typeof(p_updates) <> 'array' OR jsonb_array_length(p_updates) = 0 THEN
        RETURN;
    END IF;

    UPDATE sense s
    SET
        display_text = NULLIF(btrim(elem->>'display_text'), ''),
        classification = NULLIF(btrim(elem->>'classification'), ''),
        unity_bucket = NULLIF(btrim(elem->>'unity_bucket'), ''),
        familiarity_bucket = NULLIF(btrim(elem->>'familiarity_bucket'), ''),
        quality_bucket = NULLIF(btrim(elem->>'quality_bucket'), ''),
        domain = NULLIF(btrim(elem->>'domain'), '')
    FROM jsonb_array_elements(p_updates) AS elem
    WHERE s.id = btrim(elem->>'sense_id')
      AND COALESCE(btrim(elem->>'sense_id'), '') <> '';
END;
$$;
