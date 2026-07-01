CREATE OR REPLACE FUNCTION update_sense_familiarity_scores(scores_data jsonb)
RETURNS void AS $$
BEGIN
    UPDATE sense s
    SET familiarity_score = (elem->>'familiarity_score')::int
    FROM jsonb_array_elements(scores_data) AS elem
    WHERE s.id = elem->>'sense_id';
END;
$$ LANGUAGE plpgsql;
