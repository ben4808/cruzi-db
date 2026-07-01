CREATE OR REPLACE FUNCTION insert_entries_or_fill_nulls(entries_data jsonb)
RETURNS void AS $$
BEGIN
  INSERT INTO entry ("entry", root_entry, lang, "length", display_text, entry_type, familiarity_score, quality_score, idiomacity_score, loading_status)
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
    COALESCE(NULLIF(trim(elem->>'loading_status'), ''), 'Ready')
  FROM jsonb_array_elements(entries_data) AS elem
  ON CONFLICT ("entry", lang) DO UPDATE SET
    root_entry = COALESCE(entry.root_entry, EXCLUDED.root_entry),
    display_text = COALESCE(entry.display_text, EXCLUDED.display_text),
    entry_type = COALESCE(entry.entry_type, EXCLUDED.entry_type),
    familiarity_score = COALESCE(entry.familiarity_score, EXCLUDED.familiarity_score),
    quality_score = COALESCE(entry.quality_score, EXCLUDED.quality_score),
    idiomacity_score = COALESCE(entry.idiomacity_score, EXCLUDED.idiomacity_score);
END;
$$ LANGUAGE plpgsql;
