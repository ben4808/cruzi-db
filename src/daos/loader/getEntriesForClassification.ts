import { sqlQuery } from "../../pool/postgres";

export interface ClassificationRequest {
  fillWord: string;
  senseId?: string | null;
}

export interface ClassificationEntry {
  fillWord: string;
  entry: string | null;
  lang: string | null;
  displayText: string | null;
  classification: string | null;
  unityBucket: string | null;
  familiarityBucket: string | null;
  qualityBucket: string | null;
  isVulgar: boolean | null;
  isCrosswordese: boolean;
  isBreakfast: boolean;
  isSensitive: boolean;
  nytValue: string | null;
  senseId: string | null;
  senseSummary: string | null;
}

function asBoolean(value: unknown): boolean {
  return value === true || value === 'true' || value === 't';
}

function normalizeItems(
  items: Array<string | ClassificationRequest>,
): ClassificationRequest[] {
  return items
    .map((item) => (
      typeof item === 'string'
        ? { fillWord: item }
        : { fillWord: item.fillWord, senseId: item.senseId }
    ))
    .filter((item) => (item.fillWord || '').trim() !== '');
}

const getEntriesForClassification = async (
  items: Array<string | ClassificationRequest>,
): Promise<ClassificationEntry[]> => {
  const normalized = normalizeItems(items);
  if (normalized.length === 0) {
    return [];
  }

  const results = await sqlQuery(true, "get_entries_for_classification", [
    {
      name: "p_items",
      value: normalized.map((item) => ({
        fill_word: item.fillWord,
        sense_id: item.senseId || undefined,
      })),
    },
  ]);

  return results.map((row) => ({
    fillWord: row.fill_word,
    entry: row.entry ?? null,
    lang: row.lang ?? null,
    displayText: row.display_text ?? null,
    classification: row.classification ?? null,
    unityBucket: row.unity_bucket ?? null,
    familiarityBucket: row.familiarity_bucket ?? null,
    qualityBucket: row.quality_bucket ?? null,
    isVulgar: row.is_vulgar == null ? null : asBoolean(row.is_vulgar),
    isCrosswordese: asBoolean(row.is_crosswordese),
    isBreakfast: asBoolean(row.is_breakfast),
    isSensitive: asBoolean(row.is_sensitive),
    nytValue: row.nyt_value ?? null,
    senseId: row.sense_id ?? null,
    senseSummary: row.sense_summary ?? null,
  }));
};

export default getEntriesForClassification;
