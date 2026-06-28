CREATE OR REPLACE FUNCTION get_senses_for_entry(
    p_entry text,
    p_lang text
)
RETURNS TABLE(
    id text,
    part_of_speech text,
    classification text,
    frequency text,
    summary text,
    definition text,
    similar_entries text[],
    example_sentences jsonb,
    translations jsonb,
    source_ai text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.id,
        s.part_of_speech,
        s.classification,
        s.frequency,
        s.summary,
        s.definition,
        s.similar_entries,
        COALESCE(example_data.example_sentences, '[]'::jsonb) as example_sentences,
        COALESCE(translation_data.translations, '{}'::jsonb) as translations,
        s.source_ai
    FROM sense s
    LEFT JOIN LATERAL (
        SELECT jsonb_agg(
            jsonb_build_object(
                'id', es.id,
                'sentence', est.sentence,
                'lang', est.lang
            )
            ORDER BY es.id, est.lang
        ) as example_sentences
        FROM example_sentence es
        LEFT JOIN example_sentence_translation est ON es.id = est.example_sentence_id
        WHERE es.sense_id = s.id
    ) example_data ON true
    LEFT JOIN LATERAL (
        SELECT jsonb_object_agg(
            set_row.lang,
            jsonb_build_object(
                'naturalTranslations', COALESCE(to_jsonb(set_row.natural_translations), '[]'::jsonb),
                'colloquialTranslations', COALESCE(to_jsonb(set_row.colloquial_translations), '[]'::jsonb)
            )
        ) as translations
        FROM sense_entry_translation set_row
        WHERE set_row.sense_id = s.id
    ) translation_data ON true
    WHERE s.entry = p_entry AND s.lang = p_lang
    GROUP BY s.id, s.part_of_speech, s.classification, s.frequency, s.summary, s.definition, s.similar_entries, s.source_ai, example_data.example_sentences, translation_data.translations;
END;
$$;
