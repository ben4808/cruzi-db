import { sqlQuery } from "../../pool/postgres";

export interface SenseWithoutFamiliarity {
  senseId: string;
  entry: string;
  displayText: string;
  lang: string;
  senseSummary: string;
}

const getSensesWithoutFamiliarityTop50 = async (): Promise<SenseWithoutFamiliarity[]> => {
  const results = await sqlQuery(true, "get_senses_without_familiarity_top_50", []);

  return results.map((row) => ({
    senseId: row.sense_id,
    entry: row.entry,
    displayText: row.display_text,
    lang: row.lang,
    senseSummary: row.sense_summary,
  }));
};

export default getSensesWithoutFamiliarityTop50;
