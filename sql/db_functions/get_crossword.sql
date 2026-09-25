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
                            'base_form', inflected_base_form_for_entry(c.entry, c.lang),
                            'entry_type', e.entry_type,
                            'familiarity_score', e.familiarity_score,
                            'familiarity_bucket', e.familiarity_bucket,
                            'quality_score', e.quality_score,
                            'quality_bucket', e.quality_bucket,
                            'unity_bucket', e.unity_bucket,
                            'tags', COALESCE((
                                SELECT jsonb_object_agg(et.tag, COALESCE(et.value, ''))
                                FROM entry_tags et
                                WHERE et."entry" = e."entry" AND et.lang = e.lang
                            ), '{}'::jsonb),
                            'custom_clue', c.custom_clue,
                            'custom_display_text', c.custom_display_text,
                            'sense', CASE
                                WHEN s.id IS NULL THEN NULL
                                ELSE jsonb_build_object(
                                    'id', s.id,
                                    'entry', s.entry,
                                    'lang', s.lang,
                                    'display_text', s.display_text,
                                    'summary', s.summary,
                                    'definition', s.definition,
                                    'part_of_speech', s.part_of_speech,
                                    'classification', s.classification,
                                    'unity_bucket', s.unity_bucket,
                                    'familiarity_bucket', s.familiarity_bucket,
                                    'quality_bucket', s.quality_bucket,
                                    'domain', s.domain,
                                    'similar_entries', to_jsonb(COALESCE(s.similar_entries, ARRAY[]::text[])),
                                    'entry_display_text', se.display_text,
                                    'tags', COALESCE((
                                        SELECT jsonb_object_agg(st.tag, COALESCE(st.value, ''))
                                        FROM sense_tags st
                                        WHERE st.sense_id = s.id
                                    ), '{}'::jsonb),
                                    'references', COALESCE((
                                        SELECT jsonb_agg(
                                            jsonb_build_object(
                                                'id', sr.id,
                                                'sense_id', sr.sense_id,
                                                'reference_type', sr.reference_type,
                                                'reference_text', sr.reference_text,
                                                'reference_source', sr.reference_source,
                                                'reference_url', sr.reference_url
                                            )
                                            ORDER BY sr.reference_type, sr.reference_text
                                        )
                                        FROM sense_reference sr
                                        WHERE sr.sense_id = s.id
                                    ), '[]'::jsonb),
                                    'translations', COALESCE((
                                        SELECT jsonb_object_agg(
                                            trans.translation_lang,
                                            jsonb_build_object(
                                                'natural_translations', COALESCE(to_jsonb(trans.natural_translations), '[]'::jsonb),
                                                'colloquial_translations', COALESCE(to_jsonb(trans.colloquial_translations), '[]'::jsonb)
                                            )
                                        )
                                        FROM (
                                            SELECT DISTINCT ON (set_row.translation_lang)
                                                set_row.translation_lang,
                                                set_row.natural_translations,
                                                set_row.colloquial_translations
                                            FROM sense_entry_translation set_row
                                            WHERE set_row.sense_id = s.id
                                            ORDER BY set_row.translation_lang, (set_row."entry" = s.entry) DESC, set_row."entry"
                                        ) trans
                                    ), '{}'::jsonb)
                                )
                            END,
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
                LEFT JOIN sense s ON c.sense_id = s.id
                LEFT JOIN entry se ON s.entry = se.entry AND s.lang = se.lang
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
