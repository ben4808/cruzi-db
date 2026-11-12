CREATE OR REPLACE FUNCTION add_entry_sentences(
    p_sentences jsonb
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_inserted integer;
BEGIN
    IF p_sentences IS NULL OR jsonb_typeof(p_sentences) <> 'array' OR jsonb_array_length(p_sentences) = 0 THEN
        RETURN 0;
    END IF;

    INSERT INTO entry_sentence (
        id,
        "entry",
        original_lang,
        original_sentence,
        translated_lang,
        translated_sentence
    )
    SELECT
        gen_random_uuid()::text,
        btrim(elem->>'entry'),
        btrim(elem->>'original_lang'),
        btrim(elem->>'original_sentence'),
        NULLIF(btrim(elem->>'translated_lang'), ''),
        NULLIF(btrim(elem->>'translated_sentence'), '')
    FROM jsonb_array_elements(p_sentences) AS elem
    WHERE COALESCE(btrim(elem->>'entry'), '') <> ''
      AND COALESCE(btrim(elem->>'original_lang'), '') <> ''
      AND COALESCE(btrim(elem->>'original_sentence'), '') <> '';

    GET DIAGNOSTICS v_inserted = ROW_COUNT;
    RETURN v_inserted;
END;
$$;
