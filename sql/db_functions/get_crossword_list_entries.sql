DROP FUNCTION IF EXISTS get_crossword_list_entries(integer, integer, boolean);

CREATE OR REPLACE FUNCTION get_crossword_list_entries(
    p_min_length integer DEFAULT 3,
    p_max_length integer DEFAULT 6,
    p_exclude_obscure boolean DEFAULT true
)
RETURNS TABLE (
    entry text,
    lang text,
    unity_bucket text,
    familiarity_bucket text,
    quality_bucket text,
    has_avoid_tag boolean
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e."entry",
        e.lang,
        e.unity_bucket,
        e.familiarity_bucket,
        e.quality_bucket,
        EXISTS (
            SELECT 1
            FROM entry_tags et_avoid
            WHERE et_avoid."entry" = e."entry"
              AND et_avoid.lang = e.lang
              AND et_avoid.tag IN ('breakfast_test', 'vulgar')
        ) AS has_avoid_tag
    FROM "entry" e
    WHERE e.classification IS DISTINCT FROM 'Nonsense'
      AND e.unity_bucket IS DISTINCT FROM 'Non-unit'
      AND e.unity_bucket IS DISTINCT FROM 'Nonsense'
      AND e.display_text IS NOT NULL AND btrim(e.display_text) <> ''
      AND e.unity_bucket IS NOT NULL AND btrim(e.unity_bucket) <> ''
      AND e.familiarity_bucket IS NOT NULL AND btrim(e.familiarity_bucket) <> ''
      AND e.length >= p_min_length
      AND e.length <= p_max_length
      AND e.is_vulgar IS DISTINCT FROM true
      AND NOT EXISTS (
          SELECT 1
          FROM entry_tags et
          WHERE et."entry" = e."entry"
            AND et.lang = e.lang
            AND et.tag = 'breakfast_test'
      )
      AND (
          NOT p_exclude_obscure
          OR (
              e.familiarity_bucket IS DISTINCT FROM 'Obscure'
              AND e.familiarity_bucket IS DISTINCT FROM 'Barely Exists'
          )
      )
    ORDER BY e."entry";
END;
$$;
