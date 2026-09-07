import { sqlQuery } from "../../pool/postgres";

export interface ClassificationEntry {
  fillWord: string;
  entry: string | null;
  lang: string | null;
  baseForm: string | null;
  displayText: string | null;
  entryType: string | null;
  unityBucket: string | null;
  familiarityBucket: string | null;
  qualityBucket: string | null;
  isVulgar: boolean | null;
  isCrosswordese: boolean;
  isBreakfast: boolean;
  nytValue: string | null;
}

const getEntriesForClassification = async (
  fillWords: string[],
): Promise<ClassificationEntry[]> => {
  if (fillWords.length === 0) {
    return [];
  }

  const results = await sqlQuery(true, "get_entries_for_classification", [
    { name: "p_fill_words", value: fillWords },
  ]);

  return results.map((row) => ({
    fillWord: row.fill_word,
    entry: row.entry ?? null,
    lang: row.lang ?? null,
    baseForm: row.base_form ?? null,
    displayText: row.display_text ?? null,
    entryType: row.entry_type ?? null,
    unityBucket: row.unity_bucket ?? null,
    familiarityBucket: row.familiarity_bucket ?? null,
    qualityBucket: row.quality_bucket ?? null,
    isVulgar: row.is_vulgar ?? null,
    isCrosswordese: row.is_crosswordese === true,
    isBreakfast: row.is_breakfast === true,
    nytValue: row.nyt_value ?? null,
  }));
};

export default getEntriesForClassification;
