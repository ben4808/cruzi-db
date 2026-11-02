-- Saved grid (fill key in clue_collection.metadata2) and clues for one magic puzzle.
-- Returns null when the id is unknown.
CREATE OR REPLACE FUNCTION get_magic_puzzle(p_id text)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (
        SELECT jsonb_build_object(
            'id', mp.id,
            'lang', mp.lang,
            'width', mp.width,
            'height', mp.height,
            'grid', cc.metadata2,
            'clues', COALESCE((
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'key', COALESCE(colc.metadata1, ''),
                        'clue', COALESCE(c.custom_clue, ''),
                        'order', colc."order"
                    )
                    ORDER BY colc."order"
                )
                FROM collection__clue colc
                JOIN clue c ON c.id = colc.clue_id
                WHERE colc.collection_id = cc.id
            ), '[]'::jsonb)
        )
        FROM magic_puzzle mp
        JOIN clue_collection cc ON cc.magic_puzzle_id = mp.id
        WHERE mp.id = p_id
        ORDER BY cc.created_date DESC
        LIMIT 1
    );
END;
$$;
