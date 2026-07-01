import { sqlQuery } from "../../pool/postgres";

export interface SenseWithoutExampleSentences {
  senseId: string;
  entry: string;
  displayText: string;
  lang: string;
  senseSummary: string;
}

const getSensesWithoutExampleSentencesTop10 = async (): Promise<SenseWithoutExampleSentences[]> => {
  const results = await sqlQuery(true, "get_senses_without_example_sentences_top_10", []);

  return results.map((row) => ({
    senseId: row.sense_id,
    entry: row.entry,
    displayText: row.display_text,
    lang: row.lang,
    senseSummary: row.sense_summary,
  }));
};

export default getSensesWithoutExampleSentencesTop10;
