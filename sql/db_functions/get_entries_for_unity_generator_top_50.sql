CREATE OR REPLACE FUNCTION get_entries_for_unity_generator_top_50(p_limit integer)
RETURNS TABLE (
    entry text,
    lang text,
    display_text text,
    entry_type text,
    secondary_classes jsonb
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e."entry",
        e.lang,
        e.display_text,
        e.entry_type,
        COALESCE(
            (
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'secondary_class', esc.secondary_class,
                        'secondary_display', esc.secondary_display,
                        'secondary_base_form', esc.secondary_base_form
                    )
                )
                FROM entry_secondary_class esc
                WHERE esc."entry" = e."entry"
                  AND esc.lang = e.lang
            ),
            '[]'::jsonb
        ) AS secondary_classes
    FROM "entry" e
    WHERE e.reviewed_status = '1'
      AND e.display_text IS NOT NULL
      AND e.entry_type <> 'Nonsense'
      AND TRIM(e.display_text) <> ''
    ORDER BY random()
    LIMIT p_limit;
END;
$$;
