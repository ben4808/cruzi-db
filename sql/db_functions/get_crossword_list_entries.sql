DROP FUNCTION IF EXISTS get_crossword_list_entries(integer, integer, boolean);
DROP FUNCTION IF EXISTS get_crossword_list_entries(integer, integer, text);

CREATE OR REPLACE FUNCTION get_crossword_list_entries(
    p_min_length integer DEFAULT 3,
    p_max_length integer DEFAULT 9,
    p_exclude_items text DEFAULT NULL
)
RETURNS TABLE (
    entry text,
    lang text,
    classification text,
    unity_bucket text,
    familiarity_bucket text,
    quality_bucket text,
    has_avoid_tag boolean,
    is_abbreviation boolean,
    is_sensitive boolean,
    is_crosswordese boolean
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e."entry",
        e.lang,
        e.classification,
        e.unity_bucket,
        e.familiarity_bucket,
        e.quality_bucket,
        EXISTS (
            SELECT 1
            FROM entry_tags et_avoid
            WHERE et_avoid."entry" = e."entry"
              AND et_avoid.lang = e.lang
              AND et_avoid.tag IN ('breakfast_test', 'vulgar')
        ) AS has_avoid_tag,
        (e.classification = 'Acronym/Abbreviation') AS is_abbreviation,
        EXISTS (
            SELECT 1
            FROM entry_tags et_sensitive
            WHERE et_sensitive."entry" = e."entry"
              AND et_sensitive.lang = e.lang
              AND et_sensitive.tag = 'sensitive'
        ) AS is_sensitive,
        EXISTS (
            SELECT 1
            FROM entry_tags et_xwese
            WHERE et_xwese."entry" = e."entry"
              AND et_xwese.lang = e.lang
              AND et_xwese.tag = 'crosswordese'
        ) AS is_crosswordese
    FROM "entry" e
    WHERE e.display_text IS NOT NULL AND btrim(e.display_text) <> ''
      AND e.classification IS NOT NULL AND btrim(e.classification) <> ''
      AND e.length >= p_min_length
      AND e.length <= p_max_length
      AND (
          -- No excludeItems: include all items, including Nonsense.
          (
              p_exclude_items IS DISTINCT FROM 'ExcludeNonUnit'
              AND p_exclude_items IS DISTINCT FROM 'ExcludeObscure'
          )
          OR (
              e.classification IS DISTINCT FROM 'Nonsense'
              AND e.unity_bucket IS DISTINCT FROM 'Non-unit'
              AND e.unity_bucket IS DISTINCT FROM 'Non-Unit'
              AND e.unity_bucket IS DISTINCT FROM 'Nonsense'
              AND e.familiarity_bucket IS DISTINCT FROM 'Nonsense'
              AND (
                  p_exclude_items IS DISTINCT FROM 'ExcludeObscure'
                  OR (
                      e.familiarity_bucket IS DISTINCT FROM 'Obscure'
                      AND e.familiarity_bucket IS DISTINCT FROM 'Barely Exists'
                  )
              )
          )
      )
    ORDER BY e."entry";
END;
$$;
