import { sqlQuery } from "../../pool/postgres";

export interface ExistingSenseInfo {
  id: string;
  summary: string;
}

export interface EntryForSensesGenerator {
  entry: string;
  lang: string;
  displayText: string;
  existingSenses: ExistingSenseInfo[];
}

function parseExistingSenses(raw: unknown): ExistingSenseInfo[] {
  const items = typeof raw === "string" ? JSON.parse(raw) : raw;
  if (!Array.isArray(items)) {
    return [];
  }

  return items
    .map((item) => ({
      id: String(item.id ?? "").trim(),
      summary: String(item.summary ?? "").trim(),
    }))
    .filter((item) => item.id !== "");
}

const getEntriesForSensesGenerator = async (
  lang: string,
  length: number,
  limit: number,
  existingOnly: boolean,
  combos: string[] = [],
): Promise<EntryForSensesGenerator[]> => {
  if (limit <= 0 || length <= 0) {
    return [];
  }
  if (!existingOnly && combos.length === 0) {
    return [];
  }

  const results = await sqlQuery(true, "get_entries_for_senses_generator", [
    { name: "p_lang", value: lang },
    { name: "p_length", value: length },
    { name: "p_limit", value: limit },
    { name: "p_existing_only", value: existingOnly },
    { name: "p_combos", value: combos },
  ]);

  return results.map((row) => ({
    entry: row.entry,
    lang: row.lang,
    displayText: row.display_text,
    existingSenses: parseExistingSenses(row.existing_senses),
  }));
};

export default getEntriesForSensesGenerator;
