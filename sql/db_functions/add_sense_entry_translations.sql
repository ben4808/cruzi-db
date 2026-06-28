CREATE OR REPLACE FUNCTION add_sense_entry_translations (
    p_translations jsonb
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO sense_entry_translation (sense_id, "entry", lang, natural_translations, colloquial_translations)
    SELECT
      (t->>'sense_id')::text,
      (t->>'entry')::text,
      (t->>'lang')::text,
      CASE
          WHEN t ? 'natural_translations' AND jsonb_typeof(t->'natural_translations') = 'array'
          THEN ARRAY(SELECT jsonb_array_elements_text(t->'natural_translations'))
          ELSE NULL
      END,
      CASE
          WHEN t ? 'colloquial_translations' AND jsonb_typeof(t->'colloquial_translations') = 'array'
          THEN ARRAY(SELECT jsonb_array_elements_text(t->'colloquial_translations'))
          ELSE NULL
      END
    FROM jsonb_array_elements(p_translations) AS t
    ON CONFLICT (sense_id, "entry", lang) DO UPDATE SET
        natural_translations = EXCLUDED.natural_translations,
        colloquial_translations = EXCLUDED.colloquial_translations;
END;
$$;
