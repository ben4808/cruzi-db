CREATE OR REPLACE FUNCTION fix_accented_entries(p_entries jsonb)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    fixed_count integer := 0;
    rec record;
    v_old_entry text;
    v_new_entry text;
    v_lang text;
BEGIN
    IF p_entries IS NULL OR jsonb_typeof(p_entries) <> 'array' OR jsonb_array_length(p_entries) = 0 THEN
        RETURN 0;
    END IF;

    FOR rec IN
        SELECT DISTINCT
            trim(elem->>'entry') AS old_entry,
            trim(elem->>'lang') AS lang
        FROM jsonb_array_elements(p_entries) AS elem
        WHERE COALESCE(NULLIF(trim(elem->>'entry'), ''), '') <> ''
          AND COALESCE(NULLIF(trim(elem->>'lang'), ''), '') <> ''
    LOOP
        v_old_entry := rec.old_entry;
        v_lang := rec.lang;
        v_new_entry := strip_entry_accents(v_old_entry);

        IF v_new_entry IS NULL OR v_new_entry = '' OR v_new_entry = v_old_entry THEN
            CONTINUE;
        END IF;

        IF NOT EXISTS (
            SELECT 1 FROM "entry" e
            WHERE e."entry" = v_old_entry AND e.lang = v_lang
        ) THEN
            CONTINUE;
        END IF;

        -- Upsert de-accented entry, filling nulls on the target from the accented source.
        INSERT INTO "entry" (
            "entry",
            base_form,
            lang,
            "length",
            display_text,
            entry_type,
            familiarity_bucket,
            familiarity_score,
            quality_bucket,
            quality_score,
            idiomacity_score,
            unity_bucket,
            unity_score,
            is_vulgar,
            loading_status,
            reviewed_status
        )
        SELECT
            v_new_entry,
            e.base_form,
            e.lang,
            length(v_new_entry),
            e.display_text,
            e.entry_type,
            e.familiarity_bucket,
            e.familiarity_score,
            e.quality_bucket,
            e.quality_score,
            e.idiomacity_score,
            e.unity_bucket,
            e.unity_score,
            e.is_vulgar,
            e.loading_status,
            e.reviewed_status
        FROM "entry" e
        WHERE e."entry" = v_old_entry
          AND e.lang = v_lang
        ON CONFLICT ("entry", lang) DO UPDATE SET
            base_form = COALESCE("entry".base_form, EXCLUDED.base_form),
            display_text = COALESCE("entry".display_text, EXCLUDED.display_text),
            entry_type = COALESCE("entry".entry_type, EXCLUDED.entry_type),
            familiarity_bucket = COALESCE("entry".familiarity_bucket, EXCLUDED.familiarity_bucket),
            familiarity_score = COALESCE("entry".familiarity_score, EXCLUDED.familiarity_score),
            quality_bucket = COALESCE("entry".quality_bucket, EXCLUDED.quality_bucket),
            quality_score = COALESCE("entry".quality_score, EXCLUDED.quality_score),
            idiomacity_score = COALESCE("entry".idiomacity_score, EXCLUDED.idiomacity_score),
            unity_bucket = COALESCE("entry".unity_bucket, EXCLUDED.unity_bucket),
            unity_score = COALESCE("entry".unity_score, EXCLUDED.unity_score),
            is_vulgar = COALESCE("entry".is_vulgar, EXCLUDED.is_vulgar),
            loading_status = COALESCE("entry".loading_status, EXCLUDED.loading_status),
            reviewed_status = COALESCE("entry".reviewed_status, EXCLUDED.reviewed_status);

        -- Point child rows at the de-accented key before deleting the old row.
        UPDATE sense
        SET "entry" = v_new_entry
        WHERE "entry" = v_old_entry
          AND lang = v_lang;

        DELETE FROM entry_tags et
        WHERE et."entry" = v_old_entry
          AND et.lang = v_lang
          AND EXISTS (
              SELECT 1
              FROM entry_tags existing
              WHERE existing."entry" = v_new_entry
                AND existing.lang = et.lang
                AND existing.tag = et.tag
          );

        UPDATE entry_tags
        SET "entry" = v_new_entry
        WHERE "entry" = v_old_entry
          AND lang = v_lang;

        UPDATE clue
        SET "entry" = v_new_entry
        WHERE "entry" = v_old_entry
          AND lang = v_lang;

        DELETE FROM sense_entry_translation setr
        WHERE setr."entry" = v_old_entry
          AND setr.lang = v_lang
          AND EXISTS (
              SELECT 1
              FROM sense_entry_translation existing
              WHERE existing.sense_id = setr.sense_id
                AND existing."entry" = v_new_entry
                AND existing.lang = setr.lang
          );

        UPDATE sense_entry_translation
        SET "entry" = v_new_entry
        WHERE "entry" = v_old_entry
          AND lang = v_lang;

        UPDATE entry_info_queue
        SET "entry" = v_new_entry
        WHERE "entry" = v_old_entry
          AND lang = v_lang;

        UPDATE crossword_familiarity_queue
        SET "entry" = v_new_entry
        WHERE "entry" = v_old_entry
          AND lang = v_lang;

        UPDATE crossword_quality_queue
        SET "entry" = v_new_entry
        WHERE "entry" = v_old_entry
          AND lang = v_lang;

        UPDATE idiomacity_queue
        SET "entry" = v_new_entry
        WHERE "entry" = v_old_entry
          AND lang = v_lang;

        UPDATE short_phrase_result
        SET "entry" = v_new_entry
        WHERE "entry" = v_old_entry
          AND lang = v_lang;

        UPDATE short_phrase_summary
        SET "entry" = v_new_entry
        WHERE "entry" = v_old_entry
          AND lang = v_lang;

        DELETE FROM "entry"
        WHERE "entry" = v_old_entry
          AND lang = v_lang;

        fixed_count := fixed_count + 1;
    END LOOP;

    RETURN fixed_count;
END;
$$;
