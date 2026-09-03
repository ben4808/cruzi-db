CREATE OR REPLACE FUNCTION upsert_familiarity_generator_results(entries_data jsonb)
RETURNS void AS $$
BEGIN
  UPDATE "entry" e
  SET
    familiarity_bucket = NULLIF(trim(elem->>'familiarity_bucket'), ''),
    familiarity_score = (elem->>'familiarity_score')::int,
    reviewed_status = COALESCE(NULLIF(trim(elem->>'reviewed_status'), ''), '123'),
    display_text = COALESCE(NULLIF(trim(elem->>'display_text'), ''), e.display_text),
    entry_type = COALESCE(NULLIF(trim(elem->>'entry_type'), ''), e.entry_type),
    base_form = CASE
      WHEN NULLIF(trim(elem->>'display_text'), '') IS NOT NULL THEN NULLIF(trim(elem->>'base_form'), '')
      ELSE e.base_form
    END
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

  UPDATE entry_secondary_class esc
  SET familiarity_bucket = NULLIF(trim(sc->>'familiarity_bucket'), '')
  FROM jsonb_array_elements(entries_data) AS elem
  CROSS JOIN LATERAL jsonb_array_elements(
    COALESCE(elem->'secondary_classes_to_update', '[]'::jsonb)
  ) AS sc
  WHERE esc."entry" = elem->>'entry'
    AND esc.lang = elem->>'lang'
    AND esc.secondary_class = trim(sc->>'secondary_class');

  INSERT INTO entry_secondary_class ("entry", lang, secondary_class, secondary_display, secondary_base_form, familiarity_bucket)
  SELECT
    elem->>'entry',
    elem->>'lang',
    trim(sc->>'secondary_class'),
    trim(sc->>'secondary_display'),
    NULLIF(trim(sc->>'secondary_base_form'), ''),
    NULLIF(trim(sc->>'familiarity_bucket'), '')
  FROM jsonb_array_elements(entries_data) AS elem
  CROSS JOIN LATERAL jsonb_array_elements(
    COALESCE(elem->'secondary_classes_to_insert', '[]'::jsonb)
  ) AS sc
  WHERE COALESCE(NULLIF(trim(sc->>'secondary_class'), ''), '') <> ''
    AND COALESCE(NULLIF(trim(sc->>'secondary_display'), ''), '') <> ''
  ON CONFLICT ("entry", lang, secondary_class) DO UPDATE SET
    secondary_display = EXCLUDED.secondary_display,
    secondary_base_form = EXCLUDED.secondary_base_form,
    familiarity_bucket = EXCLUDED.familiarity_bucket;
END;
$$ LANGUAGE plpgsql;
