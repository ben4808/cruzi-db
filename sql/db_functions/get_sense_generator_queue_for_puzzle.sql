CREATE OR REPLACE FUNCTION get_sense_generator_queue_for_puzzle(
    p_puzzle_id text,
    p_limit integer,
    p_exclude jsonb DEFAULT '[]'::jsonb
)
RETURNS TABLE (
    queue_id integer,
    entry text,
    lang text,
    hint text,
    entry_display_text text,
    secondary_displays jsonb,
    existing_senses jsonb
)
LANGUAGE plpgsql
AS $$
#variable_conflict use_column
BEGIN
    RETURN QUERY
    SELECT
        q.id AS queue_id,
        q."entry" AS entry,
        q.lang AS lang,
        q.hint AS hint,
        e.display_text AS entry_display_text,
        COALESCE((
            SELECT jsonb_agg(esc.secondary_display ORDER BY esc.secondary_class)
            FROM entry_secondary_class esc
            WHERE esc."entry" = q."entry"
              AND esc.lang = q.lang
        ), '[]'::jsonb) AS secondary_displays,
        COALESCE((
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id', s.id,
                    'summary', COALESCE(s.summary, ''),
                    'display_text', COALESCE(s.display_text, '')
                )
                ORDER BY s.summary, s.id
            )
            FROM sense s
            WHERE s."entry" = q."entry"
              AND s.lang = q.lang
        ), '[]'::jsonb) AS existing_senses
    FROM sense_generator_queue q
    LEFT JOIN "entry" e ON e."entry" = q."entry" AND e.lang = q.lang
    WHERE q.puzzle_id = p_puzzle_id
      AND NOT EXISTS (
          SELECT 1
          FROM jsonb_array_elements_text(COALESCE(p_exclude, '[]'::jsonb)) AS ex(id)
          WHERE ex.id ~ '^[0-9]+$'
            AND ex.id::integer = q.id
      )
    ORDER BY q.added_at ASC, q.id ASC
    LIMIT GREATEST(COALESCE(p_limit, 0), 0);
END;
$$;
