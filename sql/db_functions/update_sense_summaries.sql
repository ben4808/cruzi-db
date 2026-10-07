-- p_updates: [{ "sense_id": text, "summary": text }]
CREATE OR REPLACE FUNCTION update_sense_summaries(p_updates jsonb)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_updates IS NULL OR jsonb_typeof(p_updates) <> 'array' OR jsonb_array_length(p_updates) = 0 THEN
        RETURN;
    END IF;

    UPDATE sense s
    SET summary = btrim(u->>'summary')
    FROM jsonb_array_elements(p_updates) AS u
    WHERE s.id = btrim(u->>'sense_id')
      AND COALESCE(btrim(u->>'summary'), '') <> '';
END;
$$;
