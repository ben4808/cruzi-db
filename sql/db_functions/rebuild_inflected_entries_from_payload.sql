CREATE OR REPLACE FUNCTION rebuild_inflected_entries_from_payload(
    entries_data jsonb,
    p_mode text DEFAULT 'replace'
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF entries_data IS NULL OR jsonb_typeof(entries_data) <> 'array' THEN
        RETURN;
    END IF;

    IF p_mode = 'replace' THEN
        DELETE FROM inflected_entry ie
        USING jsonb_array_elements(entries_data) AS elem
        WHERE ie.inflected_entry = elem->>'entry'
          AND ie.lang = elem->>'lang';
    END IF;

    INSERT INTO inflected_entry (
        base_entry,
        inflected_entry,
        lang,
        display_text,
        inflected_type
    )
    SELECT DISTINCT ON (rows.base_entry, rows.inflected_entry, rows.lang)
        rows.base_entry,
        rows.inflected_entry,
        rows.lang,
        rows.display_text,
        rows.inflected_type
    FROM (
        SELECT
            normalize_display_text_to_entry_key(
                COALESCE(elem->>'base_form', elem->>'baseForm')
            ) AS base_entry,
            elem->>'entry' AS inflected_entry,
            elem->>'lang' AS lang,
            NULLIF(trim(COALESCE(elem->>'display_text', elem->>'displayText')), '') AS display_text,
            NULLIF(trim(COALESCE(elem->>'entry_type', elem->>'entryType')), '') AS inflected_type,
            0 AS sort_ord
        FROM jsonb_array_elements(entries_data) AS elem
        WHERE normalize_display_text_to_entry_key(
                COALESCE(elem->>'base_form', elem->>'baseForm')
              ) <> ''
          AND normalize_display_text_to_entry_key(
                COALESCE(elem->>'base_form', elem->>'baseForm')
              ) IS DISTINCT FROM elem->>'entry'

        UNION ALL

        SELECT
            normalize_display_text_to_entry_key(esc.secondary_base_form) AS base_entry,
            elem->>'entry' AS inflected_entry,
            elem->>'lang' AS lang,
            NULLIF(trim(esc.secondary_display), '') AS display_text,
            NULLIF(trim(esc.secondary_class), '') AS inflected_type,
            1 AS sort_ord
        FROM jsonb_array_elements(entries_data) AS elem
        INNER JOIN entry_secondary_class esc
          ON esc."entry" = elem->>'entry'
         AND esc.lang = elem->>'lang'
        WHERE normalize_display_text_to_entry_key(esc.secondary_base_form) <> ''
          AND normalize_display_text_to_entry_key(esc.secondary_base_form)
            IS DISTINCT FROM elem->>'entry'
    ) AS rows
    WHERE COALESCE(rows.base_entry, '') <> ''
      AND COALESCE(rows.inflected_entry, '') <> ''
      AND COALESCE(rows.lang, '') <> ''
      AND (
          p_mode = 'replace'
          OR NOT EXISTS (
              SELECT 1
              FROM inflected_entry existing
              WHERE existing.inflected_entry = rows.inflected_entry
                AND existing.lang = rows.lang
          )
      )
    ORDER BY rows.base_entry, rows.inflected_entry, rows.lang, rows.sort_ord
    ON CONFLICT (base_entry, inflected_entry, lang) DO UPDATE SET
        display_text = EXCLUDED.display_text,
        inflected_type = EXCLUDED.inflected_type;
END;
$$;
