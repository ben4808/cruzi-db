CREATE OR REPLACE FUNCTION fill_entry_fields_from_scored_senses(p_updates jsonb)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_updates IS NULL OR jsonb_typeof(p_updates) <> 'array' OR jsonb_array_length(p_updates) = 0 THEN
        RETURN;
    END IF;

    WITH src AS (
        SELECT DISTINCT ON (s."entry", s.lang)
            s."entry" AS entry,
            s.lang AS lang,
            NULLIF(btrim(s.display_text), '') AS display_text,
            NULLIF(btrim(s.classification), '') AS entry_type,
            NULLIF(btrim(s.unity_bucket), '') AS unity_bucket,
            NULLIF(btrim(s.familiarity_bucket), '') AS familiarity_bucket,
            NULLIF(btrim(s.quality_bucket), '') AS quality_bucket,
            NULLIF(btrim(s.domain), '') AS domain,
            (elem->>'unity_score')::int AS unity_score,
            (elem->>'familiarity_score')::int AS familiarity_score,
            (elem->>'quality_score')::int AS quality_score
        FROM jsonb_array_elements(p_updates) AS elem
        JOIN sense s ON s.id = elem->>'sense_id'
        WHERE s.reviewed_status = '234'
          AND NULLIF(btrim(s.unity_bucket), '') IS NOT NULL
          AND NULLIF(btrim(s.familiarity_bucket), '') IS NOT NULL
          AND NULLIF(btrim(s.quality_bucket), '') IS NOT NULL
        ORDER BY s."entry", s.lang, s.id
    )
    UPDATE "entry" e
    SET
        display_text = CASE
            WHEN NULLIF(btrim(e.display_text), '') IS NULL THEN src.display_text
            ELSE e.display_text
        END,
        entry_type = CASE
            WHEN NULLIF(btrim(e.entry_type), '') IS NULL THEN src.entry_type
            ELSE e.entry_type
        END,
        unity_score = CASE
            WHEN NULLIF(btrim(e.unity_bucket), '') IS NULL AND src.unity_bucket IS NOT NULL
                THEN src.unity_score
            ELSE e.unity_score
        END,
        unity_bucket = CASE
            WHEN NULLIF(btrim(e.unity_bucket), '') IS NULL THEN src.unity_bucket
            ELSE e.unity_bucket
        END,
        familiarity_score = CASE
            WHEN NULLIF(btrim(e.familiarity_bucket), '') IS NULL AND src.familiarity_bucket IS NOT NULL
                THEN src.familiarity_score
            ELSE e.familiarity_score
        END,
        familiarity_bucket = CASE
            WHEN NULLIF(btrim(e.familiarity_bucket), '') IS NULL THEN src.familiarity_bucket
            ELSE e.familiarity_bucket
        END,
        quality_score = CASE
            WHEN NULLIF(btrim(e.quality_bucket), '') IS NULL AND src.quality_bucket IS NOT NULL
                THEN src.quality_score
            ELSE e.quality_score
        END,
        quality_bucket = CASE
            WHEN NULLIF(btrim(e.quality_bucket), '') IS NULL THEN src.quality_bucket
            ELSE e.quality_bucket
        END,
        domain = CASE
            WHEN NULLIF(btrim(e.domain), '') IS NULL THEN src.domain
            ELSE e.domain
        END
    FROM src
    WHERE e."entry" = src.entry
      AND e.lang = src.lang;
END;
$$;
