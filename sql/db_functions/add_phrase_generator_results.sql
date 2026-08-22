DROP FUNCTION IF EXISTS add_phrase_generator_results(integer, jsonb);

CREATE OR REPLACE FUNCTION add_phrase_generator_results (
    p_results jsonb
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO phrase_generator_result (prompt, "entry", lang, display_text, unity_bucket, familiarity_bucket)
    SELECT
        trim((r->>'prompt')::text),
        trim((r->>'entry')::text),
        trim((r->>'lang')::text),
        NULLIF(trim(r->>'display_text'), ''),
        NULLIF(trim(r->>'unity_bucket'), ''),
        NULLIF(trim(r->>'familiarity_bucket'), '')
    FROM jsonb_array_elements(p_results) AS r
    WHERE COALESCE(NULLIF(trim(r->>'prompt'), ''), '') <> ''
      AND COALESCE(NULLIF(trim(r->>'entry'), ''), '') <> ''
      AND COALESCE(NULLIF(trim(r->>'lang'), ''), '') <> '';
END;
$$;
