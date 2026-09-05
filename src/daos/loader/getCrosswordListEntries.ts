import { sqlQuery } from "../../pool/postgres";

export interface CrosswordListEntry {
  entry: string;
  lang: string;
  unityBucket: string | null;
  familiarityBucket: string | null;
  qualityBucket: string | null;
}

const getCrosswordListEntries = async (
  minLength: number = 3,
  maxLength: number = 5,
  excludeObscure: boolean = true,
): Promise<CrosswordListEntry[]> => {
  const results = await sqlQuery(true, "get_crossword_list_entries", [
    { name: "p_min_length", value: minLength },
    { name: "p_max_length", value: maxLength },
    { name: "p_exclude_obscure", value: excludeObscure },
  ]);

  return results.map((row) => ({
    entry: row.entry,
    lang: row.lang,
    unityBucket: row.unity_bucket ?? null,
    familiarityBucket: row.familiarity_bucket ?? null,
    qualityBucket: row.quality_bucket ?? null,
  }));
};

export default getCrosswordListEntries;
