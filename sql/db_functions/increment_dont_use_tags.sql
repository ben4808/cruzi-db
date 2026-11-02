CREATE OR REPLACE FUNCTION increment_dont_use_tags(
    p_entries jsonb,
    p_lang text DEFAULT 'en'
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_count integer;
BEGIN
    -- First selection inserts dont_use = '1'. Later selections add 1 to the stored count.
    -- Entries that are not in "entry" are skipped so one missing word does not fail the batch.
    INSERT INTO entry_tags ("entry", lang, tag, "value")
    SELECT
        e."entry",
        e.lang,
        'dont_use',
        '1'
    FROM (
        SELECT DISTINCT upper(trim(elem)) AS entry
        FROM jsonb_array_elements_text(p_entries) AS elem
        WHERE COALESCE(trim(elem), '') <> ''
    ) s
    JOIN "entry" e
      ON e."entry" = s.entry
     AND e.lang = COALESCE(NULLIF(trim(p_lang), ''), 'en')
    ON CONFLICT ("entry", lang, tag) DO UPDATE SET
        "value" = (
            CASE
                WHEN COALESCE(entry_tags."value", '') ~ '^[0-9]+$'
                THEN entry_tags."value"::integer
                ELSE 0
            END + 1
        )::text;

    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$;
