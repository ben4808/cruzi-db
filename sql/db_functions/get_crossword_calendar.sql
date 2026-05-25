CREATE OR REPLACE FUNCTION get_crossword_calendar(
    p_user_id TEXT,
    p_publication_id TEXT,
    p_month INT,
    p_year INT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (
        SELECT COALESCE(jsonb_agg(
            jsonb_build_object(
                'date', to_char(p.date, 'YYYY-MM-DD'),
                'hints_used', CASE
                    WHEN p_user_id IS NULL THEN 0
                    ELSE COALESCE(uc.hints_used, 0)
                END
            )
            ORDER BY p.date
        ), '[]'::jsonb)
        FROM puzzle p
        JOIN clue_collection cc ON cc.puzzle_id = p.id
        LEFT JOIN user__collection uc
            ON uc.collection_id = cc.id
            AND uc.user_id = p_user_id
        WHERE p.publication_id = p_publication_id
          AND EXTRACT(MONTH FROM p.date) = p_month
          AND EXTRACT(YEAR FROM p.date) = p_year
    );
END;
$$;
