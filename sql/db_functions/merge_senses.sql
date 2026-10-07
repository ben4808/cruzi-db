-- p_merges: [{ "keep_id": text, "remove_id": text }]
-- Clues pointing at the removed sense are repointed to the kept sense, then the removed sense is deleted.
CREATE OR REPLACE FUNCTION merge_senses(p_merges jsonb)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_merges IS NULL OR jsonb_typeof(p_merges) <> 'array' OR jsonb_array_length(p_merges) = 0 THEN
        RETURN;
    END IF;

    UPDATE clue c
    SET sense_id = btrim(m->>'keep_id')
    FROM jsonb_array_elements(p_merges) AS m
    WHERE c.sense_id = btrim(m->>'remove_id')
      AND COALESCE(btrim(m->>'keep_id'), '') <> ''
      AND btrim(m->>'keep_id') <> btrim(m->>'remove_id');

    DELETE FROM sense s
    USING jsonb_array_elements(p_merges) AS m
    WHERE s.id = btrim(m->>'remove_id')
      AND COALESCE(btrim(m->>'keep_id'), '') <> ''
      AND btrim(m->>'keep_id') <> btrim(m->>'remove_id');
END;
$$;
