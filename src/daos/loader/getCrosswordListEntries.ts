import { sqlQuery } from "../../pool/postgres";

export type CrosswordListExcludeItems = 'ExcludeNonUnit' | 'ExcludeObscure';

export interface CrosswordListEntry {
  entry: string;
  lang: string;
  classification: string | null;
  unityBucket: string | null;
  familiarityBucket: string | null;
  qualityBucket: string | null;
  hasAvoidTag: boolean;
  isAbbreviation: boolean;
  isSensitive: boolean;
  isCrosswordese: boolean;
}

const getCrosswordListEntries = async (
  minLength: number = 3,
  maxLength: number = 9,
  excludeItems?: CrosswordListExcludeItems | null,
): Promise<CrosswordListEntry[]> => {
  const results = await sqlQuery(true, "get_crossword_list_entries", [
    { name: "p_min_length", value: minLength },
    { name: "p_max_length", value: maxLength },
    { name: "p_exclude_items", value: excludeItems ?? null },
  ]);

  return results.map((row) => ({
    entry: row.entry,
    lang: row.lang,
    classification: row.classification ?? null,
    unityBucket: row.unity_bucket ?? null,
    familiarityBucket: row.familiarity_bucket ?? null,
    qualityBucket: row.quality_bucket ?? null,
    hasAvoidTag: Boolean(row.has_avoid_tag),
    isAbbreviation: Boolean(row.is_abbreviation),
    isSensitive: Boolean(row.is_sensitive),
    isCrosswordese: Boolean(row.is_crosswordese),
  }));
};

export default getCrosswordListEntries;
