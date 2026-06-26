import { sqlQuery } from "../../pool/postgres";

export interface ScrabbleEntryInsertData {
  entry: string;
  lang: string;
  length?: number;
  display_text?: string;
}

export const insertScrabbleEntries = async (entries: ScrabbleEntryInsertData[]): Promise<void> => {
  if (entries.length === 0) {
    return;
  }

  await sqlQuery(true, "insert_scrabble_entries", [
    { name: "p_entries", value: entries },
  ]);
};
