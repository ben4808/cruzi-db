-- Mark a crossword collection as completed for a user.
CREATE OR REPLACE FUNCTION complete_crossword(
    p_user_id text,
    p_collection_id text
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM clue_collection
        WHERE id = p_collection_id
          AND puzzle_id IS NOT NULL
    ) THEN
        RAISE EXCEPTION 'Crossword collection not found: %', p_collection_id;
    END IF;

    INSERT INTO user__collection (user_id, collection_id, collection_completed)
    VALUES (p_user_id, p_collection_id, true)
    ON CONFLICT (user_id, collection_id) DO UPDATE
        SET collection_completed = true;
END;
$$;
