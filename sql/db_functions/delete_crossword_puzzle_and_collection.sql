CREATE OR REPLACE FUNCTION delete_crossword_puzzle_and_collection (
    p_publication_id text,
    p_date date
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_puzzle_ids text[];
    v_collection_ids text[];
BEGIN
    -- Puzzle and clue_collection rows for this publication/date. Entry rows are left intact.
    SELECT COALESCE(array_agg(id), ARRAY[]::text[])
    INTO v_puzzle_ids
    FROM puzzle
    WHERE publication_id = p_publication_id
      AND "date" = p_date;

    SELECT COALESCE(array_agg(id), ARRAY[]::text[])
    INTO v_collection_ids
    FROM clue_collection
    WHERE puzzle_id = ANY(v_puzzle_ids)
       OR (
            "source" = p_publication_id
            AND metadata1 = to_char(p_date, 'YYYY-MM-DD')
       );

    DELETE FROM clue c
    WHERE c.id IN (
        SELECT cc.clue_id
        FROM collection__clue cc
        WHERE cc.collection_id = ANY(v_collection_ids)
    )
    AND NOT EXISTS (
        SELECT 1
        FROM collection__clue other
        WHERE other.clue_id = c.id
          AND NOT (other.collection_id = ANY(v_collection_ids))
    );

    DELETE FROM clue_collection
    WHERE id = ANY(v_collection_ids);

    DELETE FROM puzzle
    WHERE id = ANY(v_puzzle_ids);
END;
$$;
