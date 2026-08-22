CREATE OR REPLACE FUNCTION delete_phrase_generator_queue_item (
    p_prompt text,
    p_lang text
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM phrase_generator_queue
    WHERE prompt = p_prompt
      AND lang = p_lang;
END;
$$;
