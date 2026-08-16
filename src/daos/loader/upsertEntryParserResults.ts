import { sqlQuery } from "../../pool/postgres";

export interface EntryParserSecondaryClass {
  secondaryClass: string;
  secondaryDisplay: string;
  secondaryBaseForm?: string;
}

export interface EntryParserResult {
  entry: string;
  lang: string;
  displayText: string;
  entryType: string;
  baseForm?: string;
  isVulgar: boolean;
  reviewedStatus?: string;
  secondaryClasses?: EntryParserSecondaryClass[];
}

const upsertEntryParserResults = async (entries: EntryParserResult[]): Promise<void> => {
  if (entries.length === 0) {
    return;
  }

  const payload = entries.map((e) => ({
    entry: e.entry,
    lang: e.lang,
    display_text: e.displayText,
    entry_type: e.entryType,
    base_form: e.baseForm ?? undefined,
    is_vulgar: e.isVulgar,
    reviewed_status: e.reviewedStatus ?? "1",
    secondary_classes: (e.secondaryClasses ?? []).map((sc) => ({
      secondary_class: sc.secondaryClass,
      secondary_display: sc.secondaryDisplay,
      secondary_base_form: sc.secondaryBaseForm ?? undefined,
    })),
  }));

  await sqlQuery(true, "upsert_entry_parser_results", [
    { name: "entries_data", value: payload },
  ]);
};

export default upsertEntryParserResults;
