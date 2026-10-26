ALTER TABLE generated_clue ADD COLUMN IF NOT EXISTS clue_type text;
ALTER TABLE "entry" ADD COLUMN IF NOT EXISTS clues_generated boolean NOT NULL DEFAULT false;

CREATE OR REPLACE FUNCTION add_generated_clues(
    p_clues jsonb
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_inserted integer;
BEGIN
    INSERT INTO generated_clue ("entry", lang, generated_clue, is_seedword, clue_type)
    SELECT
        upper(trim(c->>'entry')),
        COALESCE(NULLIF(trim(c->>'lang'), ''), 'en'),
        trim(c->>'generated_clue'),
        COALESCE((c->>'is_seedword')::boolean, false),
        NULLIF(trim(c->>'clue_type'), '')
    FROM jsonb_array_elements(p_clues) AS c
    WHERE COALESCE(trim(c->>'entry'), '') <> ''
      AND COALESCE(trim(c->>'generated_clue'), '') <> '';

    GET DIAGNOSTICS v_inserted = ROW_COUNT;

    UPDATE "entry" e
    SET clues_generated = true
    FROM jsonb_array_elements(p_clues) AS c
    WHERE COALESCE((c->>'is_seedword')::boolean, false) = false
      AND COALESCE(trim(c->>'entry'), '') <> ''
      AND COALESCE(trim(c->>'generated_clue'), '') <> ''
      AND e.lang = COALESCE(NULLIF(trim(c->>'lang'), ''), 'en')
      AND e."entry" = upper(trim(c->>'entry'));

    RETURN v_inserted;
END;
$$;
