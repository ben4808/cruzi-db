CREATE OR REPLACE FUNCTION add_community_clues(
    p_clues jsonb
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_inserted integer;
BEGIN
    INSERT INTO community_clue ("entry", lang, clue, times_used)
    SELECT
        upper(trim(c->>'entry')),
        COALESCE(NULLIF(trim(c->>'lang'), ''), 'en'),
        trim(c->>'clue'),
        1
    FROM jsonb_array_elements(p_clues) AS c
    WHERE COALESCE(trim(c->>'entry'), '') <> ''
      AND COALESCE(trim(c->>'clue'), '') <> ''
      AND NOT EXISTS (
          SELECT 1
          FROM community_clue existing
          WHERE existing."entry" = upper(trim(c->>'entry'))
            AND existing.lang = COALESCE(NULLIF(trim(c->>'lang'), ''), 'en')
            AND existing.clue = trim(c->>'clue')
      );

    GET DIAGNOSTICS v_inserted = ROW_COUNT;
    RETURN v_inserted;
END;
$$;
