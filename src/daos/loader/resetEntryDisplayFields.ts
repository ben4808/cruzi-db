import { sqlQuery } from "../../pool/postgres";
import { EntryWithMismatchedDisplayText } from "./getEntriesWithMismatchedDisplayText";

const resetEntryDisplayFields = async (
  entries: EntryWithMismatchedDisplayText[],
): Promise<number> => {
  if (entries.length === 0) {
    return 0;
  }

  const payload = entries.map((entry) => ({
    entry: entry.entry,
    lang: entry.lang,
  }));

  const results = await sqlQuery(true, "reset_entry_display_fields", [
    { name: "p_entries", value: payload },
  ]);

  return Number(results[0]?.reset_entry_display_fields ?? 0);
};

export default resetEntryDisplayFields;
