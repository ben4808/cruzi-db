CREATE OR REPLACE FUNCTION upsert_unity_generator_results(entries_data jsonb)
RETURNS void AS $$
BEGIN
  UPDATE "entry" e
  SET
    unity_bucket = NULLIF(trim(elem->>'unity_bucket'), ''),
    unity_score = (elem->>'unity_score')::int,
    reviewed_status = COALESCE(NULLIF(trim(elem->>'reviewed_status'), ''), '12'),
    display_text = COALESCE(NULLIF(trim(elem->>'display_text'), ''), e.display_text),
    entry_type = COALESCE(NULLIF(trim(elem->>'entry_type'), ''), e.entry_type)
  FROM jsonb_array_elements(entries_data) AS elem
  WHERE e."entry" = elem->>'entry'
    AND e.lang = elem->>'lang';

  DELETE FROM entry_secondary_class esc
  USING jsonb_array_elements(entries_data) AS elem
  CROSS JOIN LATERAL jsonb_array_elements(
    COALESCE(elem->'secondary_classes_to_delete', '[]'::jsonb)
  ) AS sc
  WHERE esc."entry" = elem->>'entry'
    AND esc.lang = elem->>'lang'
    AND esc.secondary_class = trim(sc->>'secondary_class');
END;
$$ LANGUAGE plpgsql;
