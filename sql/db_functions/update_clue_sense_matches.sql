CREATE OR REPLACE FUNCTION update_clue_sense_matches(p_updates jsonb)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_updates IS NULL OR jsonb_typeof(p_updates) <> 'array' OR jsonb_array_length(p_updates) = 0 THEN
        RETURN;
    END IF;

    UPDATE clue c
    SET
        sense_id = CASE
            WHEN elem ? 'sense_id' THEN NULLIF(btrim(elem->>'sense_id'), '')
            ELSE c.sense_id
        END,
        match_attempted = CASE
            WHEN elem ? 'match_attempted' THEN COALESCE((elem->>'match_attempted')::boolean, c.match_attempted)
            ELSE c.match_attempted
        END
    FROM jsonb_array_elements(p_updates) AS elem
    WHERE c.id = elem->>'clue_id';
END;
$$;
