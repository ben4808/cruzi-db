CREATE OR REPLACE FUNCTION get_crossword_collection_id(
  p_publication_id text,
  p_date date
)
RETURNS jsonb AS $$
DECLARE
    v_puzzle_id text;
    v_collection_id text;
BEGIN
    SELECT id
    INTO v_puzzle_id
    FROM puzzle
    WHERE "date" = p_date AND publication_id = p_publication_id;

    IF v_puzzle_id IS NOT NULL THEN
        SELECT id
        INTO v_collection_id
        FROM clue_collection
        WHERE puzzle_id = v_puzzle_id;
    END IF;

    RETURN jsonb_build_object('collection_id', v_collection_id);
END;
$$ LANGUAGE plpgsql;
