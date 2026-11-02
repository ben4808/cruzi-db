import { sqlQuery } from "../../pool/postgres";

const incrementDontUseTags = async (entries: string[], lang: string = "en"): Promise<number> => {
  const unique = [...new Set(entries.map((entry) => entry.trim()).filter(Boolean))];
  if (unique.length === 0) {
    return 0;
  }

  const results = await sqlQuery(
    false,
    "SELECT increment_dont_use_tags($1::jsonb, $2::text) AS increment_dont_use_tags",
    [
      { name: "p_entries", value: unique },
      { name: "p_lang", value: lang },
    ],
  );

  return Number(results[0]?.increment_dont_use_tags ?? 0);
};

export default incrementDontUseTags;
