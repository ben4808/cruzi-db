CREATE OR REPLACE FUNCTION update_entry_classifications(
    p_updates jsonb
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO "entry" (
        "entry",
        lang,
        "length",
        display_text,
        base_form,
        classification,
        unity_bucket,
        unity_score,
        familiarity_bucket,
        familiarity_score,
        quality_bucket,
        quality_score,
        crossword_bucket,
        domain,
        human_reviewed,
        reviewed_status,
        loading_status
    )
    SELECT
        trim(elem->>'entry'),
        trim(elem->>'lang'),
        length(trim(elem->>'entry')),
        NULLIF(trim(elem->>'display_text'), ''),
        NULLIF(trim(COALESCE(elem->>'base_form', elem->>'baseForm')), ''),
        NULLIF(trim(elem->>'classification'), ''),
        NULLIF(trim(elem->>'unity_bucket'), ''),
        CASE NULLIF(trim(elem->>'unity_bucket'), '')
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
        NULLIF(trim(elem->>'familiarity_bucket'), ''),
        CASE NULLIF(trim(elem->>'familiarity_bucket'), '')
            WHEN 'Beginner Core' THEN 50
            WHEN 'Ubiquitous' THEN 45
            WHEN 'Active' THEN 40
            WHEN 'Easy Collocation' THEN 35
            WHEN 'Literal' THEN 35
            WHEN 'Common Name' THEN 30
            WHEN 'Regionalism' THEN 30
            WHEN 'General Knowledge' THEN 30
            WHEN 'Colloquial' THEN 30
            WHEN 'Inferred' THEN 25
            WHEN 'Niche' THEN 20
            WHEN 'Variant' THEN 20
            WHEN 'Partial Phrase' THEN 20
            WHEN 'Obscure' THEN 15
            WHEN 'Nonsense' THEN 0
            ELSE NULL
        END,
        NULLIF(trim(elem->>'quality_bucket'), ''),
        CASE NULLIF(trim(elem->>'quality_bucket'), '')
            WHEN 'Idiomatic' THEN 40
            WHEN 'Interesting' THEN 40
            WHEN 'Feel-Good' THEN 40
            WHEN 'Emotional' THEN 40
            WHEN 'Trendy' THEN 40
            WHEN 'Normal' THEN 30
            ELSE NULL
        END,
        NULLIF(trim(elem->>'crossword_bucket'), ''),
        NULLIF(trim(elem->>'domain'), ''),
        CASE
            WHEN elem->>'human_reviewed' IS NULL OR btrim(elem->>'human_reviewed') = '' THEN false
            ELSE (elem->>'human_reviewed')::boolean
        END,
        CASE
            WHEN elem->>'human_reviewed' IS NULL OR btrim(elem->>'human_reviewed') = '' THEN NULL
            WHEN (elem->>'human_reviewed')::boolean THEN '1234'
            ELSE NULL
        END,
        'Ready'
    FROM jsonb_array_elements(p_updates) AS elem
    WHERE COALESCE(NULLIF(trim(elem->>'entry'), ''), '') <> ''
      AND COALESCE(NULLIF(trim(elem->>'lang'), ''), '') <> ''
    ON CONFLICT ("entry", lang) DO UPDATE SET
        display_text = NULLIF(trim(EXCLUDED.display_text), ''),
        base_form = CASE
            WHEN EXISTS (
                SELECT 1
                FROM jsonb_array_elements(p_updates) AS elem
                WHERE trim(elem->>'entry') = EXCLUDED."entry"
                  AND trim(elem->>'lang') = EXCLUDED.lang
                  AND (elem ? 'base_form' OR elem ? 'baseForm')
            ) THEN EXCLUDED.base_form
            ELSE "entry".base_form
        END,
        classification = NULLIF(trim(EXCLUDED.classification), ''),
        unity_bucket = NULLIF(trim(EXCLUDED.unity_bucket), ''),
        unity_score = EXCLUDED.unity_score,
        familiarity_bucket = NULLIF(trim(EXCLUDED.familiarity_bucket), ''),
        familiarity_score = EXCLUDED.familiarity_score,
        quality_bucket = NULLIF(trim(EXCLUDED.quality_bucket), ''),
        quality_score = EXCLUDED.quality_score,
        crossword_bucket = CASE
            WHEN EXISTS (
                SELECT 1
                FROM jsonb_array_elements(p_updates) AS elem
                WHERE trim(elem->>'entry') = EXCLUDED."entry"
                  AND trim(elem->>'lang') = EXCLUDED.lang
                  AND elem ? 'crossword_bucket'
            ) THEN EXCLUDED.crossword_bucket
            ELSE "entry".crossword_bucket
        END,
        domain = CASE
            WHEN EXCLUDED.domain IS NULL THEN "entry".domain
            ELSE NULLIF(trim(EXCLUDED.domain), '')
        END,
        human_reviewed = EXCLUDED.human_reviewed,
        reviewed_status = CASE
            WHEN EXCLUDED.human_reviewed IS TRUE AND "entry".human_reviewed IS DISTINCT FROM TRUE THEN '1234'
            ELSE "entry".reviewed_status
        END;
END;
$$;
