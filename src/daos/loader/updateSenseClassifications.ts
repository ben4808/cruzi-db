import { sqlQuery } from "../../pool/postgres";

export interface SenseClassificationUpdate {
  senseId: string;
  displayText: string | null;
  classification: string | null;
  unityBucket: string | null;
  familiarityBucket: string | null;
  qualityBucket: string | null;
  domain: string | null;
}

const updateSenseClassifications = async (
  updates: SenseClassificationUpdate[],
): Promise<void> => {
  if (updates.length === 0) {
    return;
  }

  const payload = updates.map((update) => ({
    sense_id: update.senseId,
    display_text: update.displayText ?? undefined,
    classification: update.classification ?? undefined,
    unity_bucket: update.unityBucket ?? undefined,
    familiarity_bucket: update.familiarityBucket ?? undefined,
    quality_bucket: update.qualityBucket ?? undefined,
    domain: update.domain ?? undefined,
  }));

  await sqlQuery(true, "update_sense_classifications", [
    { name: "p_updates", value: payload },
  ]);
};

export default updateSenseClassifications;
