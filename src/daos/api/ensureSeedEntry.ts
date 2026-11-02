import { sqlQuery } from "../../pool/postgres";

/** Insert a missing seed answer with default entry fields and a seed_answer tag. */
const ensureSeedEntry = async (
  displayText: string,
  entry: string,
  lang: string = "en",
): Promise<boolean> => {
  const results = await sqlQuery(true, "ensure_seed_entry", [
    { name: "p_display_text", value: displayText },
    { name: "p_entry", value: entry },
    { name: "p_lang", value: lang },
  ]);

  return results[0]?.ensure_seed_entry === true;
};

export default ensureSeedEntry;
