import { sqlQuery } from "../../pool/postgres";

export interface CommunityClueItem {
  clue: string;
  timesUsed: number;
}

export interface CommunityClueRecord {
  entry: string;
  clues: CommunityClueItem[];
}

const getCommunityCluesForEntries = async (
  entries: string[],
  lang: string = "en",
): Promise<CommunityClueRecord[]> => {
  const requested = Array.from(new Set(
    entries.map((entry) => entry.trim().toUpperCase()).filter(Boolean),
  ));
  if (requested.length === 0) {
    return [];
  }

  const results = await sqlQuery(true, "get_community_clues_for_entries", [
    { name: "p_entries", value: requested },
    { name: "p_lang", value: lang },
  ]);

  const byEntry = new Map<string, CommunityClueItem[]>();
  requested.forEach((entry) => byEntry.set(entry, []));

  results.forEach((row) => {
    const entry = String(row.entry || "").toUpperCase();
    const clue = String(row.clue || "").trim();
    if (!entry || !clue) return;
    const timesUsed = Number(row.times_used ?? 0);
    const list = byEntry.get(entry) || [];
    const existing = list.find((item) => item.clue === clue);
    if (!existing) list.push({ clue, timesUsed });
    else if (timesUsed > existing.timesUsed) existing.timesUsed = timesUsed;
    byEntry.set(entry, list);
  });

  return Array.from(byEntry.entries()).map(([entry, clues]) => ({
    entry,
    clues: clues.sort((a, b) => b.timesUsed - a.timesUsed),
  }));
};

export default getCommunityCluesForEntries;
