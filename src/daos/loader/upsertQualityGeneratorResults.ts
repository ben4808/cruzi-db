import { sqlQuery } from "../../pool/postgres";

export interface QualityGeneratorResult {
  entry: string;
  lang: string;
  qualityBucket: string;
  qualityScore: number;
  reviewedStatus?: string;
}

const upsertQualityGeneratorResults = async (
  entries: QualityGeneratorResult[],
): Promise<void> => {
  if (entries.length === 0) {
    return;
  }

  const payload = entries.map((e) => ({
    entry: e.entry,
    lang: e.lang,
    quality_bucket: e.qualityBucket,
    quality_score: e.qualityScore,
    reviewed_status: e.reviewedStatus ?? "1234",
  }));

  await sqlQuery(true, "upsert_quality_generator_results", [
    { name: "entries_data", value: payload },
  ]);
};

export default upsertQualityGeneratorResults;
