import { sqlQuery } from "../../pool/postgres";
import { Entry } from "cruzi-models";

const upsertEntryImproverResults = async (entries: Entry[]): Promise<void> => {
  const payload = entries.map((e) => ({
    entry: e.entry,
    lang: e.lang,
    length: e.entry.length,
    entry_type: e.entryType ?? undefined,
    display_text: e.displayText ?? undefined,
    base_form: e.baseForm ?? undefined,
    unity_bucket: e.unityBucket ?? undefined,
    unity_score: e.unityScore ?? undefined,
    familiarity_bucket: e.familiarityBucket ?? undefined,
    familiarity_score: e.familiarityScore ?? undefined,
    quality_bucket: e.qualityBucket ?? undefined,
    quality_score: e.qualityScore ?? undefined,
    is_vulgar: e.isVulgar ?? undefined,
    reviewed_status: e.reviewedStatus ?? "R",
  }));

  await sqlQuery(true, "upsert_entry_improver_results", [
    { name: "entries_data", value: payload },
  ]);
};

export default upsertEntryImproverResults;
