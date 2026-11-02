import { sqlQuery } from "../../pool/postgres";

export interface GeneratedClueRecord {
  clue: string;
  clueType: string | null;
  isSeedword: boolean;
  timesUsed: number;
}

export interface EntryClueStatus {
  entry: string;
  displayText: string | null;
  cluesGenerated: boolean;
  clues: GeneratedClueRecord[];
}

function asBoolean(value: unknown): boolean {
  return value === true || value === "true" || value === "t";
}

const getGeneratedCluesForEntries = async (
  entries: string[],
  lang: string = "en",
): Promise<EntryClueStatus[]> => {
  const requested = Array.from(new Set(
    entries.map((entry) => entry.trim().toUpperCase()).filter(Boolean),
  ));
  if (requested.length === 0) {
    return [];
  }

  const results = await sqlQuery(true, "get_generated_clues_for_entries", [
    { name: "p_entries", value: requested },
    { name: "p_lang", value: lang },
  ]);

  const byEntry = new Map<string, EntryClueStatus>();
  requested.forEach((entry) => {
    byEntry.set(entry, {
      entry,
      displayText: null,
      cluesGenerated: false,
      clues: [],
    });
  });

  results.forEach((row) => {
    const entry = String(row.entry || "").toUpperCase();
    if (!entry) return;
    const status = byEntry.get(entry) || {
      entry,
      displayText: null,
      cluesGenerated: false,
      clues: [],
    };
    if (row.display_text) status.displayText = row.display_text;
    status.cluesGenerated = status.cluesGenerated || asBoolean(row.clues_generated);
    if (row.generated_clue) {
      status.clues.push({
        clue: row.generated_clue,
        clueType: row.clue_type ?? null,
        isSeedword: asBoolean(row.is_seedword),
        timesUsed: Number(row.times_used ?? 0),
      });
    }
    byEntry.set(entry, status);
  });

  return Array.from(byEntry.values());
};

export default getGeneratedCluesForEntries;
