CREATE OR REPLACE FUNCTION get_crossword(
    p_collection_id TEXT,
    p_user_id TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (
        SELECT jsonb_build_object(
            'id', cc.id,
            'title', cc.title,
            'lang', cc.lang,
            'author', cc.author,
            'description', cc.description,
            'is_private', cc.is_private,
            'created_date', cc.created_date,
            'modified_date', cc.modified_date,
            'source', cc.source,
            'metadata1', cc.metadata1,
            'metadata2', cc.metadata2,
            'clue_count', cc.clue_count,
            'clue_count_6_plus', cc.clue_count_6_plus,
            'puzzle', CASE
                WHEN p.id IS NOT NULL THEN jsonb_build_object(
                    'id', p.id,
                    'title', p.title,
                    'publication_id', pub.id,
                    'date', p.date,
                    'width', p.width,
                    'height', p.height,
                    'author', p.author,
                    'copyright', p.copyright,
                    'notes', p.notes,
                    'lang', p.lang,
                    'source_link', p.source_link
                )
                ELSE NULL
            END,
            'creator', CASE
                WHEN u.id IS NOT NULL THEN jsonb_build_object(
                    'creator_id', u.id,
                    'creator_first_name', u.first_name,
                    'creator_last_name', u.last_name
                )
                ELSE NULL
            END,
            'user_progress', CASE
                WHEN p_user_id IS NOT NULL AND uc.user_id IS NOT NULL THEN jsonb_build_object(
                    'unseen', uc.unseen,
                    'in_progress', uc.in_progress,
                    'completed', uc.completed,
                    'hints_used', COALESCE(uc.hints_used, 0),
                    'collection_completed', uc.collection_completed
                )
                ELSE NULL
            END,
            'clues', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'order', ccl."order",
                        'metadata1', ccl.metadata1,
                        'metadata2', ccl.metadata2,
                        'clue', jsonb_build_object(
                            'id', c.id,
                            'entry', c.entry,
                            'lang', c.lang,
                            'display_text', e.display_text,
                            'loading_status', e.loading_status,
                            'base_form', e.base_form,
                            'entry_type', e.entry_type,
                            'familiarity_score', e.familiarity_score,
                            'quality_score', e.quality_score,
                            'custom_clue', c.custom_clue,
                            'custom_display_text', c.custom_display_text,
                            'sense', NULL,
                            'user_progress', CASE
                                WHEN p_user_id IS NOT NULL AND upc.user_id IS NOT NULL THEN jsonb_build_object(
                                    'hints_used', upc.hints_used
                                )
                                ELSE NULL
                            END
                        )
                    )
                    ORDER BY ccl."order" ASC
                )
                FROM collection__clue ccl
                JOIN clue c ON ccl.clue_id = c.id
                LEFT JOIN entry e ON c.entry = e.entry AND c.lang = e.lang
                LEFT JOIN user__puzzle_clue upc ON c.id = upc.clue_id AND upc.user_id = p_user_id
                WHERE ccl.collection_id = cc.id
            ), '[]'::jsonb)
        )
        FROM clue_collection cc
        LEFT JOIN puzzle p ON cc.puzzle_id = p.id
        LEFT JOIN publication pub ON p.publication_id = pub.id
        LEFT JOIN "user" u ON cc.creator_id = u.id
        LEFT JOIN user__collection uc ON cc.id = uc.collection_id AND uc.user_id = p_user_id
        LEFT JOIN collection_access ca ON cc.id = ca.collection_id AND ca.user_id = p_user_id
        WHERE cc.id = p_collection_id
          AND cc.puzzle_id IS NOT NULL
          AND (
              (p_user_id IS NULL AND cc.is_private = FALSE)
              OR (
                  p_user_id IS NOT NULL
                  AND (
                      cc.is_private = FALSE
                      OR cc.creator_id = p_user_id
                      OR ca.user_id IS NOT NULL
                  )
              )
          )
    );
END;
$$;
