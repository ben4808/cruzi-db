import { sqlQuery } from "../../pool/postgres";

export interface SenseFamiliarityScoreUpdate {
  senseId: string;
  familiarityScore: number;
}

export const updateSenseFamiliarityScores = async (
  updates: SenseFamiliarityScoreUpdate[],
): Promise<void> => {
  const payload = updates.map((update) => ({
    sense_id: update.senseId,
    familiarity_score: update.familiarityScore,
  }));

  await sqlQuery(true, "update_sense_familiarity_scores", [
    { name: "scores_data", value: payload },
  ]);
};
