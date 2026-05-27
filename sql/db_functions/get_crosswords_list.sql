CREATE OR REPLACE FUNCTION get_crosswords_list(
  p_date text
)
RETURNS jsonb AS $$
DECLARE
  result jsonb;
BEGIN
  SELECT jsonb_agg(
    jsonb_build_object(
      'id', cc.id,
      'title', cc.title,
      'author', cc.author,
      'lang', cc.lang,
      'description', cc.description,
      'created_date', cc.created_date,
      'modified_date', cc.modified_date,
      'source', cc.source,
      'is_private', cc.is_private,
      'metadata1', cc.metadata1,
      'metadata2', cc.metadata2,
      'clue_count', cc.clue_count,
      'clue_count_6_plus', cc.clue_count_6_plus,
      'puzzle_id', p.id,
      'puzzle_title', p.title,
      'puzzle_date', p.date,
      'puzzle_author', p.author,
      'puzzle_lang', p.lang,
      'width', p.width,
      'height', p.height,
      'publication_id', p.publication_id,
      'creator', CASE WHEN u.id IS NOT NULL
                      THEN jsonb_build_object(
                          'creator_id', u.id,
                          'creator_first_name', u.first_name,
                          'creator_last_name', u.last_name
                      )
                      ELSE NULL
                END
    )
  )
  INTO result
  FROM clue_collection cc
  LEFT JOIN puzzle p ON cc.puzzle_id = p.id
  LEFT JOIN "user" u ON cc.creator_id = u.id
  WHERE cc.metadata1 = p_date;

  RETURN result;
END;
$$ LANGUAGE plpgsql;
