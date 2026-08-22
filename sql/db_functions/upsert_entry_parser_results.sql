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
  SELECT DISTINCT ON (sc_rows."entry", sc_rows.lang, sc_rows.secondary_class)
    sc_rows."entry",
    sc_rows.lang,
    sc_rows.secondary_class,
    sc_rows.secondary_display,
    sc_rows.secondary_base_form
  FROM (
    SELECT
      elem->>'entry' AS "entry",
      elem->>'lang' AS lang,
      trim(sc->>'secondary_class') AS secondary_class,
      trim(sc->>'secondary_display') AS secondary_display,
      NULLIF(trim(sc->>'secondary_base_form'), '') AS secondary_base_form,
      elem.entry_ord,
      sc.sc_ord
    FROM jsonb_array_elements(entries_data) WITH ORDINALITY AS elem(elem, entry_ord)
    CROSS JOIN LATERAL jsonb_array_elements(COALESCE(elem.elem->'secondary_classes', '[]'::jsonb))
      WITH ORDINALITY AS sc(sc, sc_ord)
    WHERE COALESCE(NULLIF(trim(sc->>'secondary_class'), ''), '') <> ''
      AND COALESCE(NULLIF(trim(sc->>'secondary_display'), ''), '') <> ''
  ) AS sc_rows
  ORDER BY sc_rows."entry", sc_rows.lang, sc_rows.secondary_class, sc_rows.entry_ord, sc_rows.sc_ord
  ON CONFLICT ("entry", lang, secondary_class) DO UPDATE SET
    secondary_display = EXCLUDED.secondary_display,
    secondary_base_form = EXCLUDED.secondary_base_form;
END;
$$ LANGUAGE plpgsql;
