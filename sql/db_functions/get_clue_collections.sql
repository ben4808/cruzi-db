CREATE OR REPLACE FUNCTION get_clue_collections(
    p_user_id TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (
        SELECT jsonb_agg(
            jsonb_build_object(
                'id', c.id,
                'title', c.title,
                'lang', c.lang,
                'author', c.author,
                'description', c.description,
                'is_private', c.is_private,
                'created_date', c.created_date,
                'modified_date', c.modified_date,
                'last_accessed', COALESCE(
                    (SELECT MAX(uc2.last_solve)::timestamp
                     FROM collection__clue cc2
                     JOIN user__clue uc2 ON uc2.clue_id = cc2.clue_id AND uc2.user_id = p_user_id
                     WHERE cc2.collection_id = c.id AND uc2.last_solve IS NOT NULL),
                    c.modified_date
                ),
                'metadata1', c.metadata1,
                'metadata2', c.metadata2,
                'clue_count', c.clue_count,
                'creator', CASE WHEN u.id IS NOT NULL
                                THEN jsonb_build_object(
                                    'creator_id', u.id,
                                    'creator_first_name', u.first_name,
                                    'creator_last_name', u.last_name
                                )
                                ELSE NULL
                          END,
                'user_progress', CASE WHEN p_user_id IS NOT NULL AND uc.user_id IS NOT NULL THEN
                        jsonb_build_object(
                            'unseen', uc.unseen,
                            'in_progress', uc.in_progress,
                            'completed', uc.completed,
                            'collection_completed', uc.collection_completed
                        )
                    ELSE
                        NULL
                END
            )
        )
        FROM clue_collection c
        LEFT JOIN "user" u ON c.creator_id = u.id
        LEFT JOIN user__collection uc ON c.id = uc.collection_id AND uc.user_id = p_user_id
        LEFT JOIN collection_access ca ON c.id = ca.collection_id AND ca.user_id = p_user_id
        WHERE c.puzzle_id IS NULL
          AND ((p_user_id IS NULL AND c.is_private = FALSE)
           OR (p_user_id IS NOT NULL AND (c.is_private = FALSE OR c.creator_id = p_user_id OR ca.user_id IS NOT NULL)))
    );
END;
$$;
