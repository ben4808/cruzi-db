import { sqlQuery } from "../../pool/postgres";

export interface SeedEntry {
  entry: string;
  lang: string;
  displayText: string;
}

const getRandomSeedEntries = async (
  length: number,
  familiarityBucket: string = "General Knowledge",
  count: number = 10,
  lang: string = "en",
): Promise<SeedEntry[]> => {
  const results = await sqlQuery(true, "get_random_seed_entries", [
    { name: "p_length", value: length },
    { name: "p_familiarity_bucket", value: familiarityBucket },
    { name: "p_count", value: count },
    { name: "p_lang", value: lang },
  ]);

  return results.map((row) => ({
    entry: row.entry,
    lang: row.lang,
    displayText: row.display_text,
  }));
};

export default getRandomSeedEntries;
