CREATE OR REPLACE FUNCTION get_entry_info_queue_top_1()
RETURNS TABLE (
    entry text,
    display_text text,
    lang text,
    existing_sense_ids text[],
    existing_sense_summaries text[],
    example_sentence_count integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH top_entry AS (
        SELECT eiq.entry, eiq.lang, e.display_text
        FROM entry_info_queue eiq
        LEFT JOIN entry e ON e.entry = eiq.entry AND e.lang = eiq.lang
        ORDER BY eiq.added_at ASC
        LIMIT 1
    ),
    sense_data AS (
        SELECT
            te.entry,
            te.display_text,
            te.lang,
            s.id AS sense_id,
            s.summary AS sense_summary,
            COALESCE(es_count.count, 0) AS sense_example_count
        FROM top_entry te
        LEFT JOIN sense s ON s.entry = te.entry AND s.lang = te.lang
        LEFT JOIN (
            SELECT sense_id, COUNT(*) AS count
            FROM example_sentence
            GROUP BY sense_id
        ) es_count ON es_count.sense_id = s.id
    )
    SELECT
        sd.entry,
        sd.display_text,
        sd.lang,
        COALESCE(
            array_agg(sd.sense_id::text ORDER BY sd.sense_id)
                FILTER (WHERE sd.sense_id IS NOT NULL),
            ARRAY[]::text[]
        ) AS existing_sense_ids,
        COALESCE(
            array_agg(sd.sense_summary ORDER BY sd.sense_id)
                FILTER (WHERE sd.sense_summary IS NOT NULL),
            ARRAY[]::text[]
        ) AS existing_sense_summaries,
        COALESCE(SUM(sd.sense_example_count), 0)::integer AS example_sentence_count
    FROM sense_data sd
    GROUP BY sd.entry, sd.display_text, sd.lang;
END;
$$;
