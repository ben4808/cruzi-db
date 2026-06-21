import { sqlQuery } from "../../pool/postgres";
import { EntryWithLowIdiomacity } from "./getEntriesLowIdiomacityTop150";

const getEntriesLowIdiomacity = async (afterEntry: string): Promise<EntryWithLowIdiomacity[]> => {
  const results = await sqlQuery(true, "get_entries_low_idiomacity", [
    { name: "p_after_entry", value: afterEntry },
  ]);

  return results.map((row) => ({
    entry: row.entry,
    lang: row.lang,
    display_text: row.display_text ?? null,
    entry_type: row.entry_type ?? null,
  }));
};

export default getEntriesLowIdiomacity;
