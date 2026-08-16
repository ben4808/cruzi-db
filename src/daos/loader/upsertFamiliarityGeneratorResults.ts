import { sqlQuery } from "../../pool/postgres";

export interface FamiliarityGeneratorSecondaryClassChange {
  secondaryClass: string;
  secondaryDisplay?: string;
  secondaryBaseForm?: string;
}

export interface FamiliarityGeneratorResult {
  entry: string;
  lang: string;
  familiarityBucket: string;
  familiarityScore: number;
  reviewedStatus?: string;
  displayText?: string;
  entryType?: string;
  baseForm?: string;
  secondaryClassesToDelete?: string[];
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
    display_text: e.displayText ?? undefined,
    entry_type: e.entryType ?? undefined,
    base_form: e.baseForm ?? undefined,
    secondary_classes_to_delete: (e.secondaryClassesToDelete ?? []).map((secondaryClass) => ({
      secondary_class: secondaryClass,
    })),
    secondary_classes_to_insert: (e.secondaryClassesToInsert ?? []).map((sc) => ({
      secondary_class: sc.secondaryClass,
      secondary_display: sc.secondaryDisplay ?? undefined,
      secondary_base_form: sc.secondaryBaseForm ?? undefined,
    })),
  }));

  await sqlQuery(true, "upsert_familiarity_generator_results", [
    { name: "entries_data", value: payload },
  ]);
};

export default upsertFamiliarityGeneratorResults;
