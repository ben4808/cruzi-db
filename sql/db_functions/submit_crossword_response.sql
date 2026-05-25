-- Submit a user's response to a crossword clue.
CREATE OR REPLACE FUNCTION submit_crossword_response(
    p_user_id text,
    p_response jsonb
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    _clue_id text;
    _collection_id text;
    _hints_used integer;
BEGIN
    _clue_id := p_response->>'clueId';
    _hints_used := COALESCE((p_response->>'hintsUsed')::integer, 0);

    SELECT cc.id
    INTO _collection_id
    FROM collection__clue ccl
    JOIN clue_collection cc ON cc.id = ccl.collection_id
    WHERE ccl.clue_id = _clue_id
      AND cc.puzzle_id IS NOT NULL
    LIMIT 1;

    IF _collection_id IS NULL THEN
        RAISE EXCEPTION 'Crossword clue not found: %', _clue_id;
    END IF;

    INSERT INTO user__puzzle_clue (user_id, clue_id, hints_used)
    VALUES (p_user_id, _clue_id, _hints_used)
    ON CONFLICT (user_id, clue_id) DO UPDATE
        SET hints_used = EXCLUDED.hints_used;
END;
$$;
