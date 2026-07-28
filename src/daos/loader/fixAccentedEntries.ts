import { sqlQuery } from "../../pool/postgres";
import { EntryWithAccent } from "./getEntriesWithAccents";

const fixAccentedEntries = async (
  entries: EntryWithAccent[],
): Promise<number> => {
  if (entries.length === 0) {
    return 0;
  }

  const payload = entries.map((entry) => ({
    entry: entry.entry,
    lang: entry.lang,
  }));

  const results = await sqlQuery(true, "fix_accented_entries", [
    { name: "p_entries", value: payload },
  ]);

  return Number(results[0]?.fix_accented_entries ?? 0);
};

export default fixAccentedEntries;
