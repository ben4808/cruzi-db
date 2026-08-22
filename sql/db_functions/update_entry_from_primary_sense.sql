DROP FUNCTION IF EXISTS update_entry_from_primary_sense(text, text, text, text);

CREATE OR REPLACE FUNCTION update_entry_from_primary_sense(
    p_entry text,
    p_lang text,
    p_display_text text,
    p_entry_type text,
    p_base_form text DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE "entry"
    SET
        display_text = COALESCE(NULLIF(TRIM(p_display_text), ''), display_text),
        entry_type = COALESCE(NULLIF(TRIM(p_entry_type), ''), entry_type),
        base_form = COALESCE(NULLIF(TRIM(p_base_form), ''), base_form),
        loading_status = 'Senses',
        reviewed_status = '1'
    WHERE "entry" = p_entry
      AND lang = p_lang;
END;
$$;
