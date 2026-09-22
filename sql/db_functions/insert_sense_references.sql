CREATE OR REPLACE FUNCTION insert_sense_references(p_references jsonb)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_references IS NULL OR jsonb_typeof(p_references) <> 'array' OR jsonb_array_length(p_references) = 0 THEN
        RETURN;
    END IF;

    INSERT INTO sense_reference (
        id,
        sense_id,
        reference_type,
        reference_text,
        reference_source,
        reference_url
    )
    SELECT
        btrim(elem->>'id'),
        btrim(elem->>'sense_id'),
        btrim(elem->>'reference_type'),
        btrim(elem->>'reference_text'),
        NULLIF(btrim(elem->>'reference_source'), ''),
        NULLIF(btrim(elem->>'reference_url'), '')
    FROM jsonb_array_elements(p_references) AS elem
    WHERE COALESCE(btrim(elem->>'id'), '') <> ''
      AND COALESCE(btrim(elem->>'sense_id'), '') <> ''
      AND COALESCE(btrim(elem->>'reference_type'), '') <> ''
      AND COALESCE(btrim(elem->>'reference_text'), '') <> ''
    ON CONFLICT (id) DO UPDATE SET
        sense_id = EXCLUDED.sense_id,
        reference_type = EXCLUDED.reference_type,
        reference_text = EXCLUDED.reference_text,
        reference_source = EXCLUDED.reference_source,
        reference_url = EXCLUDED.reference_url;
END;
$$;
