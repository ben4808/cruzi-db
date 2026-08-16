import { sqlQuery } from "../../pool/postgres";

export interface EntryForEntryParser {
  entry: string;
  lang: string;
}

const getEntriesForEntryParserTop50 = async (
  limit: number,
): Promise<EntryForEntryParser[]> => {
  const results = await sqlQuery(true, "get_entries_for_entry_parser_top_50", [
    { name: "p_limit", value: limit },
  ]);

  return results.map((row) => ({
    entry: row.entry,
    lang: row.lang,
  }));
};

export default getEntriesForEntryParserTop50;
