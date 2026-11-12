import { sqlQuery } from "../../pool/postgres";

export type CrosswordListExcludeItems =
  | 'ExcludeNotAThing'
  | 'ExcludeNotGettable'
  | 'ExcludeMaybeGettable';

export interface CrosswordListEntry {
  entry: string;
  lang: string;
  classification: string | null;
  unityBucket: string | null;
  familiarityBucket: string | null;
  qualityBucket: string | null;
  crosswordBucket: string | null;
  baseForm: string | null;
  hasAvoidTag: boolean;
  hasSensitiveTag: boolean;
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
    crosswordBucket: row.crossword_bucket ?? null,
    baseForm: row.base_form ?? null,
    hasAvoidTag: Boolean(row.has_avoid_tag),
    hasSensitiveTag: Boolean(row.has_sensitive_tag),
  }));
};

export default getCrosswordListEntries;
