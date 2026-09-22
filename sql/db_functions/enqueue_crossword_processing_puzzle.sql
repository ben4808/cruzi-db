CREATE OR REPLACE FUNCTION enqueue_crossword_processing_puzzle(p_puzzle_id text)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_puzzle_id IS NULL OR btrim(p_puzzle_id) = '' THEN
        RETURN;
    END IF;

    INSERT INTO crossword_processing_queue (puzzle_id)
    VALUES (p_puzzle_id);
END;
$$;
