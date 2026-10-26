DROP FUNCTION IF EXISTS get_crosswordese_and_abbreviation_entries(integer, integer, text);

CREATE OR REPLACE FUNCTION get_crosswordese_and_abbreviation_entries(
    p_min_length integer DEFAULT 3,
    p_max_length integer DEFAULT 15,
    p_lang text DEFAULT 'en'
)
RETURNS TABLE (
    entry text,
    lang text,
    is_crosswordese boolean,
    is_abbreviation boolean
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e."entry",
        e.lang,
        EXISTS (
            SELECT 1
            FROM entry_tags et
            WHERE et."entry" = e."entry"
              AND et.lang = e.lang
              AND et.tag = 'crosswordese'
        ) AS is_crosswordese,
        (e.classification = 'Acronym/Abbreviation') AS is_abbreviation
    FROM "entry" e
    WHERE e.lang = p_lang
      AND e."length" >= p_min_length
      AND e."length" <= p_max_length
      AND e."entry" ~ '^[A-Z]+$'
      AND (
          e.classification = 'Acronym/Abbreviation'
          OR EXISTS (
              SELECT 1
              FROM entry_tags et
              WHERE et."entry" = e."entry"
                AND et.lang = e.lang
                AND et.tag = 'crosswordese'
          )
      )
      AND e.unity_bucket IS DISTINCT FROM 'Non-unit'
      AND e.unity_bucket IS DISTINCT FROM 'Nonsense'
      AND e.familiarity_bucket IS DISTINCT FROM 'Barely Exists'
      AND NOT EXISTS (
          SELECT 1
          FROM entry_tags et
          WHERE et."entry" = e."entry"
            AND et.lang = e.lang
            AND et.tag IN ('breakfast_test', 'vulgar')
      )
    ORDER BY e."entry";
END;
$$;
