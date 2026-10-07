insert into short_phrase_queue (prompt, lang, "length")
SELECT
  chr(a) || chr(b) || '_____' AS prompt,
  'en' as lang,
  7 as "length"
FROM generate_series(ascii('A'), ascii('Z')) AS a
CROSS JOIN generate_series(ascii('A'), ascii('Z')) AS b
ORDER BY 1;
