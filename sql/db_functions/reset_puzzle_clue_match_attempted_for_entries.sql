CREATE OR REPLACE FUNCTION reset_puzzle_clue_match_attempted_for_entries(
    p_puzzle_id text,
    p_entries jsonb
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_puzzle_id IS NULL
       OR p_entries IS NULL
       OR jsonb_typeof(p_entries) <> 'array'
       OR jsonb_array_length(p_entries) = 0 THEN
        RETURN;
    END IF;

    UPDATE clue c
    SET match_attempted = false
    FROM clue_collection cc
    JOIN collection__clue ccl ON ccl.collection_id = cc.id
    CROSS JOIN jsonb_array_elements(p_entries) AS elem
    WHERE cc.puzzle_id = p_puzzle_id
      AND c.id = ccl.clue_id
      AND btrim(elem->>'entry') = c."entry"
      AND btrim(elem->>'lang') = c.lang
      AND COALESCE(btrim(elem->>'entry'), '') <> ''
      AND COALESCE(btrim(elem->>'lang'), '') <> '';
END;
$$;
