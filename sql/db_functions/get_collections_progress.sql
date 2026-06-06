CREATE OR REPLACE FUNCTION get_collections_progress(
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
                'hints_used', uc.hints_used,
                'collection_completed', uc.collection_completed
            )
        ), '[]'::jsonb)
        FROM user__collection uc
        WHERE uc.user_id = p_user_id
          AND uc.collection_id IN (
              SELECT jsonb_array_elements_text(p_collection_ids)
          )
    );
END;
$$;
