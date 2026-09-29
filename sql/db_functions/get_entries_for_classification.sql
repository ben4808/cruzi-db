DROP FUNCTION IF EXISTS get_entries_for_classification(jsonb);

CREATE OR REPLACE FUNCTION get_entries_for_classification(
    p_items jsonb
)
RETURNS TABLE (
    fill_word text,
    entry text,
    lang text,
    display_text text,
    classification text,
    unity_bucket text,
    familiarity_bucket text,
    quality_bucket text,
    is_vulgar boolean,
    is_crosswordese boolean,
    is_breakfast boolean,
    is_sensitive boolean,
    nyt_value text,
    sense_id text,
    sense_summary text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT ON (requested.fill_word)
        requested.fill_word,
        e."entry",
        e.lang,
        CASE WHEN s.id IS NOT NULL THEN s.display_text ELSE e.display_text END,
        CASE WHEN s.id IS NOT NULL THEN s.classification ELSE e.classification END,
        CASE WHEN s.id IS NOT NULL THEN s.unity_bucket ELSE e.unity_bucket END,
        CASE WHEN s.id IS NOT NULL THEN s.familiarity_bucket ELSE e.familiarity_bucket END,
        CASE WHEN s.id IS NOT NULL THEN s.quality_bucket ELSE e.quality_bucket END,
        CASE
            WHEN s.id IS NOT NULL THEN EXISTS (
                SELECT 1
                FROM sense_tags st
                WHERE st.sense_id = s.id
                  AND lower(st.tag) = 'vulgar'
            )
            ELSE EXISTS (
                SELECT 1
                FROM entry_tags et
                WHERE et."entry" = e."entry"
                  AND et.lang = e.lang
                  AND lower(et.tag) = 'vulgar'
            ) OR COALESCE(e.is_vulgar, false)
        END AS is_vulgar,
        EXISTS (
            SELECT 1
            FROM entry_tags et
            WHERE et."entry" = e."entry"
              AND et.lang = e.lang
              AND et.tag = 'crosswordese'
        ) AS is_crosswordese,
        EXISTS (
            SELECT 1
            FROM entry_tags et
            WHERE et."entry" = e."entry"
              AND et.lang = e.lang
              AND et.tag = 'breakfast_test'
        ) AS is_breakfast,
        CASE
            WHEN s.id IS NOT NULL THEN EXISTS (
                SELECT 1
                FROM sense_tags st
                WHERE st.sense_id = s.id
                  AND lower(st.tag) = 'sensitive'
            )
            ELSE EXISTS (
                SELECT 1
                FROM entry_tags et
                WHERE et."entry" = e."entry"
                  AND et.lang = e.lang
                  AND lower(et.tag) = 'sensitive'
            )
        END AS is_sensitive,
        nyt."value" AS nyt_value,
        s.id AS sense_id,
        s.summary AS sense_summary
    FROM (
        SELECT DISTINCT
            upper(trim(COALESCE(
                NULLIF(elem->>'fill_word', ''),
                NULLIF(elem->>'fillWord', ''),
                CASE WHEN jsonb_typeof(elem) = 'string' THEN trim(elem#>>'{}') ELSE NULL END
            ))) AS fill_word,
            NULLIF(trim(COALESCE(elem->>'sense_id', elem->>'senseId', '')), '') AS sense_id
        FROM jsonb_array_elements(p_items) AS elem
        WHERE COALESCE(NULLIF(trim(COALESCE(
                NULLIF(elem->>'fill_word', ''),
                NULLIF(elem->>'fillWord', ''),
                CASE WHEN jsonb_typeof(elem) = 'string' THEN trim(elem#>>'{}') ELSE NULL END
            )), ''), '') <> ''
    ) requested
    LEFT JOIN "entry" e
      ON e.lang = 'en'
     AND normalize_display_text_to_entry_key(e."entry") = requested.fill_word
    LEFT JOIN sense s
      ON s.id = requested.sense_id
    LEFT JOIN entry_tags nyt
      ON nyt."entry" = e."entry"
     AND nyt.lang = e.lang
     AND nyt.tag = 'nyt'
    ORDER BY
        requested.fill_word,
        (e."entry" IS NOT NULL) DESC,
        e."entry";
END;
$$;
