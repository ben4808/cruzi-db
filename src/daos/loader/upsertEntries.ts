import { sqlQuery } from "../../pool/postgres";
import { Entry } from "cruzi-models";

const upsertEntries = async (entries: Entry[]) => {
    const payload = entries.map((e) => ({
        entry: e.entry,
        lang: e.lang,
        length: e.entry.length,
        base_form: e.baseForm ?? undefined,
        display_text: e.displayText ?? undefined,
        entry_type: e.entryType ?? undefined,
        familiarity_score: e.familiarityScore ?? undefined,
        quality_score: e.qualityScore ?? undefined,
        idiomacity_score: e.idiomacityScore ?? undefined,
        unity_bucket: e.unityBucket ?? undefined,
        loading_status: e.loadingStatus ?? undefined,
    }));
    await sqlQuery(true, "upsert_entries", [{ name: "entries_data", value: payload }]);
};

export default upsertEntries;
