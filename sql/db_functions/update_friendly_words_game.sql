-- Persist lobby/game fields for a Friendly Words game.
CREATE OR REPLACE FUNCTION update_friendly_words_game(
    p_id text,
    p_title text,
    p_host_player_id text,
    p_status text,
    p_player1 text,
    p_player2 text,
    p_player3 text,
    p_player4 text,
    p_waitlist jsonb,
    p_state jsonb,
    p_completed_at timestamp DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    _row friendly_words_game%ROWTYPE;
BEGIN
    UPDATE friendly_words_game
    SET
        title = p_title,
        host_player_id = p_host_player_id,
        status = p_status,
        player1 = p_player1,
        player2 = p_player2,
        player3 = p_player3,
        player4 = p_player4,
        waitlist = p_waitlist,
        state = p_state,
        completed_at = p_completed_at,
        game_code = CASE
            WHEN p_status = 'completed' OR p_completed_at IS NOT NULL THEN NULL
            ELSE game_code
        END
    WHERE id = p_id
    RETURNING * INTO _row;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Game not found: %', p_id;
    END IF;

    RETURN jsonb_build_object(
        'id', _row.id,
        'game_code', _row.game_code,
        'title', _row.title,
        'host_player_id', _row.host_player_id,
        'status', _row.status,
        'lang', _row.lang,
        'created_at', _row.created_at,
        'completed_at', _row.completed_at,
        'player1', _row.player1,
        'player2', _row.player2,
        'player3', _row.player3,
        'player4', _row.player4,
        'waitlist', _row.waitlist,
        'state', _row.state
    );
END;
$$;
