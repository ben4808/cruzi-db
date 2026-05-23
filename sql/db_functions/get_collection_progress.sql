CREATE OR REPLACE FUNCTION get_collection_progress(
    p_user_id TEXT,
    p_collection_ids JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_collection_ids IS NULL OR jsonb_array_length(p_collection_ids) = 0 THEN
        RETURN '[]'::jsonb;
    END IF;

    RETURN (
        SELECT COALESCE(jsonb_agg(
            jsonb_build_object(
                'collection_id', uc.collection_id,
                'unseen', uc.unseen,
                'in_progress', uc.in_progress,
                'completed', uc.completed,
                'hints_used', COALESCE(h.hints_used, 0)
            )
        ), '[]'::jsonb)
        FROM user__collection uc
        LEFT JOIN (
            SELECT
                cc.collection_id,
                SUM(COALESCE(ucl.hints_used, 0))::int AS hints_used
            FROM collection__clue cc
            LEFT JOIN user__clue ucl
                ON cc.clue_id = ucl.clue_id
                AND ucl.user_id = p_user_id
            WHERE cc.collection_id IN (
                SELECT jsonb_array_elements_text(p_collection_ids)
            )
            GROUP BY cc.collection_id
        ) h ON h.collection_id = uc.collection_id
        WHERE uc.user_id = p_user_id
          AND uc.collection_id IN (
              SELECT jsonb_array_elements_text(p_collection_ids)
          )
    );
END;
$$;
