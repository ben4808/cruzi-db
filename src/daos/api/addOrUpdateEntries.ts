import { Entry } from 'cruzi-models';
import { sqlQuery } from "../../pool/postgres";

const addOrUpdateEntries = async (entries: Entry[]): Promise<void> => {
    const entryData = entries.map(entry => ({
        entry: entry.entry,
        lang: entry.lang,
        length: entry.entry.length,
        base_form: entry.baseForm,
        display_text: entry.displayText,
        entry_type: entry.entryType,
        loading_status: entry.loadingStatus,
    }));

    await sqlQuery(true, 'upsert_entries', [
        { name: 'entries_data', value: entryData }
    ]);
};

export default addOrUpdateEntries;
