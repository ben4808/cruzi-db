import { sqlQuery } from "../../pool/postgres";

export interface EntryForSpokenFamiliarityGenerator {
  entry: string;
  lang: string;
  display_text: string;
  familiarity_score: number | null;
  unity_bucket: string | null;
}

const getEntriesForSpokenFamiliarityGeneratorTop50 = async (): Promise<
  EntryForSpokenFamiliarityGenerator[]
> => {
  const results = await sqlQuery(true, "get_entries_for_spoken_familiarity_generator_top_50", []);

  return results.map((row) => ({
    entry: row.entry,
    lang: row.lang,
    display_text: row.display_text,
    familiarity_score: row.familiarity_score ?? null,
    unity_bucket: row.unity_bucket ?? null,
  }));
};

export default getEntriesForSpokenFamiliarityGeneratorTop50;
