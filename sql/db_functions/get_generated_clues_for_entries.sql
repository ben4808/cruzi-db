DROP FUNCTION IF EXISTS get_generated_clues_for_entries(jsonb, text);

CREATE OR REPLACE FUNCTION get_generated_clues_for_entries(
    p_entries jsonb,
    p_lang text DEFAULT 'en'
)
RETURNS TABLE (
    entry text,
    display_text text,
    clues_generated boolean,
    generated_clue text,
    clue_type text,
    is_seedword boolean
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH requested AS (
        SELECT DISTINCT upper(trim(
            CASE
                WHEN jsonb_typeof(elem) = 'string' THEN elem#>>'{}'
                ELSE COALESCE(elem->>'entry', elem->>'fill_word', elem->>'fillWord', '')
            END
        )) AS entry
        FROM jsonb_array_elements(p_entries) AS elem
        WHERE COALESCE(NULLIF(trim(
            CASE
                WHEN jsonb_typeof(elem) = 'string' THEN elem#>>'{}'
                ELSE COALESCE(elem->>'entry', elem->>'fill_word', elem->>'fillWord', '')
            END
        ), ''), '') <> ''
    ),
    matched AS (
        SELECT DISTINCT ON (requested.entry)
            requested.entry AS requested_entry,
            e."entry" AS db_entry,
            e.display_text,
            COALESCE(e.clues_generated, false) AS clues_generated
        FROM requested
        LEFT JOIN "entry" e
          ON e.lang = p_lang
         AND (
              e."entry" = requested.entry
              OR normalize_display_text_to_entry_key(e."entry") = requested.entry
         )
        ORDER BY
            requested.entry,
            (e."entry" IS NOT NULL) DESC,
            e."entry"
    )
    SELECT
        matched.requested_entry,
        matched.display_text,
        matched.clues_generated,
        gc.generated_clue,
        gc.clue_type,
        gc.is_seedword
    FROM matched
    LEFT JOIN generated_clue gc
      ON gc.lang = p_lang
     AND (
          gc."entry" = matched.requested_entry
          OR (matched.db_entry IS NOT NULL AND gc."entry" = matched.db_entry)
     );
END;
$$;
