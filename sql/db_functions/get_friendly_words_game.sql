-- Fetch a Friendly Words game by id, including turns and played words.
CREATE OR REPLACE FUNCTION get_friendly_words_game(p_id text)
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
            'created_at', g.created_at,
            'completed_at', g.completed_at,
            'player1', g.player1,
            'player2', g.player2,
            'player3', g.player3,
            'player4', g.player4,
            'waitlist', g.waitlist,
            'state', g.state,
            'turns', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'id', t.id,
                        'game_id', t.game_id,
                        'player', t.player,
                        'turn_number', t.turn_number,
                        'rack', t.rack,
                        'action', t.action,
                        'gross_score', t.gross_score,
                        'total_multiplier', t.total_multiplier,
                        'net_score', t.net_score,
                        'start_score', t.start_score,
                        'end_score', t.end_score
                    )
                    ORDER BY t.turn_number
                )
                FROM friendly_words_turn t
                WHERE t.game_id = g.id
            ), '[]'::jsonb),
            'played_words', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'id', w.id,
                        'turn_id', w.turn_id,
                        'entry', w.entry,
                        'lang', w.lang,
                        'gross_score', w.gross_score,
                        'multiplier', w.multiplier
                    )
                )
                FROM friendly_words_played_word w
                INNER JOIN friendly_words_turn t ON t.id = w.turn_id
                WHERE t.game_id = g.id
            ), '[]'::jsonb)
        )
        FROM friendly_words_game g
        WHERE g.id = p_id
    );
END;
$$;
