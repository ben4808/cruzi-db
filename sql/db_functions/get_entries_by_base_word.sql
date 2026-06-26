CREATE OR REPLACE FUNCTION get_entries_by_base_word (
    p_base_word text,
    p_lang text,
    p_position text
)
RETURNS TABLE (
    display_text text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_base_key text;
    v_base_word text;
BEGIN
    v_base_key := normalize_display_text_to_entry_key(p_base_word);
    v_base_word := lower(trim(p_base_word));

    RETURN QUERY
    SELECT DISTINCT COALESCE(NULLIF(trim(e.display_text), ''), e.entry) AS display_text
    FROM "entry" e
    WHERE e.lang = p_lang
      AND (
        CASE lower(trim(p_position))
          WHEN 'start' THEN
            lower(trim(COALESCE(e.display_text, e.entry))) = v_base_word
            OR lower(trim(COALESCE(e.display_text, e.entry))) LIKE v_base_word || ' %'
            OR e.entry LIKE v_base_key || '%'
          WHEN 'end' THEN
            lower(trim(COALESCE(e.display_text, e.entry))) = v_base_word
            OR lower(trim(COALESCE(e.display_text, e.entry))) LIKE '% ' || v_base_word
            OR e.entry LIKE '%' || v_base_key
          ELSE false
        END
      );
END;
$$;
