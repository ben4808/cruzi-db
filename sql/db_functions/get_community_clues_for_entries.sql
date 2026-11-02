DROP FUNCTION IF EXISTS get_community_clues_for_entries(jsonb, text);

CREATE OR REPLACE FUNCTION get_community_clues_for_entries(
    p_entries jsonb,
    p_lang text DEFAULT 'en'
)
RETURNS TABLE (
    entry text,
    clue text,
    times_used int
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH requested AS (
        SELECT DISTINCT upper(trim(
            CASE
                WHEN jsonb_typeof(elem) = 'string' THEN elem#>>'{}'
                ELSE COALESCE(elem->>'entry', '')
            END
        )) AS entry
        FROM jsonb_array_elements(p_entries) AS elem
        WHERE COALESCE(NULLIF(trim(
            CASE
                WHEN jsonb_typeof(elem) = 'string' THEN elem#>>'{}'
                ELSE COALESCE(elem->>'entry', '')
            END
        ), ''), '') <> ''
    )
    SELECT
        requested.entry,
        cc.clue,
        COALESCE(cc.times_used, 0) AS times_used
    FROM requested
    JOIN community_clue cc
      ON cc.lang = p_lang
     AND (
          cc."entry" = requested.entry
          OR normalize_display_text_to_entry_key(cc."entry") = requested.entry
     )
    WHERE COALESCE(trim(cc.clue), '') <> ''
    ORDER BY requested.entry, cc.times_used DESC, cc.id;
END;
$$;
