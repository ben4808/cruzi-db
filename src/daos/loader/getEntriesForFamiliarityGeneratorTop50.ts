import { sqlQuery } from "../../pool/postgres";

export interface FamiliarityGeneratorSecondaryClass {
  secondaryClass: string;
  secondaryDisplay: string;
  secondaryBaseForm?: string;
  unityBucket?: string;
}

export interface EntryForFamiliarityGenerator {
  entry: string;
  lang: string;
  displayText: string;
  entryType: string | null;
  baseForm?: string;
  unityBucket: string | null;
  secondaryClasses: FamiliarityGeneratorSecondaryClass[];
}

function parseSecondaryClasses(raw: unknown): FamiliarityGeneratorSecondaryClass[] {
  const items = typeof raw === "string" ? JSON.parse(raw) : raw;
  if (!Array.isArray(items)) {
    return [];
  }

  return items
    .map((item) => ({
      secondaryClass: String(item.secondary_class ?? "").trim(),
      secondaryDisplay: String(item.secondary_display ?? "").trim(),
      secondaryBaseForm: item.secondary_base_form
        ? String(item.secondary_base_form).trim()
        : undefined,
      unityBucket: item.unity_bucket
        ? String(item.unity_bucket).trim()
        : undefined,
    }))
    .filter((item) => item.secondaryClass && item.secondaryDisplay);
}

const getEntriesForFamiliarityGeneratorTop50 = async (
  limit: number,
): Promise<EntryForFamiliarityGenerator[]> => {
  const results = await sqlQuery(true, "get_entries_for_familiarity_generator_top_50", [
    { name: "p_limit", value: limit },
  ]);

  return results.map((row) => ({
    entry: row.entry,
    lang: row.lang,
    displayText: row.display_text,
    entryType: row.entry_type ?? null,
    baseForm: row.base_form ? String(row.base_form) : undefined,
    unityBucket: row.unity_bucket ?? null,
    secondaryClasses: parseSecondaryClasses(row.secondary_classes),
  }));
};

export default getEntriesForFamiliarityGeneratorTop50;
