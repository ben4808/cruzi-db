import { sqlQuery } from "../../pool/postgres";

export interface PrimaryNounSenseLowFamiliarity {
  senseId: string;
  entry: string;
  displayText: string;
  lang: string;
  senseSummary: string;
}

const getPrimaryNounSensesLowFamiliarity = async (): Promise<PrimaryNounSenseLowFamiliarity[]> => {
  const results = await sqlQuery(true, "get_primary_noun_senses_low_familiarity", []);

  return results.map((row) => ({
    senseId: row.sense_id,
    entry: row.entry,
    displayText: row.display_text,
    lang: row.lang,
    senseSummary: row.sense_summary,
  }));
};

export default getPrimaryNounSensesLowFamiliarity;
