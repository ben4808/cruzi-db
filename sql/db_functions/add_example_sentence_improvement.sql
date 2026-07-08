CREATE OR REPLACE FUNCTION add_example_sentence_improvement(
    p_example_sentence_id text,
    p_old_sentence text,
    p_new_sentence text,
    p_new_translation text
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO example_sentence_improvement (
        id,
        example_sentence_id,
        old_sentence,
        new_sentence,
        new_translation
    )
    VALUES (
        gen_random_uuid()::text,
        p_example_sentence_id,
        p_old_sentence,
        p_new_sentence,
        p_new_translation
    );
END;
$$;
