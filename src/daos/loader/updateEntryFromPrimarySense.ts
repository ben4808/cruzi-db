import { sqlQuery } from "../../pool/postgres";

export const updateEntryFromPrimarySense = async (
  entry: string,
  lang: string,
  displayText: string,
  entryType: string,
  baseForm?: string,
): Promise<void> => {
  await sqlQuery(true, "update_entry_from_primary_sense", [
    { name: "p_entry", value: entry },
    { name: "p_lang", value: lang },
    { name: "p_display_text", value: displayText },
    { name: "p_entry_type", value: entryType },
    { name: "p_base_form", value: baseForm ?? "" },
  ]);
};
