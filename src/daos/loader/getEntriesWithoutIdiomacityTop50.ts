import { sqlQuery } from "../../pool/postgres";

export interface EntryWithoutIdiomacity {
  entry: string;
  lang: string;
  display_text: string | null;
  entry_type: string | null;
}

const getEntriesWithoutIdiomacityTop50 = async (): Promise<EntryWithoutIdiomacity[]> => {
  const results = await sqlQuery(true, "get_entries_without_idiomacity_top_50", []);

  return results.map((row) => ({
    entry: row.entry,
    lang: row.lang,
    display_text: row.display_text ?? null,
    entry_type: row.entry_type ?? null,
  }));
};

export default getEntriesWithoutIdiomacityTop50;
