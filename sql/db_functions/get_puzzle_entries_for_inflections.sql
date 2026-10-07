CREATE OR REPLACE FUNCTION get_puzzle_entries_for_inflections(p_puzzle_id text)
RETURNS TABLE (
    entry text,
    lang text,
    display_text text,
    reviewed_status text,
    secondary_displays jsonb
)
LANGUAGE plpgsql
AS $$
#variable_conflict use_column
BEGIN
    RETURN QUERY
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
        ), '[]'::jsonb) AS secondary_displays
    FROM clue_collection cc
    JOIN collection__clue ccl ON ccl.collection_id = cc.id
    JOIN clue c ON c.id = ccl.clue_id
    JOIN "entry" e ON e."entry" = c."entry" AND e.lang = c.lang
    WHERE cc.puzzle_id = p_puzzle_id
      AND COALESCE(e.loading_status, '') NOT LIKE 'I%'
    ORDER BY e."entry", e.lang;
END;
$$;
