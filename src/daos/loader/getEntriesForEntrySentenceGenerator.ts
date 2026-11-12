import { sqlQuery } from "../../pool/postgres";

export interface EntryForEntrySentenceGenerator {
  entry: string;
  lang: string;
  displayText: string;
}

const getEntriesForEntrySentenceGenerator = async (
  limit: number,
): Promise<EntryForEntrySentenceGenerator[]> => {
  const results = await sqlQuery(true, "get_entries_for_entry_sentence_generator", [
    { name: "p_limit", value: limit },
  ]);

  return results.map((row) => ({
    entry: row.entry,
    lang: row.lang,
    displayText: row.display_text,
  }));
};

export default getEntriesForEntrySentenceGenerator;
