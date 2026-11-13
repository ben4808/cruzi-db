import { sqlQuery } from "../../pool/postgres";

export interface PuzzleDateRow {
  publicationId: string;
  date: string;
}

const getPuzzleDatesInRange = async (
  startDate: string,
  endDate: string,
): Promise<PuzzleDateRow[]> => {
  const results = await sqlQuery(
    false,
    `SELECT publication_id, to_char(date, 'YYYY-MM-DD') AS date
     FROM puzzle
     WHERE date >= $1
       AND date <= $2
       AND publication_id IS NOT NULL`,
    [
      { name: "p_start_date", value: startDate },
      { name: "p_end_date", value: endDate },
    ],
  );

  return results.map((row) => ({
    publicationId: row.publication_id as string,
    date: row.date as string,
  }));
};

export default getPuzzleDatesInRange;
