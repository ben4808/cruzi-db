CREATE OR REPLACE FUNCTION fill_entry_fields_from_scored_senses(p_updates jsonb)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_updates IS NULL OR jsonb_typeof(p_updates) <> 'array' OR jsonb_array_length(p_updates) = 0 THEN
        RETURN;
    END IF;

    WITH newly_scored AS (
        SELECT DISTINCT s."entry", s.lang
        FROM jsonb_array_elements(p_updates) AS elem
        JOIN sense s ON s.id = elem->>'sense_id'
        WHERE s.reviewed_status = '234'
          AND NULLIF(btrim(s.unity_bucket), '') IS NOT NULL
          AND NULLIF(btrim(s.familiarity_bucket), '') IS NOT NULL
          AND NULLIF(btrim(s.quality_bucket), '') IS NOT NULL
    ),
    entry_sense_stats AS (
        SELECT
            ns."entry",
            ns.lang,
            COUNT(*)::int AS sense_count,
            COUNT(*) FILTER (
                WHERE s.reviewed_status = '234'
                  AND NULLIF(btrim(s.unity_bucket), '') IS NOT NULL
                  AND NULLIF(btrim(s.familiarity_bucket), '') IS NOT NULL
                  AND NULLIF(btrim(s.quality_bucket), '') IS NOT NULL
            )::int AS scored_count
        FROM newly_scored ns
        JOIN sense s ON s."entry" = ns."entry" AND s.lang = ns.lang
        GROUP BY ns."entry", ns.lang
    ),
    eligible AS (
        SELECT ess."entry", ess.lang
        FROM entry_sense_stats ess
        WHERE ess.scored_count >= 2
           OR ess.sense_count = 1
    ),
    selected AS (
        SELECT DISTINCT ON (s."entry", s.lang)
            s.id AS sense_id,
            s."entry" AS entry,
            s.lang AS lang,
            NULLIF(btrim(s.display_text), '') AS display_text,
            NULLIF(btrim(s.classification), '') AS classification,
            NULLIF(btrim(s.unity_bucket), '') AS unity_bucket,
            NULLIF(btrim(s.familiarity_bucket), '') AS familiarity_bucket,
            NULLIF(btrim(s.quality_bucket), '') AS quality_bucket,
            NULLIF(btrim(s.domain), '') AS domain
        FROM eligible e
        JOIN sense s ON s."entry" = e."entry" AND s.lang = e.lang
        WHERE s.reviewed_status = '234'
          AND NULLIF(btrim(s.unity_bucket), '') IS NOT NULL
          AND NULLIF(btrim(s.familiarity_bucket), '') IS NOT NULL
          AND NULLIF(btrim(s.quality_bucket), '') IS NOT NULL
        ORDER BY
            s."entry",
            s.lang,
            CASE NULLIF(btrim(s.unity_bucket), '')
                WHEN 'Concept' THEN 1
                WHEN 'Collocation' THEN 2
                WHEN 'Formula' THEN 3
                WHEN 'Formulaic' THEN 4
                WHEN 'Variant' THEN 5
                WHEN 'Partial' THEN 6
                WHEN 'Non-unit' THEN 7
                WHEN 'Nonsense' THEN 8
                ELSE 9
            END,
            CASE NULLIF(btrim(s.familiarity_bucket), '')
                WHEN 'Ubiquitous' THEN 1
                WHEN 'Active' THEN 2
                WHEN 'Literal' THEN 3
                WHEN 'Common Name' THEN 4
                WHEN 'General Knowledge' THEN 5
                WHEN 'Inferred' THEN 6
                WHEN 'Niche' THEN 7
                WHEN 'Obscure' THEN 8
                WHEN 'Barely Exists' THEN 9
                WHEN 'Nonsense' THEN 10
                ELSE 11
            END,
            CASE NULLIF(btrim(s.quality_bucket), '')
                WHEN 'Idiomatic' THEN 1
                WHEN 'Interesting' THEN 2
                WHEN 'Appealing' THEN 3
                WHEN 'Positive' THEN 4
                WHEN 'Trendy' THEN 5
                WHEN 'Normal' THEN 6
                WHEN 'Uncommon Inflection' THEN 7
                WHEN 'Clunky' THEN 8
                WHEN 'Non-unit' THEN 9
                ELSE 10
            END,
            random()
    ),
    updated AS (
        UPDATE "entry" e
        SET
            display_text = COALESCE(selected.display_text, e.display_text),
            classification = COALESCE(selected.classification, e.classification),
            unity_bucket = selected.unity_bucket,
            unity_score = CASE selected.unity_bucket
                WHEN 'Concept' THEN 5
                WHEN 'Collocation' THEN 4
                WHEN 'Formula' THEN 3
                WHEN 'Partial' THEN 2
                WHEN 'Variant' THEN 2
                WHEN 'Formulaic' THEN 2
                WHEN 'Non-unit' THEN 2
                WHEN 'Nonsense' THEN 1
                ELSE NULL
            END,
            familiarity_bucket = selected.familiarity_bucket,
            familiarity_score = CASE selected.familiarity_bucket
                WHEN 'Ubiquitous' THEN 45
                WHEN 'Active' THEN 40
                WHEN 'Literal' THEN 35
                WHEN 'Common Name' THEN 30
                WHEN 'General Knowledge' THEN 30
                WHEN 'Inferred' THEN 25
                WHEN 'Niche' THEN 20
                WHEN 'Obscure' THEN 15
                WHEN 'Barely Exists' THEN 10
                WHEN 'Nonsense' THEN 0
                ELSE NULL
            END,
            quality_bucket = selected.quality_bucket,
            quality_score = CASE selected.quality_bucket
                WHEN 'Non-unit' THEN 20
                WHEN 'Uncommon Inflection' THEN 20
                WHEN 'Clunky' THEN 20
                WHEN 'Idiomatic' THEN 40
                WHEN 'Interesting' THEN 40
                WHEN 'Appealing' THEN 40
                WHEN 'Positive' THEN 40
                WHEN 'Trendy' THEN 40
                WHEN 'Normal' THEN 30
                ELSE NULL
            END,
            domain = selected.domain
        FROM selected
        WHERE e."entry" = selected.entry
          AND e.lang = selected.lang
        RETURNING selected.sense_id, selected.entry, selected.lang
    ),
    deleted AS (
        DELETE FROM entry_tags et
        USING updated u
        WHERE et."entry" = u.entry
          AND et.lang = u.lang
          AND lower(et.tag) IN ('vulgar', 'sensitive')
        RETURNING et."entry"
    )
    INSERT INTO entry_tags ("entry", lang, tag, "value")
    SELECT DISTINCT
        u.entry,
        u.lang,
        lower(st.tag),
        st.value
    FROM updated u
    JOIN sense_tags st ON st.sense_id = u.sense_id
    WHERE lower(st.tag) IN ('vulgar', 'sensitive')
      AND (SELECT COUNT(*) FROM deleted) IS NOT NULL
    ON CONFLICT ("entry", lang, tag) DO UPDATE SET "value" = EXCLUDED."value";
END;
$$;
