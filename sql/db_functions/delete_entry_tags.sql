CREATE OR REPLACE FUNCTION delete_entry_tags (
    p_tags jsonb
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM entry_tags et
    USING jsonb_array_elements(p_tags) AS t
    WHERE et."entry" = trim((t->>'entry')::text)
      AND et.lang = trim((t->>'lang')::text)
      AND et.tag = trim((t->>'tag')::text)
      AND COALESCE(NULLIF(trim(t->>'entry'), ''), '') <> ''
      AND COALESCE(NULLIF(trim(t->>'lang'), ''), '') <> ''
      AND COALESCE(NULLIF(trim(t->>'tag'), ''), '') <> '';
END;
$$;
