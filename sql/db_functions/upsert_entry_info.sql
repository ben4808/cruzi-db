CREATE OR REPLACE FUNCTION upsert_entry_info(
    p_entry_info jsonb
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    sense_record jsonb;
    current_sense_id text;
    entry_name text;
    entry_lang text;
    entry_status text;
BEGIN
    -- Extract parameters from jsonb
    entry_name := (p_entry_info->>'entry')::text;
    entry_lang := (p_entry_info->>'lang')::text;
    entry_status := (p_entry_info->>'status')::text;

    -- Update entry status
    UPDATE "entry"
    SET loading_status = entry_status
    WHERE "entry" = entry_name AND lang = entry_lang;

    -- Process each sense
    FOR sense_record IN SELECT * FROM jsonb_array_elements(p_entry_info->'senses')
    LOOP
        -- Check if sense corresponds to existing sense
        IF sense_record ? 'corresponds_with' AND (sense_record->>'corresponds_with') IS NOT NULL THEN
            -- Find existing sense by summary match
            SELECT s.id INTO current_sense_id
            FROM sense s
            WHERE s.entry = entry_name
              AND s.lang = entry_lang
              AND s.summary = (sense_record->>'corresponds_with')
            LIMIT 1;

            IF current_sense_id IS NULL THEN
                -- Generate new sense ID if no match found
                current_sense_id := gen_random_uuid()::text;
            END IF;
        ELSE
            -- Check if sense already has an ID (from the input)
            IF sense_record ? 'id' AND (sense_record->>'id') IS NOT NULL THEN
                current_sense_id := (sense_record->>'id')::text;
            ELSE
                -- Generate new sense ID
                current_sense_id := gen_random_uuid()::text;
            END IF;
        END IF;

        -- Insert or update sense
        INSERT INTO sense (
            id,
            "entry",
            lang,
            part_of_speech,
            classification,
            frequency,
            summary,
            "definition",
            similar_entries,
            source_ai
        ) VALUES (
            current_sense_id,
            entry_name,
            entry_lang,
            (sense_record->>'part_of_speech')::text,
            (sense_record->>'classification')::text,
            (sense_record->>'frequency')::text,
            (sense_record->>'summary')::text,
            (sense_record->>'definition')::text,
            CASE
                WHEN sense_record ? 'similar_entries'
                     AND jsonb_typeof(sense_record->'similar_entries') = 'array'
                     AND jsonb_array_length(sense_record->'similar_entries') > 0
                THEN ARRAY(
                    SELECT jsonb_array_elements_text(sense_record->'similar_entries')
                )
                ELSE NULL
            END,
            (sense_record->>'source_ai')::text
        )
        ON CONFLICT (id) DO UPDATE SET
            part_of_speech = EXCLUDED.part_of_speech,
            classification = EXCLUDED.classification,
            frequency = EXCLUDED.frequency,
            summary = EXCLUDED.summary,
            "definition" = EXCLUDED."definition",
            similar_entries = EXCLUDED.similar_entries,
            source_ai = EXCLUDED.source_ai;

        IF sense_record ? 'translation_lang'
           AND (sense_record->>'translation_lang') IS NOT NULL THEN
            INSERT INTO sense_entry_translation (
                sense_id,
                "entry",
                lang,
                natural_translations,
                colloquial_translations
            ) VALUES (
                current_sense_id,
                entry_name,
                (sense_record->>'translation_lang')::text,
                CASE
                    WHEN sense_record ? 'natural_translations'
                         AND jsonb_typeof(sense_record->'natural_translations') = 'array'
                    THEN ARRAY(
                        SELECT jsonb_array_elements_text(sense_record->'natural_translations')
                    )
                    ELSE NULL
                END,
                CASE
                    WHEN sense_record ? 'colloquial_translations'
                         AND jsonb_typeof(sense_record->'colloquial_translations') = 'array'
                    THEN ARRAY(
                        SELECT jsonb_array_elements_text(sense_record->'colloquial_translations')
                    )
                    ELSE NULL
                END
            )
            ON CONFLICT (sense_id, "entry", lang) DO UPDATE SET
                natural_translations = EXCLUDED.natural_translations,
                colloquial_translations = EXCLUDED.colloquial_translations;
        END IF;
    END LOOP;
END;
$$;
