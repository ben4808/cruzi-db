-- Create a new Friendly Words game row.
CREATE OR REPLACE FUNCTION create_friendly_words_game(
    p_id text,
    p_game_code text,
    p_title text,
    p_host_player_id text,
    p_player1 text,
    p_state jsonb,
    p_lang text DEFAULT 'en'
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    _row friendly_words_game%ROWTYPE;
BEGIN
    IF EXISTS (SELECT 1 FROM friendly_words_game WHERE game_code = p_game_code AND completed_at IS NULL) THEN
        RAISE EXCEPTION 'Game code already in use: %', p_game_code;
    END IF;

    INSERT INTO friendly_words_game (
        id, game_code, title, host_player_id, status, lang, player1, waitlist, state
    )
    VALUES (
        p_id, p_game_code, p_title, p_host_player_id, 'lobby', COALESCE(NULLIF(p_lang, ''), 'en'),
        p_player1, '[]'::jsonb, p_state
    )
    RETURNING * INTO _row;

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
