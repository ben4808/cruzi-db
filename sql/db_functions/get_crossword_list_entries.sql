CREATE OR REPLACE FUNCTION get_crossword_list_entries(
    p_min_length integer DEFAULT 3,
    p_max_length integer DEFAULT 5,
    p_exclude_obscure boolean DEFAULT true
)
RETURNS TABLE (
    entry text,
    lang text,
    unity_bucket text,
    familiarity_bucket text,
    quality_bucket text
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
        e.quality_bucket
    FROM "entry" e
    WHERE e.entry_type IS DISTINCT FROM 'Nonsense'
      AND e.unity_bucket IS DISTINCT FROM 'Non-unit'
      AND e.unity_bucket IS DISTINCT FROM 'Nonsense'
      AND e.length >= p_min_length
      AND e.length <= p_max_length
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
