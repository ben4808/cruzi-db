CREATE OR REPLACE FUNCTION get_primary_noun_senses_low_familiarity()
RETURNS TABLE (
    sense_id text,
    "entry" text,
    display_text text,
    lang text,
    sense_summary text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.id AS sense_id,
        s."entry",
        COALESCE(e.display_text, s."entry") AS display_text,
        s.lang,
        s.summary AS sense_summary
    FROM sense s
    LEFT JOIN entry e ON e."entry" = s."entry" AND e.lang = s.lang
    WHERE s.familiarity_score < 50
      AND lower(s.part_of_speech) = 'noun'
      AND s.frequency = 'Primary'
      AND s.summary IS NOT NULL
      AND trim(s.summary) <> ''
    ORDER BY s."entry", s.lang, s.id;
END;
$$;
