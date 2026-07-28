CREATE OR REPLACE FUNCTION normalize_display_text_to_entry_key(p_text text)
RETURNS text
LANGUAGE plpgsql
IMMUTABLE
PARALLEL SAFE
AS $$
DECLARE
  result text;
BEGIN
  result := upper(
    translate(
      coalesce(p_text, ''),
      'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝŸàáâãäåæçèéêëìíîïðñòóôõöøùúûüýÿāăąćĉċčďđēĕėęěĝğġģĥħĩīĭįıĵķĺļľŀłńņňŋōŏőœŕřśŝşšţťŧũūŭůűųŵŷỹẽĨŨỸ',
      'AAAAAAACEEEEIIIIDNOOOOOOUUUUYYaaaaaaaceeeeiiiidnoooooouuuuyyaaaccccddeeeeegggghhiiiiijklllllnnnnoooorrsssstttuuuuuuwyyeIUY'
    )
  );
  -- Keep ASCII letters and numerals only (accents already stripped above).
  result := regexp_replace(result, '[^A-Z0-9]', '', 'g');
  RETURN result;
END;
$$;
