import { sqlQuery } from "../../pool/postgres";

export interface EntryForQualityGenerator {
  entry: string;
  lang: string;
  displayText: string;
  unityBucket: string;
  familiarityBucket: string;
}

const getEntriesForQualityGeneratorTop50 = async (
  limit: number,
  pattern?: string,
): Promise<EntryForQualityGenerator[]> => {
  const results = await sqlQuery(true, "get_entries_for_quality_generator_top_50", [
    { name: "p_limit", value: limit },
    { name: "p_pattern", value: pattern ?? null },
  ]);

  return results.map((row) => ({
    entry: row.entry,
    lang: row.lang,
    displayText: row.display_text,
    unityBucket: row.unity_bucket,
    familiarityBucket: row.familiarity_bucket,
  }));
};

export default getEntriesForQualityGeneratorTop50;
