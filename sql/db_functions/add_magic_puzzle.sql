CREATE OR REPLACE FUNCTION add_magic_puzzle(
    p_id text,
    p_lang text,
    p_width integer,
    p_height integer,
    p_seed_answer text
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO magic_puzzle (id, lang, width, height, seed_answer)
    VALUES (
        p_id,
        COALESCE(NULLIF(trim(p_lang), ''), 'en'),
        p_width,
        p_height,
        upper(trim(p_seed_answer))
    );
END;
$$;
