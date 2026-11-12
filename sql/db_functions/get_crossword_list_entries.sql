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
    crossword_bucket text,
    base_form text,
    has_avoid_tag boolean,
    has_sensitive_tag boolean
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
        e.crossword_bucket,
        e.base_form,
        EXISTS (
            SELECT 1
            FROM entry_tags et_avoid
            WHERE et_avoid."entry" = e."entry"
              AND et_avoid.lang = e.lang
              AND et_avoid.tag IN ('gross', 'vulgar')
        ) AS has_avoid_tag,
        EXISTS (
            SELECT 1
            FROM entry_tags et_sensitive
            WHERE et_sensitive."entry" = e."entry"
              AND et_sensitive.lang = e.lang
              AND et_sensitive.tag = 'sensitive'
        ) AS has_sensitive_tag
    FROM "entry" e
    WHERE e.display_text IS NOT NULL AND btrim(e.display_text) <> ''
      AND e.classification IS NOT NULL AND btrim(e.classification) <> ''
      AND e.length >= p_min_length
      AND e.length <= p_max_length
      AND (
          p_exclude_items IS NULL
          OR (
              e.classification IS DISTINCT FROM 'Nonsense'
              AND e.unity_bucket IS DISTINCT FROM 'Nonsense'
              AND e.familiarity_bucket IS DISTINCT FROM 'Nonsense'
              AND (
                  p_exclude_items = 'ExcludeNotAThing'
                  OR (
                      e.familiarity_bucket IS DISTINCT FROM 'Obscure'
                      AND (
                          p_exclude_items = 'ExcludeNotGettable'
                          OR (
                              p_exclude_items = 'ExcludeMaybeGettable'
                              AND e.unity_bucket IN (
                                  'Concept', 'Collocation', 'Formula', 'Variant',
                                  'Partial', 'Formulaic'
                              )
                              AND e.familiarity_bucket IN (
                                  'Ubiquitous', 'Active', 'Literal', 'Common Name',
                                  'Regionalism', 'General Knowledge', 'Inferred'
                              )
                          )
                      )
                  )
              )
          )
      )
    ORDER BY e."entry";
END;
$$;
