import { sqlQuery } from "../../pool/postgres";

export interface EntryForEntryImprover {
  entry: string;
  lang: string;
  inPuzzle: boolean;
}

const getEntriesForEntryImprover = async (
  limit: number,
): Promise<EntryForEntryImprover[]> => {
  const results = await sqlQuery(true, "get_entries_for_entry_improver", [
    { name: "p_limit", value: limit },
  ]);

  return results.map((row) => ({
    entry: row.entry,
    lang: row.lang,
    inPuzzle: row.in_puzzle,
  }));
};

export default getEntriesForEntryImprover;
