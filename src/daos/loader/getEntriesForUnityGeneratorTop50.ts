import { sqlQuery } from "../../pool/postgres";

export interface UnityGeneratorSecondaryClass {
  secondaryClass: string;
  secondaryDisplay: string;
  secondaryBaseForm?: string;
}

export interface EntryForUnityGenerator {
  entry: string;
  lang: string;
  displayText: string;
  entryType: string | null;
  secondaryClasses: UnityGeneratorSecondaryClass[];
}

function parseSecondaryClasses(raw: unknown): UnityGeneratorSecondaryClass[] {
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
    }))
    .filter((item) => item.secondaryClass && item.secondaryDisplay);
}

const getEntriesForUnityGeneratorTop50 = async (
  limit: number,
): Promise<EntryForUnityGenerator[]> => {
  const results = await sqlQuery(true, "get_entries_for_unity_generator_top_50", [
    { name: "p_limit", value: limit },
  ]);

  return results.map((row) => ({
    entry: row.entry,
    lang: row.lang,
    displayText: row.display_text,
    entryType: row.entry_type ?? null,
    secondaryClasses: parseSecondaryClasses(row.secondary_classes),
  }));
};

export default getEntriesForUnityGeneratorTop50;
