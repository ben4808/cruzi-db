CREATE OR REPLACE FUNCTION apply_inflection_generator_results(p_results jsonb)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_results IS NULL OR jsonb_typeof(p_results) <> 'array' OR jsonb_array_length(p_results) = 0 THEN
        RETURN;
    END IF;

    DROP TABLE IF EXISTS tmp_inflection_items, tmp_inflection_forms, tmp_base_forms;

    CREATE TEMP TABLE tmp_inflection_items ON COMMIT DROP AS
    SELECT
        btrim(elem->>'entry') AS item_entry,
        btrim(elem->>'lang') AS item_lang,
        COALESCE(elem->'inflections', '[]'::jsonb) AS inflections,
        COALESCE(elem->'base_forms', '[]'::jsonb) AS base_forms
    FROM jsonb_array_elements(p_results) AS elem
    WHERE COALESCE(btrim(elem->>'entry'), '') <> ''
      AND COALESCE(btrim(elem->>'lang'), '') <> ''
      AND COALESCE((elem->>'has_results')::boolean, false);

    CREATE TEMP TABLE tmp_inflection_forms ON COMMIT DROP AS
    SELECT DISTINCT ON (i.item_entry, i.item_lang, normalize_display_text_to_entry_key(form->>'display_text'))
        i.item_entry,
        i.item_lang,
        normalize_display_text_to_entry_key(form->>'display_text') AS form_entry,
        NULLIF(btrim(form->>'display_text'), '') AS display_text,
        NULLIF(btrim(form->>'inflected_type'), '') AS inflected_type
    FROM tmp_inflection_items i
    CROSS JOIN LATERAL jsonb_array_elements(i.inflections) AS form
    WHERE normalize_display_text_to_entry_key(form->>'display_text') <> ''
      AND normalize_display_text_to_entry_key(form->>'display_text') <> i.item_entry
    ORDER BY i.item_entry, i.item_lang, normalize_display_text_to_entry_key(form->>'display_text');

    CREATE TEMP TABLE tmp_base_forms ON COMMIT DROP AS
    SELECT DISTINCT ON (i.item_entry, i.item_lang, normalize_display_text_to_entry_key(base_text))
        i.item_entry,
        i.item_lang,
        normalize_display_text_to_entry_key(base_text) AS base_entry,
        NULLIF(btrim(base_text), '') AS display_text
    FROM tmp_inflection_items i
    CROSS JOIN LATERAL jsonb_array_elements_text(i.base_forms) AS base_text
    WHERE normalize_display_text_to_entry_key(base_text) <> ''
      AND normalize_display_text_to_entry_key(base_text) <> i.item_entry
    ORDER BY i.item_entry, i.item_lang, normalize_display_text_to_entry_key(base_text);

    DELETE FROM inflected_entry ie
    USING tmp_inflection_items i
    WHERE ie.base_entry = i.item_entry
      AND ie.lang = i.item_lang;

    WITH inserted AS (
        INSERT INTO "entry" ("entry", lang, "length", display_text)
        SELECT DISTINCT ON (f.form_entry, f.item_lang)
            f.form_entry,
            f.item_lang,
            length(f.form_entry),
            f.display_text
        FROM tmp_inflection_forms f
        ORDER BY f.form_entry, f.item_lang
        ON CONFLICT ("entry", lang) DO NOTHING
        RETURNING "entry", lang
    )
    INSERT INTO entry_tags ("entry", lang, tag)
    SELECT inserted."entry", inserted.lang, 'inflection_generator'
    FROM inserted
    ON CONFLICT ("entry", lang, tag) DO NOTHING;

    WITH inserted AS (
        INSERT INTO "entry" ("entry", lang, "length", display_text)
        SELECT DISTINCT ON (b.base_entry, b.item_lang)
            b.base_entry,
            b.item_lang,
            length(b.base_entry),
            b.display_text
        FROM tmp_base_forms b
        ORDER BY b.base_entry, b.item_lang
        ON CONFLICT ("entry", lang) DO NOTHING
        RETURNING "entry", lang
    )
    INSERT INTO entry_tags ("entry", lang, tag)
    SELECT inserted."entry", inserted.lang, 'inflection_generator'
    FROM inserted
    ON CONFLICT ("entry", lang, tag) DO NOTHING;

    INSERT INTO inflected_entry (base_entry, inflected_entry, lang, display_text, inflected_type)
    SELECT f.item_entry, f.form_entry, f.item_lang, f.display_text, f.inflected_type
    FROM tmp_inflection_forms f
    ON CONFLICT (base_entry, inflected_entry, lang) DO UPDATE SET
        display_text = EXCLUDED.display_text,
        inflected_type = EXCLUDED.inflected_type;

    INSERT INTO inflected_entry (base_entry, inflected_entry, lang, display_text)
    SELECT b.base_entry, b.item_entry, b.item_lang, e.display_text
    FROM tmp_base_forms b
    LEFT JOIN "entry" e ON e."entry" = b.item_entry AND e.lang = b.item_lang
    ON CONFLICT (base_entry, inflected_entry, lang) DO NOTHING;

    DELETE FROM sense s
    WHERE EXISTS (
        SELECT 1
        FROM tmp_base_forms b
        WHERE b.item_entry = s."entry"
          AND b.item_lang = s.lang
    );

    UPDATE "entry" e
    SET loading_status = 'I'
    FROM jsonb_array_elements(p_results) AS elem
    WHERE e."entry" = btrim(elem->>'entry')
      AND e.lang = btrim(elem->>'lang');
END;
$$;
