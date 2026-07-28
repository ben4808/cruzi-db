import { sqlQuery } from "../../pool/postgres";
import { EntryKey } from "./updateEntriesLoadingStatus";

const deleteEntries = async (entries: EntryKey[]): Promise<number> => {
  if (entries.length === 0) {
    return 0;
  }

  const payload = entries.map((e) => ({
    entry: e.entry,
    lang: e.lang,
  }));

  const results = await sqlQuery(true, "delete_entries", [
    { name: "p_entries", value: payload },
  ]);

  return Number(results[0]?.delete_entries ?? 0);
};

export default deleteEntries;
export { deleteEntries };
