-- Fetch a Friendly Words game by 4-digit join code (active games only).
CREATE OR REPLACE FUNCTION get_friendly_words_game_by_code(p_game_code text)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (
        SELECT jsonb_build_object(
            'id', g.id,
            'game_code', g.game_code,
            'title', g.title,
            'host_player_id', g.host_player_id,
            'status', g.status,
            'lang', g.lang,
            'created_at', g.created_at,
            'completed_at', g.completed_at,
            'player1', g.player1,
            'player2', g.player2,
            'player3', g.player3,
            'player4', g.player4,
            'waitlist', g.waitlist,
            'state', g.state,
            'turns', '[]'::jsonb,
            'played_words', '[]'::jsonb
        )
        FROM friendly_words_game g
        WHERE g.game_code = p_game_code
          AND g.completed_at IS NULL
        ORDER BY g.created_at DESC
        LIMIT 1
    );
END;
$$;
