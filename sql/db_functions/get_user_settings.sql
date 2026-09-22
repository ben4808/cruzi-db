CREATE OR REPLACE FUNCTION get_user_settings(
    p_user_id text
)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN COALESCE(
        (
            SELECT jsonb_build_object(
                'crossword_solver_minigame', us.crossword_solver_minigame
            )
            FROM user_settings us
            WHERE us.user_id = p_user_id
        ),
        jsonb_build_object(
            'crossword_solver_minigame', false
        )
    );
END;
$$;
