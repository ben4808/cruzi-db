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

    DROP TABLE IF EXISTS tmp_rebuild_inflected_rows;
    CREATE TEMP TABLE tmp_rebuild_inflected_rows ON COMMIT DROP AS
    SELECT DISTINCT ON (rows.base_entry, rows.inflected_entry, rows.lang)
        rows.base_entry,
        rows.inflected_entry,
        rows.lang,
        rows.display_text,
        rows.inflected_type,
        rows.base_display_text
    FROM (
        SELECT
            normalize_display_text_to_entry_key(
                COALESCE(elem->>'base_form', elem->>'baseForm')
            ) AS base_entry,
            elem->>'entry' AS inflected_entry,
            elem->>'lang' AS lang,
            NULLIF(trim(COALESCE(elem->>'display_text', elem->>'displayText')), '') AS display_text,
            NULLIF(trim(elem->>'classification'), '') AS inflected_type,
            NULLIF(trim(COALESCE(elem->>'base_form', elem->>'baseForm')), '') AS base_display_text,
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
            NULLIF(trim(esc.secondary_base_form), '') AS base_display_text,
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
    ORDER BY rows.base_entry, rows.inflected_entry, rows.lang, rows.sort_ord;

    INSERT INTO "entry" ("entry", lang, "length", display_text)
    SELECT DISTINCT ON (e.entry_key, e.lang)
        e.entry_key,
        e.lang,
        length(e.entry_key),
        e.display_text
    FROM (
        SELECT
            rows.base_entry AS entry_key,
            rows.lang,
            rows.base_display_text AS display_text
        FROM tmp_rebuild_inflected_rows rows
        UNION ALL
        SELECT
            rows.inflected_entry,
            rows.lang,
            rows.display_text
        FROM tmp_rebuild_inflected_rows rows
    ) e
    WHERE COALESCE(e.entry_key, '') <> ''
      AND COALESCE(e.lang, '') <> ''
    ORDER BY e.entry_key, e.lang
    ON CONFLICT ("entry", lang) DO NOTHING;

    INSERT INTO inflected_entry (
        base_entry,
        inflected_entry,
        lang,
        display_text,
        inflected_type
    )
    SELECT
        rows.base_entry,
        rows.inflected_entry,
        rows.lang,
        rows.display_text,
        rows.inflected_type
    FROM tmp_rebuild_inflected_rows rows
    ON CONFLICT (base_entry, inflected_entry, lang) DO UPDATE SET
        display_text = EXCLUDED.display_text,
        inflected_type = EXCLUDED.inflected_type;
END;
$$;
