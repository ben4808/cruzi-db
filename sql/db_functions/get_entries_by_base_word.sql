CREATE OR REPLACE FUNCTION get_entries_by_base_word (
    p_base_word text,
    p_lang text,
    p_position text,
    p_separated_only boolean DEFAULT false
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
        CASE
          WHEN p_separated_only THEN
            CASE lower(trim(p_position))
              WHEN 'start' THEN
                lower(trim(COALESCE(e.display_text, e.entry))) = v_base_word
                OR (
                  position(v_base_word in lower(trim(COALESCE(e.display_text, e.entry)))) = 1
                  AND length(lower(trim(COALESCE(e.display_text, e.entry)))) > length(v_base_word)
                  AND substring(
                    lower(trim(COALESCE(e.display_text, e.entry)))
                    FROM length(v_base_word) + 1
                    FOR 1
                  ) ~ '[ ,\-]'
                )
              WHEN 'end' THEN
                lower(trim(COALESCE(e.display_text, e.entry))) = v_base_word
                OR (
                  lower(trim(COALESCE(e.display_text, e.entry))) LIKE '%' || v_base_word
                  AND length(lower(trim(COALESCE(e.display_text, e.entry)))) > length(v_base_word)
                  AND substring(
                    lower(trim(COALESCE(e.display_text, e.entry)))
                    FROM length(lower(trim(COALESCE(e.display_text, e.entry)))) - length(v_base_word)
                    FOR 1
                  ) ~ '[ ,\-]'
                )
              ELSE false
            END
          ELSE
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
        END
      );
END;
$$;
