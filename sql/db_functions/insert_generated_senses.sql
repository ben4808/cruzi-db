CREATE OR REPLACE FUNCTION insert_generated_senses(p_senses jsonb)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_senses IS NULL OR jsonb_typeof(p_senses) <> 'array' OR jsonb_array_length(p_senses) = 0 THEN
        RETURN;
    END IF;

    INSERT INTO sense (
        id,
        "entry",
        lang,
        display_text,
        summary,
        definition,
        part_of_speech,
        classification,
        similar_entries
    )
    SELECT
        btrim(elem->>'id'),
        btrim(elem->>'entry'),
        btrim(elem->>'lang'),
        NULLIF(btrim(elem->>'display_text'), ''),
        NULLIF(btrim(elem->>'summary'), ''),
        NULLIF(btrim(elem->>'definition'), ''),
        NULLIF(btrim(elem->>'part_of_speech'), ''),
        NULLIF(btrim(elem->>'classification'), ''),
        CASE
            WHEN jsonb_typeof(elem->'similar_entries') = 'array'
            THEN ARRAY(SELECT jsonb_array_elements_text(elem->'similar_entries'))
            ELSE NULL
        END
    FROM jsonb_array_elements(p_senses) AS elem
    WHERE COALESCE(btrim(elem->>'id'), '') <> ''
      AND COALESCE(btrim(elem->>'entry'), '') <> ''
      AND COALESCE(btrim(elem->>'lang'), '') <> ''
    ON CONFLICT (id) DO UPDATE SET
        display_text = EXCLUDED.display_text,
        summary = EXCLUDED.summary,
        definition = EXCLUDED.definition,
        part_of_speech = EXCLUDED.part_of_speech,
        classification = EXCLUDED.classification,
        similar_entries = EXCLUDED.similar_entries;

    DELETE FROM sense_tags st
    USING jsonb_array_elements(p_senses) AS elem
    WHERE st.sense_id = btrim(elem->>'id')
      AND st.tag = 'regionality'
      AND COALESCE(btrim(elem->>'id'), '') <> '';

    INSERT INTO sense_tags (sense_id, tag, value)
    SELECT DISTINCT
        btrim(elem->>'id'),
        btrim(tag_elem->>'tag'),
        NULLIF(btrim(tag_elem->>'value'), '')
    FROM jsonb_array_elements(p_senses) AS elem
    CROSS JOIN LATERAL jsonb_array_elements(
        CASE
            WHEN jsonb_typeof(elem->'tags') = 'array' THEN elem->'tags'
            ELSE '[]'::jsonb
        END
    ) AS tag_elem
    WHERE COALESCE(btrim(elem->>'id'), '') <> ''
      AND COALESCE(btrim(tag_elem->>'tag'), '') <> ''
    ON CONFLICT (sense_id, tag) DO UPDATE SET
        value = EXCLUDED.value;

    INSERT INTO sense_entry_translation (
        sense_id,
        "entry",
        translation_lang,
        natural_translations,
        colloquial_translations
    )
    SELECT DISTINCT ON (sense_id, "entry", translation_lang)
        rows.sense_id,
        rows."entry",
        rows.translation_lang,
        rows.natural_translations,
        rows.colloquial_translations
    FROM (
        SELECT
            btrim(elem->>'id') AS sense_id,
            btrim(elem->>'entry') AS "entry",
            btrim(trans->>'translation_lang') AS translation_lang,
            CASE
                WHEN jsonb_typeof(trans->'natural_translations') = 'array'
                THEN ARRAY(SELECT jsonb_array_elements_text(trans->'natural_translations'))
                ELSE NULL
            END AS natural_translations,
            CASE
                WHEN jsonb_typeof(trans->'colloquial_translations') = 'array'
                THEN ARRAY(SELECT jsonb_array_elements_text(trans->'colloquial_translations'))
                ELSE NULL
            END AS colloquial_translations
        FROM jsonb_array_elements(p_senses) AS elem
        CROSS JOIN LATERAL jsonb_array_elements(
            CASE
                WHEN jsonb_typeof(elem->'translations') = 'array' THEN elem->'translations'
                ELSE '[]'::jsonb
            END
        ) AS trans
        WHERE COALESCE(btrim(elem->>'id'), '') <> ''
          AND COALESCE(btrim(elem->>'entry'), '') <> ''
          AND COALESCE(btrim(trans->>'translation_lang'), '') <> ''
    ) AS rows
    ORDER BY sense_id, "entry", translation_lang
    ON CONFLICT (sense_id, "entry", translation_lang) DO UPDATE SET
        natural_translations = EXCLUDED.natural_translations,
        colloquial_translations = EXCLUDED.colloquial_translations;
END;
$$;
