-- Function to submit a user response to a clue
CREATE OR REPLACE FUNCTION submit_user_response(
    p_user_id text,
    p_response jsonb
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    _clue_id text;
    _is_correct boolean;
    _current_correct_solves integer;
    _current_incorrect_solves integer;
    _correct_solves_needed integer;
    _was_completed_before boolean;
    _default_solves_needed integer;
BEGIN
    _clue_id := p_response->>'clueId';
    _is_correct := (p_response->>'isCorrect')::boolean;
    _default_solves_needed := 2;

    SELECT
        COALESCE(uc.correct_solves, 0),
        COALESCE(uc.incorrect_solves, 0),
        COALESCE(uc.correct_solves_needed, _default_solves_needed),
        COALESCE(uc.correct_solves, 0) >= COALESCE(uc.correct_solves_needed, _default_solves_needed)
    INTO
        _current_correct_solves,
        _current_incorrect_solves,
        _correct_solves_needed,
        _was_completed_before
    FROM user__clue uc
    WHERE uc.user_id = p_user_id AND uc.clue_id = _clue_id;

    IF NOT FOUND THEN
        IF _is_correct THEN
            INSERT INTO user__clue (user_id, clue_id, correct_solves, incorrect_solves, correct_solves_needed, last_solve)
            VALUES (p_user_id, _clue_id, 1, 0, _default_solves_needed, CURRENT_DATE)
            ON CONFLICT (user_id, clue_id) DO NOTHING;
        ELSE
            INSERT INTO user__clue (user_id, clue_id, correct_solves, incorrect_solves, correct_solves_needed, last_solve)
            VALUES (p_user_id, _clue_id, 0, 1, 4, CURRENT_DATE)
            ON CONFLICT (user_id, clue_id) DO NOTHING;
        END IF;
    ELSE
        IF _is_correct THEN
            IF NOT _was_completed_before THEN
                UPDATE user__clue
                SET
                    correct_solves = _current_correct_solves + 1,
                    last_solve = CURRENT_DATE
                WHERE user_id = p_user_id AND clue_id = _clue_id;
            ELSE
                UPDATE user__clue
                SET last_solve = CURRENT_DATE
                WHERE user_id = p_user_id AND clue_id = _clue_id;
            END IF;
        ELSE
            UPDATE user__clue
            SET
                incorrect_solves = _current_incorrect_solves + 1,
                correct_solves_needed = _correct_solves_needed + 2,
                last_solve = CURRENT_DATE
            WHERE user_id = p_user_id AND clue_id = _clue_id;
        END IF;
    END IF;

    -- user__collection progress is maintained by sync_user_collection_progress trigger on user__clue.
END;
$$;
