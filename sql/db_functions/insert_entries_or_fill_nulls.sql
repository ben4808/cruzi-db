CREATE OR REPLACE FUNCTION insert_entries_or_fill_nulls(entries_data jsonb)
RETURNS void AS $$
BEGIN
  INSERT INTO entry ("entry", lang, "length", display_text, entry_type, familiarity_bucket, familiarity_score, quality_score, unity_bucket, unity_score, is_vulgar, loading_status, reviewed_status)
  SELECT
    elem->>'entry',
    elem->>'lang',
    COALESCE((elem->>'length')::int, length((elem->>'entry')::text)),
    NULLIF(trim(elem->>'display_text'), ''),
    NULLIF(trim(elem->>'entry_type'), ''),
    NULLIF(trim(elem->>'familiarity_bucket'), ''),
    (elem->>'familiarity_score')::int,
    (elem->>'quality_score')::int,
    NULLIF(trim(elem->>'unity_bucket'), ''),
    (elem->>'unity_score')::int,
    CASE
      WHEN elem->>'is_vulgar' IS NULL OR trim(elem->>'is_vulgar') = '' THEN NULL
      ELSE (elem->>'is_vulgar')::boolean
    END,
    COALESCE(NULLIF(trim(elem->>'loading_status'), ''), 'Ready'),
    NULLIF(trim(elem->>'reviewed_status'), '')
  FROM jsonb_array_elements(entries_data) AS elem
  ON CONFLICT ("entry", lang) DO UPDATE SET
    display_text = COALESCE(entry.display_text, EXCLUDED.display_text),
    entry_type = COALESCE(entry.entry_type, EXCLUDED.entry_type),
    familiarity_bucket = COALESCE(entry.familiarity_bucket, EXCLUDED.familiarity_bucket),
    familiarity_score = COALESCE(entry.familiarity_score, EXCLUDED.familiarity_score),
    quality_score = COALESCE(entry.quality_score, EXCLUDED.quality_score),
    unity_bucket = COALESCE(entry.unity_bucket, EXCLUDED.unity_bucket),
    unity_score = COALESCE(entry.unity_score, EXCLUDED.unity_score),
    is_vulgar = COALESCE(entry.is_vulgar, EXCLUDED.is_vulgar);

  PERFORM rebuild_inflected_entries_from_payload(entries_data, 'fill');
END;
$$ LANGUAGE plpgsql;
