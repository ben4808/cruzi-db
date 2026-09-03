import { sqlQuery } from "../../pool/postgres";

export interface EntryForEntryParser {
  entry: string;
  lang: string;
}

const getEntriesForEntryParser = async (
  limit: number,
  pattern?: string,
): Promise<EntryForEntryParser[]> => {
  const results = await sqlQuery(true, "get_entries_for_entry_parser", [
    { name: "p_limit", value: limit },
    { name: "p_pattern", value: pattern ?? null },
  ]);

  return results.map((row) => ({
    entry: row.entry,
    lang: row.lang,
  }));
};

export default getEntriesForEntryParser;
