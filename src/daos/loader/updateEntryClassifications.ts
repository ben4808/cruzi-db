import { sqlQuery } from "../../pool/postgres";

export interface EntryClassificationUpdate {
  entry: string;
  lang: string;
  baseForm: string | null;
  displayText: string | null;
  classification: string | null;
  unityBucket: string | null;
  familiarityBucket: string | null;
  qualityBucket: string | null;
  domain?: string | null;
  isVulgar: boolean | null;
}

const updateEntryClassifications = async (
  updates: EntryClassificationUpdate[],
): Promise<void> => {
  if (updates.length === 0) {
    return;
  }

  const payload = updates.map((update) => ({
    entry: update.entry,
    lang: update.lang,
    base_form: update.baseForm ?? undefined,
    display_text: update.displayText ?? undefined,
    classification: update.classification ?? undefined,
    unity_bucket: update.unityBucket ?? undefined,
    familiarity_bucket: update.familiarityBucket ?? undefined,
    quality_bucket: update.qualityBucket ?? undefined,
    domain: update.domain ?? undefined,
    is_vulgar: update.isVulgar === null || update.isVulgar === undefined
      ? undefined
      : update.isVulgar,
  }));

  await sqlQuery(true, "update_entry_classifications", [
    { name: "p_updates", value: payload },
  ]);
};

export default updateEntryClassifications;
