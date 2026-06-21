import { sqlQuery } from "../../pool/postgres";

export interface EntryWithLowIdiomacity {
  entry: string;
  lang: string;
  display_text: string | null;
  entry_type: string | null;
}

const getEntriesLowIdiomacityTop150 = async (): Promise<EntryWithLowIdiomacity[]> => {
  const results = await sqlQuery(true, "get_entries_low_idiomacity_top_150", []);

  return results.map((row) => ({
    entry: row.entry,
    lang: row.lang,
    display_text: row.display_text ?? null,
    entry_type: row.entry_type ?? null,
  }));
};

export default getEntriesLowIdiomacityTop150;
