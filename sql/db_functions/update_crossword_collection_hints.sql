-- Recompute and store total hints used for a crossword collection.
CREATE OR REPLACE FUNCTION update_crossword_collection_hints(
    p_user_id text,
    p_collection_id text
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    _total_hints integer;
BEGIN
    SELECT COALESCE(SUM(upc.hints_used), 0)::int
    INTO _total_hints
    FROM collection__clue ccl
    JOIN user__puzzle_clue upc
        ON upc.clue_id = ccl.clue_id
        AND upc.user_id = p_user_id
    WHERE ccl.collection_id = p_collection_id;

    IF NOT EXISTS (
        SELECT 1
        FROM user__collection
        WHERE user_id = p_user_id
          AND collection_id = p_collection_id
    ) THEN
        PERFORM initialize_user_collection_progress(p_user_id, p_collection_id);
    END IF;

    UPDATE user__collection
    SET hints_used = _total_hints
    WHERE user_id = p_user_id
      AND collection_id = p_collection_id;
END;
$$;
