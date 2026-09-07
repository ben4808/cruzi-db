CREATE OR REPLACE FUNCTION add_phrase_generator_results (
    p_results jsonb
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO phrase_generator_result (
        prompt,
        "entry",
        lang,
        base_form,
        is_vulgar,
        entry_type,
        display_text,
        unity_bucket,
        familiarity_bucket
    )
    SELECT
        trim((r->>'prompt')::text),
        trim((r->>'entry')::text),
        trim((r->>'lang')::text),
        NULLIF(trim(r->>'base_form'), ''),
        CASE
            WHEN r->>'is_vulgar' IS NULL OR trim(r->>'is_vulgar') = '' THEN NULL
            ELSE (r->>'is_vulgar')::boolean
        END,
        NULLIF(trim(r->>'entry_type'), ''),
        NULLIF(trim(r->>'display_text'), ''),
        NULLIF(trim(r->>'unity_bucket'), ''),
        NULLIF(trim(r->>'familiarity_bucket'), '')
    FROM jsonb_array_elements(p_results) AS r
    WHERE COALESCE(NULLIF(trim(r->>'prompt'), ''), '') <> ''
      AND COALESCE(NULLIF(trim(r->>'entry'), ''), '') <> ''
      AND COALESCE(NULLIF(trim(r->>'lang'), ''), '') <> '';

    -- Attach secondaries to phrase_generator_result keys the same way they attach to entry.
    -- Do not replace secondaries for keys that already exist in entry.
    DELETE FROM entry_secondary_class esc
    USING jsonb_array_elements(p_results) AS r
    WHERE esc."entry" = trim((r->>'entry')::text)
      AND esc.lang = trim((r->>'lang')::text)
      AND NOT EXISTS (
          SELECT 1
          FROM "entry" e
          WHERE e."entry" = esc."entry"
            AND e.lang = esc.lang
      );

    INSERT INTO entry_secondary_class (
        "entry",
        lang,
        secondary_class,
        secondary_display,
        secondary_base_form,
        unity_bucket,
        familiarity_bucket
    )
    SELECT DISTINCT ON (sc_rows."entry", sc_rows.lang, sc_rows.secondary_class)
        sc_rows."entry",
        sc_rows.lang,
        sc_rows.secondary_class,
        sc_rows.secondary_display,
        sc_rows.secondary_base_form,
        sc_rows.unity_bucket,
        sc_rows.familiarity_bucket
    FROM (
        SELECT
            trim((r->>'entry')::text) AS "entry",
            trim((r->>'lang')::text) AS lang,
            trim(sc->>'secondary_class') AS secondary_class,
            trim(sc->>'secondary_display') AS secondary_display,
            NULLIF(trim(sc->>'secondary_base_form'), '') AS secondary_base_form,
            NULLIF(trim(sc->>'unity_bucket'), '') AS unity_bucket,
            NULLIF(trim(sc->>'familiarity_bucket'), '') AS familiarity_bucket,
            r.ord AS result_ord,
            sc.sc_ord
        FROM jsonb_array_elements(p_results) WITH ORDINALITY AS r(r, ord)
        CROSS JOIN LATERAL jsonb_array_elements(COALESCE(r.r->'secondary_classes', '[]'::jsonb))
            WITH ORDINALITY AS sc(sc, sc_ord)
        WHERE COALESCE(NULLIF(trim(sc->>'secondary_class'), ''), '') <> ''
          AND COALESCE(NULLIF(trim(sc->>'secondary_display'), ''), '') <> ''
          AND NOT EXISTS (
              SELECT 1
              FROM "entry" e
              WHERE e."entry" = trim((r.r->>'entry')::text)
                AND e.lang = trim((r.r->>'lang')::text)
          )
    ) AS sc_rows
    ORDER BY sc_rows."entry", sc_rows.lang, sc_rows.secondary_class, sc_rows.result_ord, sc_rows.sc_ord
    ON CONFLICT ("entry", lang, secondary_class) DO UPDATE SET
        secondary_display = EXCLUDED.secondary_display,
        secondary_base_form = EXCLUDED.secondary_base_form,
        unity_bucket = COALESCE(EXCLUDED.unity_bucket, entry_secondary_class.unity_bucket),
        familiarity_bucket = COALESCE(EXCLUDED.familiarity_bucket, entry_secondary_class.familiarity_bucket);
END;
$$;
