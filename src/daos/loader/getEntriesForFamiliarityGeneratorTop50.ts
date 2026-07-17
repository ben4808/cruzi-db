import { sqlQuery } from "../../pool/postgres";

export interface EntryForFamiliarityGenerator {
  entry: string;
  lang: string;
  display_text: string;
}

const getEntriesForFamiliarityGeneratorTop50 = async (): Promise<EntryForFamiliarityGenerator[]> => {
  const results = await sqlQuery(true, "get_entries_for_familiarity_generator_top_50", []);

  return results.map((row) => ({
    entry: row.entry,
    lang: row.lang,
    display_text: row.display_text,
  }));
};

export default getEntriesForFamiliarityGeneratorTop50;
