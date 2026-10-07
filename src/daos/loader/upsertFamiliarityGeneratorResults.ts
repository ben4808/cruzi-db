import { sqlQuery } from "../../pool/postgres";

export interface FamiliarityGeneratorSecondaryClassChange {
  secondaryClass: string;
  secondaryDisplay?: string;
  secondaryBaseForm?: string;
  familiarityBucket?: string;
  unityBucket?: string;
}

export interface FamiliarityGeneratorSecondaryClassRef {
  secondaryClass: string;
  secondaryDisplay: string;
}

export interface FamiliarityGeneratorSecondaryClassUpdate extends FamiliarityGeneratorSecondaryClassRef {
  familiarityBucket: string;
  unityBucket?: string;
}

export interface FamiliarityGeneratorResult {
  entry: string;
  lang: string;
  familiarityBucket: string;
  familiarityScore: number;
  reviewedStatus?: string;
  unityBucket?: string;
  unityScore?: number;
  displayText?: string;
  classification?: string;
  baseForm?: string;
  domain?: string;
  secondaryClassesToDelete?: FamiliarityGeneratorSecondaryClassRef[];
  secondaryClassesToUpdate?: FamiliarityGeneratorSecondaryClassUpdate[];
  secondaryClassesToInsert?: FamiliarityGeneratorSecondaryClassChange[];
}

const upsertFamiliarityGeneratorResults = async (
  entries: FamiliarityGeneratorResult[],
): Promise<void> => {
  if (entries.length === 0) {
    return;
  }

  const payload = entries.map((e) => ({
    entry: e.entry,
    lang: e.lang,
    familiarity_bucket: e.familiarityBucket,
    familiarity_score: e.familiarityScore,
    reviewed_status: e.reviewedStatus ?? "123",
    unity_bucket: e.unityBucket ?? undefined,
    unity_score: e.unityScore ?? undefined,
    display_text: e.displayText ?? undefined,
    classification: e.classification ?? undefined,
    base_form: e.baseForm ?? undefined,
    domain: e.domain ?? '',
    secondary_classes_to_delete: (e.secondaryClassesToDelete ?? []).map((sc) => ({
      secondary_class: sc.secondaryClass,
      secondary_display: sc.secondaryDisplay,
    })),
    secondary_classes_to_update: (e.secondaryClassesToUpdate ?? []).map((sc) => ({
      secondary_class: sc.secondaryClass,
      secondary_display: sc.secondaryDisplay,
      familiarity_bucket: sc.familiarityBucket,
      unity_bucket: sc.unityBucket ?? undefined,
    })),
    secondary_classes_to_insert: (e.secondaryClassesToInsert ?? []).map((sc) => ({
      secondary_class: sc.secondaryClass,
      secondary_display: sc.secondaryDisplay ?? undefined,
      secondary_base_form: sc.secondaryBaseForm ?? undefined,
      familiarity_bucket: sc.familiarityBucket ?? undefined,
      unity_bucket: sc.unityBucket ?? undefined,
    })),
  }));

  await sqlQuery(true, "upsert_familiarity_generator_results", [
    { name: "entries_data", value: payload },
  ]);
};

export default upsertFamiliarityGeneratorResults;
