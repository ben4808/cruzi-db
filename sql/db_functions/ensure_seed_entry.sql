CREATE OR REPLACE FUNCTION ensure_seed_entry(
    p_display_text text,
    p_entry text,
    p_lang text DEFAULT 'en'
)
RETURNS boolean
LANGUAGE plpgsql
AS $$
DECLARE
    v_lang text := COALESCE(NULLIF(trim(p_lang), ''), 'en');
    v_entry text := upper(trim(p_entry));
    v_inserted integer;
BEGIN
    IF COALESCE(v_entry, '') !~ '^[A-Z]+$' THEN
        RAISE EXCEPTION 'seed entry must be letters';
    END IF;
    IF p_display_text IS NULL OR btrim(p_display_text) = '' THEN
        RAISE EXCEPTION 'display text is required';
    END IF;

    -- Leave an existing entry alone, including its display_text and tags.
    IF EXISTS (
        SELECT 1
        FROM "entry" e
        WHERE e.lang = v_lang
          AND (
            e."entry" = v_entry
            OR normalize_display_text_to_entry_key(e."entry") = v_entry
          )
    ) THEN
        RETURN false;
    END IF;

    INSERT INTO "entry" ("entry", lang, "length", display_text)
    VALUES (v_entry, v_lang, char_length(v_entry), p_display_text)
    ON CONFLICT ("entry", lang) DO NOTHING;

    GET DIAGNOSTICS v_inserted = ROW_COUNT;
    IF v_inserted = 0 THEN
        RETURN false;
    END IF;

    INSERT INTO entry_tags ("entry", lang, tag)
    VALUES (v_entry, v_lang, 'seed_answer')
    ON CONFLICT ("entry", lang, tag) DO NOTHING;

    RETURN true;
END;
$$;
