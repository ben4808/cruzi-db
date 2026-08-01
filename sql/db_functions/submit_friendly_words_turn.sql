-- Insert a completed turn and its played words.
CREATE OR REPLACE FUNCTION submit_friendly_words_turn(
    p_turn jsonb,
    p_played_words jsonb
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM friendly_words_game WHERE id = p_turn->>'gameId'
    ) THEN
        RAISE EXCEPTION 'Game not found: %', p_turn->>'gameId';
    END IF;

    INSERT INTO friendly_words_turn (
        id, game_id, player, turn_number, rack, "action",
        gross_score, total_multiplier, net_score, start_score, end_score
    )
    VALUES (
        p_turn->>'id',
        p_turn->>'gameId',
        p_turn->>'player',
        (p_turn->>'turnNumber')::int,
        p_turn->>'rack',
        p_turn->>'action',
        NULLIF(p_turn->>'grossScore', '')::int,
        p_turn->>'totalMultiplier',
        NULLIF(p_turn->>'netScore', '')::int,
        COALESCE((p_turn->>'startScore')::int, 0),
        COALESCE((p_turn->>'endScore')::int, 0)
    );

    INSERT INTO friendly_words_played_word (
        id, turn_id, "entry", lang, gross_score, multiplier
    )
    SELECT
        (word_item->>'id')::text,
        p_turn->>'id',
        (word_item->>'entry')::text,
        COALESCE(word_item->>'lang', 'en'),
        COALESCE((word_item->>'grossScore')::int, 0),
        (word_item->>'multiplier')::text
    FROM jsonb_array_elements(COALESCE(p_played_words, '[]'::jsonb)) AS word_item;
END;
$$;
