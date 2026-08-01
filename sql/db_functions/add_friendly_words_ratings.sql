-- Persist per-player ratings for played words in a turn.
CREATE OR REPLACE FUNCTION add_friendly_words_ratings(
    p_ratings jsonb
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO friendly_words_rating (
        played_word_id, player_id, "entry", lang, multiplier, was_updated
    )
    SELECT
        (r->>'playedWordId')::text,
        (r->>'playerId')::text,
        (r->>'entry')::text,
        COALESCE(r->>'lang', 'en'),
        (r->>'multiplier')::text,
        COALESCE((r->>'wasUpdated')::boolean, false)
    FROM jsonb_array_elements(COALESCE(p_ratings, '[]'::jsonb)) AS r
    ON CONFLICT (played_word_id, player_id) DO UPDATE SET
        "entry" = EXCLUDED."entry",
        lang = EXCLUDED.lang,
        multiplier = EXCLUDED.multiplier,
        was_updated = EXCLUDED.was_updated;
END;
$$;
