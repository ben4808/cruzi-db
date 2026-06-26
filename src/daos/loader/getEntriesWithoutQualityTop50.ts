import { sqlQuery } from "../../pool/postgres";

export interface EntryWithoutQuality {
  entry: string;
  lang: string;
  displayText: string;
}

const getEntriesWithoutQualityTop50 = async (): Promise<EntryWithoutQuality[]> => {
  const results = await sqlQuery(true, "get_entries_without_quality_top_50", []);

  return results.map((row) => ({
    entry: row.entry,
    lang: row.lang,
    displayText: row.display_text,
  }));
};

export default getEntriesWithoutQualityTop50;
