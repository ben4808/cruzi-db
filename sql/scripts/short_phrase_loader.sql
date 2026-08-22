insert into short_phrase_queue (prompt, lang, "length")
SELECT
  chr(a) || chr(b) || '___' AS prompt,
  'en' as lang,
  5 as "length"
FROM generate_series(ascii('A'), ascii('Z')) AS a
CROSS JOIN generate_series(ascii('A'), ascii('Z')) AS b
ORDER BY 1;
