-- Mark a Friendly Words game as completed. Join codes stay until reused by a new game.
CREATE OR REPLACE FUNCTION complete_friendly_words_game(p_id text)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE friendly_words_game
    SET status = 'completed', completed_at = now()
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Game not found: %', p_id;
    END IF;
END;
$$;
