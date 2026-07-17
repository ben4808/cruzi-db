CREATE OR REPLACE FUNCTION upsert_entries(entries_data jsonb)
RETURNS void AS $$
BEGIN
  INSERT INTO entry ("entry", root_entry, lang, "length", display_text, entry_type, familiarity_score, quality_score, idiomacity_score, unity_bucket, loading_status)
  SELECT
    elem->>'entry',
    NULLIF(trim(elem->>'root_entry'), ''),
    elem->>'lang',
    COALESCE((elem->>'length')::int, length((elem->>'entry')::text)),
    NULLIF(trim(elem->>'display_text'), ''),
    NULLIF(trim(elem->>'entry_type'), ''),
    (elem->>'familiarity_score')::int,
    (elem->>'quality_score')::int,
    (elem->>'idiomacity_score')::int,
    NULLIF(trim(elem->>'unity_bucket'), ''),
    COALESCE(NULLIF(trim(elem->>'loading_status'), ''), 'Ready')
  FROM jsonb_array_elements(entries_data) AS elem
  ON CONFLICT ("entry", lang) DO UPDATE SET
    root_entry = COALESCE(EXCLUDED.root_entry, entry.root_entry),
    "length" = COALESCE(EXCLUDED."length", entry."length"),
    display_text = COALESCE(EXCLUDED.display_text, entry.display_text),
    entry_type = COALESCE(EXCLUDED.entry_type, entry.entry_type),
    familiarity_score = COALESCE(EXCLUDED.familiarity_score, entry.familiarity_score),
    quality_score = COALESCE(EXCLUDED.quality_score, entry.quality_score),
    idiomacity_score = COALESCE(EXCLUDED.idiomacity_score, entry.idiomacity_score),
    unity_bucket = COALESCE(EXCLUDED.unity_bucket, entry.unity_bucket),
    loading_status = COALESCE(EXCLUDED.loading_status, entry.loading_status);
END;
$$ LANGUAGE plpgsql;
