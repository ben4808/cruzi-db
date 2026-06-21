import { sqlQuery } from "../../pool/postgres";

export interface EntryWithoutFamiliarity {
  entry: string;
  lang: string;
}

const getEntriesWithoutFamiliarityTop50 = async (): Promise<EntryWithoutFamiliarity[]> => {
  const results = await sqlQuery(true, "get_entries_without_familiarity_top_50", []);

  return results.map((row) => ({
    entry: row.entry,
    lang: row.lang,
  }));
};

export default getEntriesWithoutFamiliarityTop50;
