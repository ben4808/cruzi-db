COPY (
SELECT
  e."entry" || ' : ' ||
  CASE
    WHEN e.familiarity_score >= 30 AND e.quality_score >= 40 THEN 5
    WHEN e.familiarity_score >= 30 AND e.quality_score >= 35 THEN 4
    WHEN e.familiarity_score >= 30 AND e.quality_score >= 30 THEN 3
    WHEN e.familiarity_score >= 20 THEN 2
    WHEN e.familiarity_score >= 15 THEN 1
  END AS line
FROM "entry" e
WHERE e.unity_bucket IS DISTINCT FROM 'Non-unit'
  AND e.unity_bucket IS DISTINCT FROM 'Nonsense'
  AND e.familiarity_score >= 15
ORDER BY e."entry"
) TO 'C:\Users\Public\Documents\output.csv' WITH CSV HEADER;

COPY (
SELECT
  e."entry" || ';' ||
  CASE
    WHEN e.familiarity_score >= 30 AND e.quality_score >= 40 THEN 70
    WHEN e.familiarity_score >= 30 AND e.quality_score >= 35 THEN 60
    WHEN e.familiarity_score >= 30 AND e.quality_score >= 30 THEN 50
    WHEN e.familiarity_score >= 20 THEN 40
    WHEN e.familiarity_score >= 15 THEN 30
  END AS line
FROM "entry" e
WHERE e.unity_bucket IS DISTINCT FROM 'Non-unit'
  AND e.unity_bucket IS DISTINCT FROM 'Nonsense'
  AND e.familiarity_score >= 15
ORDER BY e."entry"
) TO 'C:\Users\Public\Documents\output.csv' WITH CSV HEADER;
