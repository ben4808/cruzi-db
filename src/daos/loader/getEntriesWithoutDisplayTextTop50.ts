import { sqlQuery } from "../../pool/postgres";

export interface EntryWithoutDisplayText {
  entry: string;
  lang: string;
}

const getEntriesWithoutDisplayTextTop50 = async (): Promise<EntryWithoutDisplayText[]> => {
  const results = await sqlQuery(true, "get_entries_without_display_text_top_50", []);

  return results.map((row) => ({
    entry: row.entry,
    lang: row.lang,
  }));
};

export default getEntriesWithoutDisplayTextTop50;
