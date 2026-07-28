import { sqlQuery } from "../../pool/postgres";
import { Entry } from "cruzi-models";

const insertEntriesOrFillNulls = async (entries: Entry[]) => {
    const payload = entries.map((e) => ({
        entry: e.entry,
        lang: e.lang,
        length: e.entry.length,
        base_form: e.baseForm ?? undefined,
        display_text: e.displayText ?? undefined,
        entry_type: e.entryType ?? undefined,
        familiarity_bucket: e.familiarityBucket ?? undefined,
        familiarity_score: e.familiarityScore ?? undefined,
        quality_score: e.qualityScore ?? undefined,
        idiomacity_score: e.idiomacityScore ?? undefined,
        unity_bucket: e.unityBucket ?? undefined,
        unity_score: e.unityScore ?? undefined,
        loading_status: e.loadingStatus ?? undefined,
    }));
    await sqlQuery(true, "insert_entries_or_fill_nulls", [{ name: "entries_data", value: payload }]);
};

export default insertEntriesOrFillNulls;
