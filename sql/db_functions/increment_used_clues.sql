CREATE OR REPLACE FUNCTION increment_used_clues(
    p_clues jsonb
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_generated integer;
    v_community integer;
BEGIN
    -- One count per distinct entry/lang/clue text. Each matching stored clue
    -- is increased by how many puzzle slots used that text.
    WITH usage AS (
        SELECT
            upper(trim(c->>'entry')) AS entry,
            COALESCE(NULLIF(trim(c->>'lang'), ''), 'en') AS lang,
            trim(c->>'clue') AS clue,
            COUNT(*)::int AS uses
        FROM jsonb_array_elements(COALESCE(p_clues, '[]'::jsonb)) AS c
        WHERE COALESCE(trim(c->>'entry'), '') <> ''
          AND COALESCE(trim(c->>'clue'), '') <> ''
        GROUP BY 1, 2, 3
    )
    UPDATE generated_clue gc
    SET times_used = gc.times_used + usage.uses
    FROM usage
    WHERE gc."entry" = usage.entry
      AND gc.lang = usage.lang
      AND gc.generated_clue = usage.clue;

    GET DIAGNOSTICS v_generated = ROW_COUNT;

    WITH usage AS (
        SELECT
            upper(trim(c->>'entry')) AS entry,
            COALESCE(NULLIF(trim(c->>'lang'), ''), 'en') AS lang,
            trim(c->>'clue') AS clue,
            COUNT(*)::int AS uses
        FROM jsonb_array_elements(COALESCE(p_clues, '[]'::jsonb)) AS c
        WHERE COALESCE(trim(c->>'entry'), '') <> ''
          AND COALESCE(trim(c->>'clue'), '') <> ''
        GROUP BY 1, 2, 3
    )
    UPDATE community_clue cc
    SET times_used = cc.times_used + usage.uses
    FROM usage
    WHERE cc."entry" = usage.entry
      AND cc.lang = usage.lang
      AND cc.clue = usage.clue;

    GET DIAGNOSTICS v_community = ROW_COUNT;

    RETURN v_generated + v_community;
END;
$$;
