CREATE OR REPLACE FUNCTION delete_generated_clue(
    p_entry text,
    p_clue text,
    p_lang text DEFAULT 'en'
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_deleted integer;
BEGIN
    -- Only unused or once-used AI clues can be removed.
    DELETE FROM generated_clue gc
    WHERE gc.lang = COALESCE(NULLIF(trim(p_lang), ''), 'en')
      AND gc.generated_clue = trim(p_clue)
      AND COALESCE(gc.times_used, 0) <= 1
      AND (
            gc."entry" = upper(trim(p_entry))
            OR normalize_display_text_to_entry_key(gc."entry") = upper(trim(p_entry))
      );

    GET DIAGNOSTICS v_deleted = ROW_COUNT;
    RETURN v_deleted;
END;
$$;
