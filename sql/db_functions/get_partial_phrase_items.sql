CREATE OR REPLACE FUNCTION get_partial_phrase_items(p_items jsonb)
RETURNS TABLE (
    display_text text,
    lang text
)
LANGUAGE sql
AS $$
    WITH items AS (
        SELECT DISTINCT
            trim(elem->>'display_text') AS display_text,
            trim(elem->>'lang') AS lang,
            lower(trim(elem->>'display_text')) AS display_lower
        FROM jsonb_array_elements(
            CASE
                WHEN jsonb_typeof(p_items) = 'array' THEN p_items
                ELSE '[]'::jsonb
            END
        ) AS elem
        WHERE COALESCE(NULLIF(trim(elem->>'display_text'), ''), '') <> ''
          AND COALESCE(NULLIF(trim(elem->>'lang'), ''), '') <> ''
    ),
    familiar_phrases AS (
        SELECT
            e.lang,
            lower(trim(COALESCE(NULLIF(e.display_text, ''), e.entry))) AS phrase_lower
        FROM "entry" e
        WHERE e.familiarity_score >= 20
          AND e.lang IN (SELECT i.lang FROM items i)
          AND position(' ' in trim(COALESCE(NULLIF(e.display_text, ''), e.entry))) > 0
    )
    SELECT DISTINCT i.display_text, i.lang
    FROM items i
    INNER JOIN familiar_phrases p
        ON p.lang = i.lang
       AND p.phrase_lower <> i.display_lower
       AND (
           p.phrase_lower LIKE i.display_lower || ' %'
           OR p.phrase_lower LIKE '% ' || i.display_lower
       );
$$;
