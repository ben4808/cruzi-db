import { sqlQuery } from "../../pool/postgres";

export interface EntryWithoutFamiliarity {
  entry: string;
  lang: string;
  display_text: string;
}

const getEntriesWithoutFamiliarityTop50 = async (): Promise<EntryWithoutFamiliarity[]> => {
  const results = await sqlQuery(true, "get_entries_without_familiarity_top_50", []);

  return results.map((row) => ({
    entry: row.entry,
    lang: row.lang,
    display_text: row.display_text,
  }));
};

export default getEntriesWithoutFamiliarityTop50;
