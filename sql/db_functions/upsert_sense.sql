CREATE OR REPLACE FUNCTION upsert_sense(
    p_entry text,
    p_lang text,
    sense_data jsonb
)
RETURNS void AS $$
DECLARE
    v_sense_id text := sense_data->>'id';
BEGIN
    INSERT INTO sense (
        id,
        "entry",
        lang,
        display_text,
        base_form,
        inflections,
        part_of_speech,
        classification,
        frequency,
        summary,
        definition,
        similar_entries,
        source_ai
    ) VALUES (
        v_sense_id,
        p_entry,
        p_lang,
        sense_data->>'display_text',
        sense_data->>'base_form',
        CASE
            WHEN sense_data ? 'inflections' AND jsonb_typeof(sense_data->'inflections') = 'array'
            THEN ARRAY(SELECT jsonb_array_elements_text(sense_data->'inflections'))
            ELSE NULL
        END,
        sense_data->>'part_of_speech',
        sense_data->>'classification',
        sense_data->>'frequency',
        sense_data->>'summary',
        sense_data->>'definition',
        CASE
            WHEN sense_data ? 'similar_entries' AND jsonb_typeof(sense_data->'similar_entries') = 'array'
            THEN ARRAY(SELECT jsonb_array_elements_text(sense_data->'similar_entries'))
            ELSE NULL
        END,
        sense_data->>'source_ai'
    )
    ON CONFLICT (id) DO UPDATE SET
        "entry" = EXCLUDED."entry",
        lang = EXCLUDED.lang,
        display_text = CASE WHEN sense_data ? 'display_text' THEN EXCLUDED.display_text ELSE sense.display_text END,
        base_form = CASE WHEN sense_data ? 'base_form' THEN EXCLUDED.base_form ELSE sense.base_form END,
        inflections = CASE WHEN sense_data ? 'inflections' THEN EXCLUDED.inflections ELSE sense.inflections END,
        part_of_speech = EXCLUDED.part_of_speech,
        classification = EXCLUDED.classification,
        frequency = EXCLUDED.frequency,
        summary = EXCLUDED.summary,
        definition = EXCLUDED.definition,
        similar_entries = EXCLUDED.similar_entries,
        source_ai = EXCLUDED.source_ai;

    INSERT INTO sense_entry_translation (sense_id, "entry", lang, natural_translations, colloquial_translations)
    SELECT
        v_sense_id AS sense_id,
        p_entry AS "entry",
        lang_key AS lang,
        CASE
            WHEN jsonb_typeof(COALESCE(trans->'naturalTranslations', trans->'natural_translations')) = 'array'
            THEN ARRAY(
                SELECT CASE
                    WHEN jsonb_typeof(t) = 'string' THEN t#>>'{}'
                    ELSE COALESCE(t->>'displayText', t->>'display_text', t->>'entry')
                END
                FROM jsonb_array_elements(COALESCE(trans->'naturalTranslations', trans->'natural_translations')) AS t
            )
            ELSE NULL
        END AS natural_translations,
        CASE
            WHEN jsonb_typeof(COALESCE(trans->'colloquialTranslations', trans->'colloquial_translations')) = 'array'
            THEN ARRAY(
                SELECT CASE
                    WHEN jsonb_typeof(t) = 'string' THEN t#>>'{}'
                    ELSE COALESCE(t->>'displayText', t->>'display_text', t->>'entry')
                END
                FROM jsonb_array_elements(COALESCE(trans->'colloquialTranslations', trans->'colloquial_translations')) AS t
            )
            ELSE NULL
        END AS colloquial_translations
    FROM jsonb_each(COALESCE(sense_data->'translations', '{}'::jsonb)) AS x(lang_key, trans)
    ON CONFLICT (sense_id, "entry", lang) DO UPDATE SET
        natural_translations = EXCLUDED.natural_translations,
        colloquial_translations = EXCLUDED.colloquial_translations;

    INSERT INTO example_sentence (id, sense_id)
    SELECT
        ex_sentence->>'id' AS id,
        ex_sentence->>'senseId' AS sense_id
    FROM
        jsonb_array_elements(COALESCE(sense_data->'example_sentences', '[]'::jsonb)) AS ex_sentence
    WHERE
        jsonb_typeof(COALESCE(sense_data->'example_sentences', '[]'::jsonb)) = 'array'
    ON CONFLICT (id) DO UPDATE SET
        sense_id = EXCLUDED.sense_id;

    INSERT INTO example_sentence_translation (example_sentence_id, lang, sentence)
    SELECT
        ex_sentence->>'id' AS example_sentence_id,
        lang,
        sentence
    FROM
        jsonb_array_elements(COALESCE(sense_data->'example_sentences', '[]'::jsonb)) AS ex_sentence,
        jsonb_each_text(ex_sentence->'translations') AS translation_pair(lang, sentence)
    WHERE
        jsonb_typeof(COALESCE(sense_data->'example_sentences', '[]'::jsonb)) = 'array'
    ON CONFLICT (example_sentence_id, lang) DO UPDATE SET
        sentence = EXCLUDED.sentence;
END;
$$ LANGUAGE plpgsql;
