import { sqlQuery } from "../../pool/postgres";

export interface UnityGeneratorResult {
  entry: string;
  lang: string;
  unityBucket: string;
  unityScore: number;
  reviewedStatus?: string;
  displayText?: string;
  entryType?: string;
  secondaryClassesToDelete?: string[];
}

const upsertUnityGeneratorResults = async (
  entries: UnityGeneratorResult[],
): Promise<void> => {
  if (entries.length === 0) {
    return;
  }

  const payload = entries.map((e) => ({
    entry: e.entry,
    lang: e.lang,
    unity_bucket: e.unityBucket,
    unity_score: e.unityScore,
    reviewed_status: e.reviewedStatus ?? "12",
    display_text: e.displayText ?? undefined,
    entry_type: e.entryType ?? undefined,
    secondary_classes_to_delete: (e.secondaryClassesToDelete ?? []).map((secondaryClass) => ({
      secondary_class: secondaryClass,
    })),
  }));

  await sqlQuery(true, "upsert_unity_generator_results", [
    { name: "entries_data", value: payload },
  ]);
};

export default upsertUnityGeneratorResults;
