CREATE OR REPLACE FUNCTION strip_entry_accents(p_text text)
RETURNS text
LANGUAGE sql
IMMUTABLE
PARALLEL SAFE
AS $$
  -- Remove combining marks first, then map remaining accented Latin letters.
  SELECT translate(
    regexp_replace(coalesce(p_text, ''), '[\u0300-\u036F]', '', 'g'),
    'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝŸàáâãäåæçèéêëìíîïðñòóôõöøùúûüýÿāăąćĉċčďđēĕėęěĝğġģĥħĩīĭįıĵķĺļľŀłńņňŋōŏőœŕřśŝşšţťŧũūŭůűųŵŷỹẽĨŨỸ',
    'AAAAAAACEEEEIIIIDNOOOOOOUUUUYYaaaaaaaceeeeiiiidnoooooouuuuyyaaaccccddeeeeegggghhiiiiijklllllnnnnoooorrsssstttuuuuuuwyyeIUY'
  );
$$;
