CREATE OR REPLACE FUNCTION get_puzzle_entries_for_sense_generation(
    p_puzzle_id text,
    p_base_forms boolean
)
RETURNS TABLE (
    entry text,
    lang text,
    display_text text,
    reviewed_status text,
    secondary_displays jsonb,
    hint text,
    existing_senses jsonb
)
LANGUAGE plpgsql
AS $$
#variable_conflict use_column
BEGIN
    RETURN QUERY
    WITH puzzle_clues AS (
        SELECT c."entry" AS clue_entry, c.lang AS clue_lang, c.custom_clue, ccl."order" AS clue_order
        FROM clue_collection cc
        JOIN collection__clue ccl ON ccl.collection_id = cc.id
        JOIN clue c ON c.id = ccl.clue_id
        WHERE cc.puzzle_id = p_puzzle_id
    ),
    targets AS (
        SELECT pc.clue_entry AS target_entry, pc.clue_lang AS target_lang, pc.custom_clue, pc.clue_order
        FROM puzzle_clues pc
        WHERE NOT p_base_forms
        UNION ALL
        SELECT ie.base_entry, ie.lang, pc.custom_clue, pc.clue_order
        FROM puzzle_clues pc
        JOIN inflected_entry ie ON ie.inflected_entry = pc.clue_entry AND ie.lang = pc.clue_lang
        WHERE p_base_forms
    )
    SELECT DISTINCT ON (e."entry", e.lang)
        e."entry" AS entry,
        e.lang AS lang,
        e.display_text AS display_text,
        e.reviewed_status AS reviewed_status,
        COALESCE((
            SELECT jsonb_agg(esc.secondary_display ORDER BY esc.secondary_class)
            FROM entry_secondary_class esc
            WHERE esc."entry" = e."entry"
              AND esc.lang = e.lang
              AND NULLIF(btrim(esc.secondary_display), '') IS NOT NULL
        ), '[]'::jsonb) AS secondary_displays,
        NULLIF(btrim(t.custom_clue), '') AS hint,
        COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id', s.id,
                    'entry', s."entry",
                    'summary', COALESCE(s.summary, ''),
                    'display_text', COALESCE(s.display_text, '')
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
        ), '[]'::jsonb) AS existing_senses
    FROM targets t
    JOIN "entry" e ON e."entry" = t.target_entry AND e.lang = t.target_lang
    WHERE NOT EXISTS (
        SELECT 1
        FROM sense s
        WHERE s."entry" = e."entry"
          AND s.lang = e.lang
    )
    ORDER BY e."entry", e.lang, t.clue_order;
END;
$$;
