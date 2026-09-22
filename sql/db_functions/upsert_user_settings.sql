CREATE OR REPLACE FUNCTION upsert_user_settings(
    p_user_id text,
    p_crossword_solver_minigame boolean
)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
    result jsonb;
BEGIN
    INSERT INTO user_settings (user_id, crossword_solver_minigame)
    VALUES (p_user_id, p_crossword_solver_minigame)
    ON CONFLICT (user_id) DO UPDATE
        SET crossword_solver_minigame = EXCLUDED.crossword_solver_minigame
    RETURNING jsonb_build_object(
        'crossword_solver_minigame', crossword_solver_minigame
    ) INTO result;

    RETURN result;
END;
$$;
