CREATE OR REPLACE FUNCTION get_sense_scoring_queue_for_puzzle(
    p_puzzle_id text,
    p_limit integer,
    p_exclude jsonb DEFAULT '[]'::jsonb
)
RETURNS TABLE (
    queue_id integer,
    sense_id text,
    entry text,
    lang text,
    display_text text,
    summary text,
    classification text,
    part_of_speech text,
    unity_bucket text,
    familiarity_bucket text,
    quality_bucket text,
    reviewed_status text
)
LANGUAGE plpgsql
AS $$
#variable_conflict use_column
BEGIN
    RETURN QUERY
    SELECT
        q.id AS queue_id,
        s.id AS sense_id,
        s."entry" AS entry,
        s.lang AS lang,
        COALESCE(NULLIF(btrim(s.display_text), ''), NULLIF(btrim(e.display_text), '')) AS display_text,
        s.summary AS summary,
        s.classification AS classification,
        s.part_of_speech AS part_of_speech,
        s.unity_bucket AS unity_bucket,
        s.familiarity_bucket AS familiarity_bucket,
        s.quality_bucket AS quality_bucket,
        s.reviewed_status AS reviewed_status
    FROM sense_scoring_queue q
    JOIN sense s ON s.id = q.sense_id
    LEFT JOIN "entry" e ON e."entry" = s."entry" AND e.lang = s.lang
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
