import { sqlQuery } from "../../pool/postgres";

export interface CrosswordeseOrAbbreviationEntry {
  entry: string;
  lang: string;
  isCrosswordese: boolean;
  isAbbreviation: boolean;
}

function asBoolean(value: unknown): boolean {
  return value === true || value === 'true' || value === 't';
}

const getCrosswordeseAndAbbreviationEntries = async (
  minLength: number = 3,
  maxLength: number = 15,
  lang: string = "en",
): Promise<CrosswordeseOrAbbreviationEntry[]> => {
  const results = await sqlQuery(true, "get_crosswordese_and_abbreviation_entries", [
    { name: "p_min_length", value: minLength },
    { name: "p_max_length", value: maxLength },
    { name: "p_lang", value: lang },
  ]);

  return results.map((row) => ({
    entry: row.entry,
    lang: row.lang,
    isCrosswordese: asBoolean(row.is_crosswordese),
    isAbbreviation: asBoolean(row.is_abbreviation),
  }));
};

export default getCrosswordeseAndAbbreviationEntries;
