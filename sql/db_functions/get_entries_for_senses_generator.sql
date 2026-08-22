DROP FUNCTION IF EXISTS get_entries_for_senses_generator(integer);
DROP FUNCTION IF EXISTS get_entries_for_senses_generator(jsonb, text, integer);
DROP FUNCTION IF EXISTS get_entries_for_senses_generator(text, integer, integer, boolean, jsonb);

CREATE OR REPLACE FUNCTION get_entries_for_senses_generator(
    p_lang text,
    p_length integer,
    p_limit integer,
    p_existing_only boolean DEFAULT false,
    p_combos jsonb DEFAULT '[]'::jsonb
)
RETURNS TABLE (
    entry text,
    lang text,
    display_text text,
    existing_senses jsonb
)
LANGUAGE plpgsql
AS $$
#variable_conflict use_column
BEGIN
    IF p_existing_only THEN
        RETURN QUERY
        SELECT
            e."entry",
            e."lang",
            COALESCE(NULLIF(TRIM(e.display_text), ''), e."entry"),
            COALESCE(
                (
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'id', s.id,
                            'summary', s.summary
                        )
                        ORDER BY s.id
                    )
                    FROM sense s
                    WHERE s."entry" = e."entry"
                      AND s."lang" = e."lang"
                ),
                '[]'::jsonb
            )
        FROM "entry" e
        WHERE e."lang" = p_lang
          AND e."length" = p_length
          AND COALESCE(e.loading_status, 'Ready') <> 'Senses'
        ORDER BY e."entry"
        LIMIT p_limit;
        RETURN;
    END IF;

    WITH ordered AS (
        SELECT t.combo, t.ord
        FROM jsonb_array_elements_text(p_combos) WITH ORDINALITY AS t(combo, ord)
    ),
    candidates AS (
        SELECT o.combo
        FROM ordered o
        LEFT JOIN "entry" e
          ON e."entry" = o.combo
         AND e."lang" = p_lang
        WHERE COALESCE(e.loading_status, 'Ready') <> 'Senses'
        ORDER BY o.ord
        LIMIT p_limit
    )
    INSERT INTO "entry" ("entry", "lang", "length", display_text)
    SELECT c.combo, p_lang, p_length, c.combo
    FROM candidates c
    ON CONFLICT ("entry", "lang") DO NOTHING;

    RETURN QUERY
    WITH ordered AS (
        SELECT t.combo, t.ord
        FROM jsonb_array_elements_text(p_combos) WITH ORDINALITY AS t(combo, ord)
    )
    SELECT
        e."entry",
        e."lang",
        COALESCE(NULLIF(TRIM(e.display_text), ''), e."entry"),
        COALESCE(
            (
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'id', s.id,
                        'summary', s.summary
                    )
                    ORDER BY s.id
                )
                FROM sense s
                WHERE s."entry" = e."entry"
                  AND s."lang" = e."lang"
            ),
            '[]'::jsonb
        )
    FROM ordered o
    JOIN "entry" e
      ON e."entry" = o.combo
     AND e."lang" = p_lang
    WHERE COALESCE(e.loading_status, 'Ready') <> 'Senses'
    ORDER BY o.ord
    LIMIT p_limit;
END;
$$;
