import { sqlQuery } from "../../pool/postgres";

export interface ExplorerEntrySearch {
  length: number | null;
  pattern: string | null;
  familiarityBuckets: string[];
  humanReviewed: boolean | null;
  limit: number;
  offset: number;
}

export interface ExplorerEntryRow {
  entry: string;
  displayText: string;
  total: number;
}

const searchExplorerEntries = async (
  search: ExplorerEntrySearch,
): Promise<{ entries: ExplorerEntryRow[]; total: number }> => {
  const buckets = search.familiarityBuckets.length > 0 ? search.familiarityBuckets : null;

  // Count stays available when the requested page is past the last row.
  const rows = await sqlQuery(false, `
    WITH filtered AS (
      SELECT
        e."entry" AS entry,
        COALESCE(NULLIF(btrim(e.display_text), ''), e."entry") AS display_text
      FROM "entry" e
      WHERE e.lang = 'en'
        AND ($1::int IS NULL OR e."length" = $1::int)
        AND ($2::text IS NULL OR e."entry" ~ $2)
        AND (
          $3::jsonb IS NULL
          OR jsonb_array_length($3::jsonb) = 0
          OR e.familiarity_bucket IN (SELECT jsonb_array_elements_text($3::jsonb))
        )
        AND ($4::boolean IS NULL OR e.human_reviewed = $4::boolean)
    )
    SELECT page.entry, page.display_text, counted.total_count
    FROM (SELECT COUNT(*)::int AS total_count FROM filtered) counted
    LEFT JOIN LATERAL (
      SELECT entry, display_text
      FROM filtered
      ORDER BY entry
      LIMIT $5::int OFFSET $6::int
    ) page ON true
  `, [
    { name: "length", value: search.length },
    { name: "pattern", value: search.pattern },
    { name: "buckets", value: buckets },
    { name: "humanReviewed", value: search.humanReviewed },
    { name: "limit", value: search.limit },
    { name: "offset", value: search.offset },
  ]);

  const total = rows.length ? Number(rows[0].total_count) : 0;
  return {
    total,
    entries: rows
      .filter((row) => row.entry != null)
      .map((row) => ({
        entry: row.entry as string,
        displayText: row.display_text as string,
        total,
      })),
  };
};

export default searchExplorerEntries;
