import { sqlQuery } from "../../pool/postgres";

export const deleteExampleSentencesForSenses = async (senseIds: string[]): Promise<number> => {
  if (senseIds.length === 0) {
    return 0;
  }

  const results = await sqlQuery(true, "delete_example_sentences_for_senses", [
    { name: "p_sense_ids", value: senseIds },
  ]);

  return Number(results[0]?.delete_example_sentences_for_senses ?? 0);
};
