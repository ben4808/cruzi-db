CREATE OR REPLACE FUNCTION defer_crossword_processing_puzzle(p_puzzle_id text)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_puzzle_id IS NULL OR btrim(p_puzzle_id) = '' THEN
        RETURN;
    END IF;

    UPDATE crossword_processing_queue
    SET added_at = now()
    WHERE puzzle_id = p_puzzle_id;
END;
$$;
