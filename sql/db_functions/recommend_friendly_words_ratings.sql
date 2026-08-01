-- Recommend rating labels for Friendly Words plays from entry familiarity/quality.
-- p_entries: jsonb array of entry strings, e.g. ["FOO","BAR"]
-- Returns jsonb object: { "FOO": "Good", ... }
CREATE OR REPLACE FUNCTION recommend_friendly_words_ratings(
    p_entries jsonb
)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
    result jsonb := '{}'::jsonb;
    entry_text text;
    rec record;
    label text;
BEGIN
    IF p_entries IS NULL OR jsonb_typeof(p_entries) <> 'array' THEN
        RETURN result;
    END IF;

    FOR entry_text IN
        SELECT jsonb_array_elements_text(p_entries)
    LOOP
        SELECT
            e.unity_bucket,
            e.familiarity_score,
            e.quality_score
        INTO rec
        FROM "entry" e
        WHERE e."entry" = upper(entry_text)
           OR e."entry" = entry_text
        ORDER BY CASE WHEN e.lang = 'en' THEN 0 ELSE 1 END
        LIMIT 1;

        IF NOT FOUND THEN
            label := 'Not a Thing';
        ELSIF rec.unity_bucket IN ('Non-unit', 'Nonsense')
           OR rec.familiarity_score IS NULL
           OR rec.familiarity_score < 15 THEN
            label := 'Not a Thing';
        ELSIF rec.familiarity_score >= 30 AND COALESCE(rec.quality_score, 0) >= 40 THEN
            label := 'Amazing';
        ELSIF rec.familiarity_score >= 30 AND COALESCE(rec.quality_score, 0) >= 35 THEN
            label := 'Cool';
        ELSIF rec.familiarity_score >= 30 AND (rec.quality_score is null or rec.quality_score >= 30) THEN
            label := 'Good';
        ELSIF rec.familiarity_score >= 25 THEN
            label := 'Meh';
        ELSIF rec.familiarity_score >= 20 THEN
            label := 'Obscure';
        ELSE
            -- familiarity_score >= 15
            label := 'It''s a Stretch';
        END IF;

        result := result || jsonb_build_object(entry_text, label);
    END LOOP;

    RETURN result;
END;
$$;
