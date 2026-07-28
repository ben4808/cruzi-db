CREATE OR REPLACE FUNCTION get_entries_matching_short_phrase_prompt (
    p_base_letters text,
    p_lang text,
    p_length integer,
    p_position text
)
RETURNS TABLE (
    display_text text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_base_key text;
BEGIN
    v_base_key := normalize_display_text_to_entry_key(p_base_letters);

    RETURN QUERY
    SELECT DISTINCT COALESCE(NULLIF(trim(e.display_text), ''), e.entry) AS display_text
    FROM "entry" e
    WHERE e.lang = p_lang
      AND e."length" = p_length
      AND v_base_key <> ''
      AND (
        CASE lower(trim(p_position))
          WHEN 'start' THEN e.entry LIKE v_base_key || '%'
          WHEN 'end' THEN e.entry LIKE '%' || v_base_key
          ELSE false
        END
      );
END;
$$;
