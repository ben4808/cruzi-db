CREATE OR REPLACE FUNCTION update_sense_scoring_results(p_updates jsonb)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_updates IS NULL OR jsonb_typeof(p_updates) <> 'array' OR jsonb_array_length(p_updates) = 0 THEN
        RETURN;
    END IF;

    UPDATE sense s
    SET
        unity_bucket = COALESCE(NULLIF(btrim(elem->>'unity_bucket'), ''), s.unity_bucket),
        familiarity_bucket = COALESCE(NULLIF(btrim(elem->>'familiarity_bucket'), ''), s.familiarity_bucket),
        quality_bucket = COALESCE(NULLIF(btrim(elem->>'quality_bucket'), ''), s.quality_bucket),
        domain = CASE
            WHEN elem ? 'domain' THEN NULLIF(btrim(elem->>'domain'), '')
            ELSE s.domain
        END,
        reviewed_status = COALESCE(NULLIF(btrim(elem->>'reviewed_status'), ''), s.reviewed_status)
    FROM jsonb_array_elements(p_updates) AS elem
    WHERE s.id = elem->>'sense_id';

    DELETE FROM sense_tags st
    USING jsonb_array_elements(p_updates) AS elem
    WHERE st.sense_id = elem->>'sense_id'
      AND st.tag IN ('vulgar', 'sensitive')
      AND elem ? 'flags';

    INSERT INTO sense_tags (sense_id, tag)
    SELECT DISTINCT
        elem->>'sense_id',
        lower(btrim(flag_value))
    FROM jsonb_array_elements(p_updates) AS elem
    CROSS JOIN LATERAL jsonb_array_elements_text(
        CASE
            WHEN jsonb_typeof(elem->'flags') = 'array' THEN elem->'flags'
            ELSE '[]'::jsonb
        END
    ) AS flag_value
    WHERE elem ? 'flags'
      AND lower(btrim(flag_value)) IN ('vulgar', 'sensitive')
    ON CONFLICT (sense_id, tag) DO NOTHING;
END;
$$;
