CREATE OR REPLACE FUNCTION get_random_example_sentences_top_20()
RETURNS TABLE (
    example_sentence_id text,
    sense_id text,
    display_text text,
    part_of_speech text,
    sense_summary text,
    sentence_en text,
    sentence_es text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        es.id AS example_sentence_id,
        es.sense_id,
        COALESCE(e.display_text, s."entry") AS display_text,
        s.part_of_speech,
        s.summary AS sense_summary,
        est_en.sentence AS sentence_en,
        est_es.sentence AS sentence_es
    FROM example_sentence es
    JOIN sense s ON s.id = es.sense_id
    LEFT JOIN entry e ON e."entry" = s."entry" AND e.lang = s.lang
    JOIN example_sentence_translation est_en
        ON est_en.example_sentence_id = es.id AND est_en.lang = 'en'
    JOIN example_sentence_translation est_es
        ON est_es.example_sentence_id = es.id AND est_es.lang = 'es'
    WHERE s.summary IS NOT NULL
      AND trim(s.summary) <> ''
      AND NOT EXISTS (
          SELECT 1
          FROM example_sentence_improvement esi
          WHERE esi.example_sentence_id = es.id
      )
    ORDER BY random()
    LIMIT 20;
END;
$$;
