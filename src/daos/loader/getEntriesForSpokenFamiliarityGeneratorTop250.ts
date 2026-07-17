import { sqlQuery } from "../../pool/postgres";
import { EntryForSpokenFamiliarityGenerator } from "./getEntriesForSpokenFamiliarityGeneratorTop50";

export type { EntryForSpokenFamiliarityGenerator };

const getEntriesForSpokenFamiliarityGeneratorTop250 = async (): Promise<
  EntryForSpokenFamiliarityGenerator[]
> => {
  const results = await sqlQuery(true, "get_entries_for_spoken_familiarity_generator_top_250", []);

  return results.map((row) => ({
    entry: row.entry,
    lang: row.lang,
    display_text: row.display_text,
    familiarity_score: row.familiarity_score ?? null,
    unity_bucket: row.unity_bucket ?? null,
  }));
};

export default getEntriesForSpokenFamiliarityGeneratorTop250;
