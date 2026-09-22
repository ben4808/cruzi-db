CREATE OR REPLACE FUNCTION inflected_base_form_for_entry(p_entry text, p_lang text)
RETURNS text
LANGUAGE sql
STABLE
AS $$
  SELECT COALESCE(
    (
      SELECT NULLIF(btrim(b.display_text), '')
      FROM "entry" b
      WHERE b."entry" = ie.base_entry
        AND b.lang = ie.lang
    ),
    ie.base_entry
  )
  FROM inflected_entry ie
  WHERE ie.inflected_entry = p_entry
    AND ie.lang = p_lang
  ORDER BY ie.is_common DESC, ie.base_entry
  LIMIT 1
$$;
