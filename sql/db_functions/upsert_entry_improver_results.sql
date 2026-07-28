CREATE OR REPLACE FUNCTION upsert_entry_improver_results(entries_data jsonb)
RETURNS void AS $$
BEGIN
  INSERT INTO "entry" (
    "entry",
    lang,
    "length",
    entry_type,
    display_text,
    base_form,
    unity_bucket,
    unity_score,
    familiarity_bucket,
    familiarity_score,
    quality_bucket,
    quality_score,
    is_vulgar,
    reviewed_status,
    loading_status
  )
  SELECT
    elem->>'entry',
    elem->>'lang',
    COALESCE((elem->>'length')::int, length((elem->>'entry')::text)),
    NULLIF(trim(elem->>'entry_type'), ''),
    NULLIF(trim(elem->>'display_text'), ''),
    NULLIF(trim(elem->>'base_form'), ''),
    NULLIF(trim(elem->>'unity_bucket'), ''),
    (elem->>'unity_score')::int,
    NULLIF(trim(elem->>'familiarity_bucket'), ''),
    (elem->>'familiarity_score')::int,
    NULLIF(trim(elem->>'quality_bucket'), ''),
    (elem->>'quality_score')::int,
    (elem->>'is_vulgar')::boolean,
    COALESCE(NULLIF(trim(elem->>'reviewed_status'), ''), 'R'),
    COALESCE(NULLIF(trim(elem->>'loading_status'), ''), 'Ready')
  FROM jsonb_array_elements(entries_data) AS elem
  ON CONFLICT ("entry", lang) DO UPDATE SET
    entry_type = EXCLUDED.entry_type,
    display_text = EXCLUDED.display_text,
    base_form = EXCLUDED.base_form,
    unity_bucket = EXCLUDED.unity_bucket,
    unity_score = EXCLUDED.unity_score,
    familiarity_bucket = EXCLUDED.familiarity_bucket,
    familiarity_score = EXCLUDED.familiarity_score,
    quality_bucket = EXCLUDED.quality_bucket,
    quality_score = EXCLUDED.quality_score,
    is_vulgar = EXCLUDED.is_vulgar,
    reviewed_status = EXCLUDED.reviewed_status;
END;
$$ LANGUAGE plpgsql;
