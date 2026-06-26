import { sqlQuery } from "../../pool/postgres";

export interface EntryWithMismatchedDisplayText {
  entry: string;
  lang: string;
  displayText: string;
}

const getEntriesWithMismatchedDisplayText = async (
  limit: number,
): Promise<EntryWithMismatchedDisplayText[]> => {
  const results = await sqlQuery(true, "get_entries_with_mismatched_display_text", [
    { name: "p_limit", value: limit },
  ]);

  return results.map((row) => ({
    entry: row.entry,
    lang: row.lang,
    displayText: row.display_text,
  }));
};

export default getEntriesWithMismatchedDisplayText;
