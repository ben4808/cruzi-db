import { sqlQuery } from "../../pool/postgres";

export interface ClassificationSense {
  senseId: string;
  summary: string;
  displayText: string;
  entryType: string;
  unityBucket: string;
  familiarityBucket: string;
  qualityBucket: string;
  domain: string;
  regionality: string;
  isVulgar: boolean;
  isSensitive: boolean;
}

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
  domain: string | null;
  regionality: string | null;
  isVulgar: boolean | null;
  isCrosswordese: boolean;
  isBreakfast: boolean;
  isSensitive: boolean;
  nytValue: string | null;
  senses: ClassificationSense[];
}

function asText(value: unknown): string {
  return value == null ? '' : String(value);
}

function asBoolean(value: unknown): boolean {
  return value === true || value === 'true' || value === 't';
}

function parseSenses(raw: unknown): ClassificationSense[] {
  let items: unknown[] = [];
  if (typeof raw === 'string') {
    try {
      const parsed = JSON.parse(raw);
      items = Array.isArray(parsed) ? parsed : [];
    } catch {
      items = [];
    }
  } else if (Array.isArray(raw)) {
    items = raw;
  }

  return items
    .map((item) => {
      const row = (item ?? {}) as Record<string, unknown>;
      return {
        senseId: asText(row.id || row.senseId).trim(),
        summary: asText(row.summary),
        displayText: asText(row.display_text ?? row.displayText),
        entryType: asText(row.classification ?? row.entryType),
        unityBucket: asText(row.unity_bucket ?? row.unityBucket),
        familiarityBucket: asText(row.familiarity_bucket ?? row.familiarityBucket),
        qualityBucket: asText(row.quality_bucket ?? row.qualityBucket),
        domain: asText(row.domain),
        regionality: asText(row.regionality),
        isVulgar: asBoolean(row.is_vulgar ?? row.isVulgar),
        isSensitive: asBoolean(row.is_sensitive ?? row.isSensitive),
      };
    })
    .filter((sense) => sense.senseId !== '');
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
    domain: row.domain ?? null,
    regionality: row.regionality ?? null,
    isVulgar: row.is_vulgar ?? null,
    isCrosswordese: row.is_crosswordese === true,
    isBreakfast: row.is_breakfast === true,
    isSensitive: row.is_sensitive === true,
    nytValue: row.nyt_value ?? null,
    senses: parseSenses(row.senses),
  }));
};

export default getEntriesForClassification;
