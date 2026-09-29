CREATE OR REPLACE FUNCTION fill_entry_display_and_type_if_null(
    p_entry text,
    p_lang text,
    p_display_text text,
    p_classification text
)
RETURNS boolean
LANGUAGE plpgsql
AS $$
DECLARE
    updated integer;
BEGIN
    UPDATE "entry"
    SET
        display_text = COALESCE(NULLIF(btrim(p_display_text), ''), display_text),
        classification = COALESCE(NULLIF(btrim(p_classification), ''), classification)
    WHERE "entry" = p_entry
      AND lang = p_lang
      AND NULLIF(btrim(classification), '') IS NULL;

    GET DIAGNOSTICS updated = ROW_COUNT;
    RETURN updated > 0;
END;
$$;
