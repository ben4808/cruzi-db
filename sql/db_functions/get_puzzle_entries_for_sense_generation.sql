-- Puzzle entries that have at least one clue still waiting on a sense match (match_attempted = false).
DROP FUNCTION IF EXISTS get_puzzle_entries_for_sense_generation(text);

CREATE OR REPLACE FUNCTION get_puzzle_entries_for_sense_generation(
    p_puzzle_id text
)
RETURNS TABLE (
    entry text,
    lang text,
    display_text text,
    secondary_displays jsonb,
    hints jsonb,
    existing_senses jsonb,
    base_entries jsonb,
    base_displays jsonb
)
LANGUAGE plpgsql
AS $$
#variable_conflict use_column
BEGIN
    RETURN QUERY
    WITH pending_clues AS (
        SELECT c."entry" AS clue_entry, c.lang AS clue_lang, c.custom_clue, ccl."order" AS clue_order
        FROM clue_collection cc
        JOIN collection__clue ccl ON ccl.collection_id = cc.id
        JOIN clue c ON c.id = ccl.clue_id
        WHERE cc.puzzle_id = p_puzzle_id
          AND NOT c.match_attempted
    ),
    targets AS (
        SELECT
            pc.clue_entry AS target_entry,
            pc.clue_lang AS target_lang,
            MIN(pc.clue_order) AS first_order,
            COALESCE(
                jsonb_agg(DISTINCT btrim(pc.custom_clue))
                    FILTER (WHERE NULLIF(btrim(pc.custom_clue), '') IS NOT NULL),
                '[]'::jsonb
            ) AS hints
        FROM pending_clues pc
        GROUP BY pc.clue_entry, pc.clue_lang
    )
    SELECT
        e."entry" AS entry,
        e.lang AS lang,
        e.display_text AS display_text,
        COALESCE((
            SELECT jsonb_agg(esc.secondary_display ORDER BY esc.secondary_class)
            FROM entry_secondary_class esc
            WHERE esc."entry" = e."entry"
              AND esc.lang = e.lang
              AND NULLIF(btrim(esc.secondary_display), '') IS NOT NULL
        ), '[]'::jsonb) AS secondary_displays,
        t.hints AS hints,
        COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id', s.id,
                    'entry', s."entry",
                    'summary', COALESCE(s.summary, ''),
                    'display_text', COALESCE(s.display_text, ''),
                    'part_of_speech', COALESCE(s.part_of_speech, ''),
                    'reviewed_status', s.reviewed_status
                )
                ORDER BY (s."entry" = e."entry"), s."entry", s.summary, s.id
            )
            FROM sense s
            WHERE s.lang = e.lang
              AND (
                    s."entry" = e."entry"
                    OR s."entry" IN (
                        SELECT ie.base_entry
                        FROM inflected_entry ie
                        WHERE ie.inflected_entry = e."entry"
                          AND ie.lang = e.lang
                    )
              )
        ), '[]'::jsonb) AS existing_senses,
        COALESCE((
            SELECT jsonb_agg(DISTINCT ie.base_entry)
            FROM inflected_entry ie
            WHERE ie.inflected_entry = e."entry"
              AND ie.lang = e.lang
        ), '[]'::jsonb) AS base_entries,
        COALESCE((
            SELECT jsonb_agg(DISTINCT COALESCE(NULLIF(btrim(be.display_text), ''), ie.base_entry))
            FROM inflected_entry ie
            LEFT JOIN "entry" be ON be."entry" = ie.base_entry AND be.lang = ie.lang
            WHERE ie.inflected_entry = e."entry"
              AND ie.lang = e.lang
        ), '[]'::jsonb) AS base_displays
    FROM targets t
    JOIN "entry" e ON e."entry" = t.target_entry AND e.lang = t.target_lang
    ORDER BY t.first_order, e."entry", e.lang;
END;
$$;
