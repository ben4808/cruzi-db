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
        entry_type,
        unity_bucket,
        unity_score,
        familiarity_bucket,
        familiarity_score,
        quality_bucket,
        quality_score,
        domain,
        is_vulgar,
        loading_status
    )
    SELECT
        trim(elem->>'entry'),
        trim(elem->>'lang'),
        length(trim(elem->>'entry')),
        NULLIF(trim(elem->>'display_text'), ''),
        NULLIF(trim(elem->>'entry_type'), ''),
        NULLIF(trim(elem->>'unity_bucket'), ''),
        CASE NULLIF(trim(elem->>'unity_bucket'), '')
            WHEN 'Concept' THEN 5
            WHEN 'Collocation' THEN 4
            WHEN 'Formula' THEN 3
            WHEN 'Partial' THEN 2
            WHEN 'Variant' THEN 2
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
            WHEN 'General Knowledge' THEN 30
            WHEN 'Colloquial' THEN 30
            WHEN 'Inferred' THEN 25
            WHEN 'Niche' THEN 20
            WHEN 'Variant' THEN 20
            WHEN 'Partial Phrase' THEN 20
            WHEN 'Obscure' THEN 15
            WHEN 'Barely Exists' THEN 10
            WHEN 'Nonsense' THEN 0
            ELSE NULL
        END,
        NULLIF(trim(elem->>'quality_bucket'), ''),
        CASE NULLIF(trim(elem->>'quality_bucket'), '')
            WHEN 'Non-unit' THEN 20
            WHEN 'Unfamiliar' THEN 20
            WHEN 'Uncommon Inflection' THEN 20
            WHEN 'Partial' THEN 20
            WHEN 'Clunky' THEN 20
            WHEN 'Idiomatic' THEN 40
            WHEN 'Interesting' THEN 40
            WHEN 'Appealing' THEN 40
            WHEN 'Emotional' THEN 40
            WHEN 'Trendy' THEN 40
            WHEN 'Normal' THEN 30
            ELSE NULL
        END,
        NULLIF(trim(elem->>'domain'), ''),
        CASE
            WHEN elem->>'is_vulgar' IS NULL OR btrim(elem->>'is_vulgar') = '' THEN false
            ELSE (elem->>'is_vulgar')::boolean
        END,
        'Ready'
    FROM jsonb_array_elements(p_updates) AS elem
    WHERE COALESCE(NULLIF(trim(elem->>'entry'), ''), '') <> ''
      AND COALESCE(NULLIF(trim(elem->>'lang'), ''), '') <> ''
    ON CONFLICT ("entry", lang) DO UPDATE SET
        display_text = NULLIF(trim(EXCLUDED.display_text), ''),
        entry_type = NULLIF(trim(EXCLUDED.entry_type), ''),
        unity_bucket = NULLIF(trim(EXCLUDED.unity_bucket), ''),
        unity_score = EXCLUDED.unity_score,
        familiarity_bucket = NULLIF(trim(EXCLUDED.familiarity_bucket), ''),
        familiarity_score = EXCLUDED.familiarity_score,
        quality_bucket = NULLIF(trim(EXCLUDED.quality_bucket), ''),
        quality_score = EXCLUDED.quality_score,
        domain = NULLIF(trim(EXCLUDED.domain), ''),
        is_vulgar = EXCLUDED.is_vulgar;

    PERFORM rebuild_inflected_entries_from_payload(p_updates, 'replace');
END;
$$;
