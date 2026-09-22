CREATE OR REPLACE FUNCTION get_matched_senses_without_references(
    p_puzzle_id text,
    p_limit integer,
    p_exclude jsonb DEFAULT '[]'::jsonb
)
RETURNS TABLE (
    sense_id text,
    entry text,
    lang text,
    display_text text,
    summary text
)
LANGUAGE plpgsql
AS $$
#variable_conflict use_column
BEGIN
    RETURN QUERY
    SELECT DISTINCT ON (s.id)
        s.id AS sense_id,
        s."entry" AS entry,
        s.lang AS lang,
        COALESCE(NULLIF(btrim(s.display_text), ''), NULLIF(btrim(e.display_text), '')) AS display_text,
        s.summary AS summary
    FROM clue_collection cc
    JOIN collection__clue ccl ON ccl.collection_id = cc.id
    JOIN clue c ON c.id = ccl.clue_id
    JOIN sense s ON s.id = c.sense_id
    LEFT JOIN "entry" e ON e."entry" = s."entry" AND e.lang = s.lang
    WHERE cc.puzzle_id = p_puzzle_id
      AND NOT EXISTS (
          SELECT 1
          FROM sense_reference sr
          WHERE sr.sense_id = s.id
      )
      AND NOT EXISTS (
          SELECT 1
          FROM jsonb_array_elements_text(COALESCE(p_exclude, '[]'::jsonb)) AS ex(id)
          WHERE ex.id = s.id
      )
    ORDER BY s.id ASC
    LIMIT GREATEST(COALESCE(p_limit, 0), 0);
END;
$$;
