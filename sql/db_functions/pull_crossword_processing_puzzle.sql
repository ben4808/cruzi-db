CREATE OR REPLACE FUNCTION pull_crossword_processing_puzzle()
RETURNS TABLE (
    puzzle_id text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT q.puzzle_id
    FROM crossword_processing_queue q
    ORDER BY q.added_at ASC, q.id ASC
    LIMIT 1;
END;
$$;
