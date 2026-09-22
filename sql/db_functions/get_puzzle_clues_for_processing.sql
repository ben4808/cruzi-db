CREATE OR REPLACE FUNCTION get_puzzle_clues_for_processing(p_puzzle_id text)
RETURNS TABLE (
    clue_id text,
    entry text,
    lang text,
    custom_clue text,
    sense_id text,
    match_attempted boolean,
    display_text text,
    entry_exists boolean,
    clue_order integer,
    senses jsonb
)
LANGUAGE plpgsql
AS $$
#variable_conflict use_column
BEGIN
    RETURN QUERY
    SELECT DISTINCT ON (c.id)
        c.id AS clue_id,
        c."entry" AS entry,
        c.lang AS lang,
        c.custom_clue AS custom_clue,
        c.sense_id AS sense_id,
        c.match_attempted AS match_attempted,
        e.display_text AS display_text,
        (e."entry" IS NOT NULL) AS entry_exists,
        ccl."order" AS clue_order,
        COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id', s.id,
                    'entry', s."entry",
                    'lang', s.lang,
                    'summary', COALESCE(s.summary, ''),
                    'display_text', COALESCE(s.display_text, ''),
                    'classification', COALESCE(s.classification, ''),
                    'part_of_speech', COALESCE(s.part_of_speech, ''),
                    'reviewed_status', s.reviewed_status,
                    'has_references', EXISTS (
                        SELECT 1
                        FROM sense_reference sr
                        WHERE sr.sense_id = s.id
                    )
                )
                ORDER BY s."entry", s.summary, s.id
            )
            FROM sense s
            WHERE s.lang = c.lang
              AND (
                    s."entry" = c."entry"
                    OR s."entry" IN (
                        SELECT ie.base_entry
                        FROM inflected_entry ie
                        WHERE ie.inflected_entry = c."entry"
                          AND ie.lang = c.lang
                    )
              )
        ), '[]'::jsonb) AS senses
    FROM clue_collection cc
    JOIN collection__clue ccl ON ccl.collection_id = cc.id
    JOIN clue c ON c.id = ccl.clue_id
    LEFT JOIN "entry" e ON e."entry" = c."entry" AND e.lang = c.lang
    WHERE cc.puzzle_id = p_puzzle_id
    ORDER BY c.id, ccl."order";
END;
$$;
