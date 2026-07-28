import { sqlQuery } from "../../pool/postgres";

export interface EntryWithAccent {
  entry: string;
  lang: string;
}

const getEntriesWithAccents = async (
  limit: number,
): Promise<EntryWithAccent[]> => {
  const results = await sqlQuery(true, "get_entries_with_accents", [
    { name: "p_limit", value: limit },
  ]);

  return results.map((row) => ({
    entry: row.entry,
    lang: row.lang,
  }));
};

export default getEntriesWithAccents;
