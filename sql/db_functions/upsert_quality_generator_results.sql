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
END;
$$ LANGUAGE plpgsql;
