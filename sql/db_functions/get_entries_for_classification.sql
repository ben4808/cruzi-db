DROP FUNCTION IF EXISTS get_entries_for_classification(jsonb);

CREATE OR REPLACE FUNCTION get_entries_for_classification(
    p_fill_words jsonb
)
RETURNS TABLE (
    fill_word text,
    entry text,
    lang text,
    base_form text,
    display_text text,
    entry_type text,
    unity_bucket text,
    familiarity_bucket text,
    quality_bucket text,
    domain text,
    regionality text,
    is_vulgar boolean,
    is_crosswordese boolean,
    is_breakfast boolean,
    is_sensitive boolean,
    nyt_value text,
    senses jsonb
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT ON (requested.fill_word)
        requested.fill_word,
        e."entry",
        e.lang,
        inflected_base_form_for_entry(COALESCE(e."entry", requested.fill_word), COALESCE(e.lang, 'en')) AS base_form,
        e.display_text,
        e.entry_type,
        e.unity_bucket,
        e.familiarity_bucket,
        e.quality_bucket,
        e.domain,
        (
            SELECT et."value"
            FROM entry_tags et
            WHERE et."entry" = e."entry"
              AND et.lang = e.lang
              AND lower(et.tag) = 'regionality'
            LIMIT 1
        ) AS regionality,
        e.is_vulgar,
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
        EXISTS (
            SELECT 1
            FROM entry_tags et
            WHERE et."entry" = e."entry"
              AND et.lang = e.lang
              AND lower(et.tag) = 'sensitive'
        ) AS is_sensitive,
        nyt."value" AS nyt_value,
        COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id', s.id,
                    'summary', COALESCE(s.summary, ''),
                    'display_text', COALESCE(s.display_text, ''),
                    'classification', COALESCE(s.classification, ''),
                    'unity_bucket', COALESCE(s.unity_bucket, ''),
                    'familiarity_bucket', COALESCE(s.familiarity_bucket, ''),
                    'quality_bucket', COALESCE(s.quality_bucket, ''),
                    'domain', COALESCE(s.domain, ''),
                    'regionality', COALESCE((
                        SELECT st."value"
                        FROM sense_tags st
                        WHERE st.sense_id = s.id
                          AND lower(st.tag) = 'regionality'
                        LIMIT 1
                    ), ''),
                    'is_vulgar', EXISTS (
                        SELECT 1
                        FROM sense_tags st
                        WHERE st.sense_id = s.id
                          AND lower(st.tag) = 'vulgar'
                    ),
                    'is_sensitive', EXISTS (
                        SELECT 1
                        FROM sense_tags st
                        WHERE st.sense_id = s.id
                          AND lower(st.tag) = 'sensitive'
                    )
                )
                ORDER BY s.summary, s.id
            )
            FROM sense s
            WHERE s.lang = COALESCE(e.lang, 'en')
              AND (
                    s."entry" = COALESCE(e."entry", requested.fill_word)
                    OR s."entry" IN (
                        SELECT ie.base_entry
                        FROM inflected_entry ie
                        WHERE ie.inflected_entry = COALESCE(e."entry", requested.fill_word)
                          AND ie.lang = COALESCE(e.lang, 'en')
                    )
              )
        ), '[]'::jsonb) AS senses
    FROM (
        SELECT DISTINCT upper(trim(value)) AS fill_word
        FROM jsonb_array_elements_text(p_fill_words) AS t(value)
        WHERE COALESCE(NULLIF(trim(value), ''), '') <> ''
    ) requested
    LEFT JOIN "entry" e
      ON e.lang = 'en'
     AND normalize_display_text_to_entry_key(e."entry") = requested.fill_word
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
