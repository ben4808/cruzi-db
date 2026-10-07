import { sqlQuery } from "../../pool/postgres";

export interface UnityGeneratorSecondaryClassRef {
  secondaryClass: string;
  secondaryDisplay: string;
}

export interface UnityGeneratorSecondaryClassUpdate extends UnityGeneratorSecondaryClassRef {
  unityBucket: string;
}

export interface UnityGeneratorResult {
  entry: string;
  lang: string;
  unityBucket: string;
  unityScore: number;
  reviewedStatus?: string;
  displayText?: string;
  classification?: string;
  secondaryClassesToDelete?: UnityGeneratorSecondaryClassRef[];
  secondaryClassesToUpdate?: UnityGeneratorSecondaryClassUpdate[];
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
    classification: e.classification ?? undefined,
    secondary_classes_to_delete: (e.secondaryClassesToDelete ?? []).map((sc) => ({
      secondary_class: sc.secondaryClass,
      secondary_display: sc.secondaryDisplay,
    })),
    secondary_classes_to_update: (e.secondaryClassesToUpdate ?? []).map((sc) => ({
      secondary_class: sc.secondaryClass,
      secondary_display: sc.secondaryDisplay,
      unity_bucket: sc.unityBucket,
    })),
  }));

  await sqlQuery(true, "upsert_unity_generator_results", [
    { name: "entries_data", value: payload },
  ]);
};

export default upsertUnityGeneratorResults;
