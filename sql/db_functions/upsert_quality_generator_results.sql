CREATE OR REPLACE FUNCTION upsert_quality_generator_results(entries_data jsonb)
RETURNS void AS $$
BEGIN
  UPDATE "entry" e
  SET
    quality_bucket = NULLIF(trim(elem->>'quality_bucket'), ''),
    quality_score = (elem->>'quality_score')::int,
    reviewed_status = COALESCE(NULLIF(trim(elem->>'reviewed_status'), ''), '1234')
  FROM jsonb_array_elements(entries_data) AS elem
  WHERE e."entry" = elem->>'entry'
    AND e.lang = elem->>'lang';

  DELETE FROM entry_tags et
  USING jsonb_array_elements(entries_data) AS elem
  WHERE et."entry" = elem->>'entry'
    AND et.lang = elem->>'lang'
    AND et.tag IN ('vulgar', 'sensitive');

  INSERT INTO entry_tags ("entry", lang, tag)
  SELECT DISTINCT
    e."entry",
    e.lang,
    lower(btrim(flag_value))
  FROM jsonb_array_elements(entries_data) AS elem
  JOIN "entry" e ON e."entry" = elem->>'entry' AND e.lang = elem->>'lang'
  CROSS JOIN LATERAL jsonb_array_elements_text(
    CASE
      WHEN jsonb_typeof(elem->'flags') = 'array' THEN elem->'flags'
      ELSE '[]'::jsonb
    END
  ) AS flag_value
  WHERE lower(btrim(flag_value)) IN ('vulgar', 'sensitive')
  ON CONFLICT ("entry", lang, tag) DO NOTHING;
END;
$$ LANGUAGE plpgsql;
