CREATE OR REPLACE FUNCTION get_crossword_collection_id(
  p_publication_id text,
  p_date date
)
RETURNS jsonb AS $$
DECLARE
    v_collection_id text;
BEGIN
    SELECT cc.id
    INTO v_collection_id
    FROM clue_collection cc
    JOIN puzzle p ON cc.puzzle_id = p.id
    WHERE cc.metadata1 = to_char(p_date, 'YYYY-MM-DD')
      AND p.publication_id = p_publication_id;

    RETURN jsonb_build_object('collection_id', v_collection_id);
END;
$$ LANGUAGE plpgsql;
