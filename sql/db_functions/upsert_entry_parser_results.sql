CREATE OR REPLACE FUNCTION upsert_entry_parser_results(entries_data jsonb)
RETURNS void AS $$
BEGIN
  UPDATE "entry" e
  SET
    display_text = NULLIF(trim(elem->>'display_text'), ''),
    entry_type = NULLIF(trim(elem->>'entry_type'), ''),
    base_form = NULLIF(trim(elem->>'base_form'), ''),
    is_vulgar = (elem->>'is_vulgar')::boolean,
    reviewed_status = COALESCE(NULLIF(trim(elem->>'reviewed_status'), ''), '1')
  FROM jsonb_array_elements(entries_data) AS elem
  WHERE e."entry" = elem->>'entry'
    AND e.lang = elem->>'lang';

  DELETE FROM entry_secondary_class esc
  USING jsonb_array_elements(entries_data) AS elem
  WHERE esc."entry" = elem->>'entry'
    AND esc.lang = elem->>'lang';

  INSERT INTO entry_secondary_class ("entry", lang, secondary_class, secondary_display, secondary_base_form)
  SELECT
    elem->>'entry',
    elem->>'lang',
    trim(sc->>'secondary_class'),
    trim(sc->>'secondary_display'),
    NULLIF(trim(sc->>'secondary_base_form'), '')
  FROM jsonb_array_elements(entries_data) AS elem
  CROSS JOIN LATERAL jsonb_array_elements(COALESCE(elem->'secondary_classes', '[]'::jsonb)) AS sc
  WHERE COALESCE(NULLIF(trim(sc->>'secondary_class'), ''), '') <> ''
    AND COALESCE(NULLIF(trim(sc->>'secondary_display'), ''), '') <> ''
  ON CONFLICT ("entry", lang, secondary_class) DO UPDATE SET
    secondary_display = EXCLUDED.secondary_display,
    secondary_base_form = EXCLUDED.secondary_base_form;
END;
$$ LANGUAGE plpgsql;
