CREATE OR REPLACE FUNCTION add_magic_clue_collection (
    p_collection_id text,
    p_magic_puzzle_id text,
    p_title text,
    p_lang text,
    p_source text,
    p_metadata2 text,
    p_clue_count integer,
    p_created_date timestamp,
    p_modified_date timestamp
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO clue_collection (
        id,
        magic_puzzle_id,
        title,
        lang,
        is_private,
        created_date,
        modified_date,
        metadata2,
        clue_count,
        "source"
    )
    VALUES (
        p_collection_id,
        p_magic_puzzle_id,
        p_title,
        p_lang,
        false,
        p_created_date,
        p_modified_date,
        NULLIF(p_metadata2, ''),
        COALESCE(p_clue_count, 0),
        NULLIF(p_source, '')
    )
    ON CONFLICT (id) DO UPDATE SET
        magic_puzzle_id = EXCLUDED.magic_puzzle_id,
        title = EXCLUDED.title,
        lang = EXCLUDED.lang,
        modified_date = EXCLUDED.modified_date,
        metadata2 = EXCLUDED.metadata2,
        clue_count = EXCLUDED.clue_count,
        "source" = EXCLUDED.source;
END;
$$;
