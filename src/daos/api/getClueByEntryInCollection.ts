import { Clue, Entry, Sense } from 'cruzi-models';
import { sqlQuery } from "../../pool/postgres";

const getClueByEntryInCollection = async (collectionId: string, entry: string, lang: string): Promise<Clue | null> => {
    const result = await sqlQuery(true, 'get_clue_by_entry_in_collection', [
        { name: 'p_collection_id', value: collectionId },
        { name: 'p_entry', value: entry },
        { name: 'p_lang', value: lang }
    ]);

    if (!result || result.length === 0 || !result[0].get_clue_by_entry_in_collection || result[0].get_clue_by_entry_in_collection.length === 0) {
        return null;
    }

    const row = result[0].get_clue_by_entry_in_collection[0];
    const entryModel = {
        entry: row.entry,
        lang: row.lang,
    } as Entry;
    return {
        id: row.id,
        entry: entryModel,
        lang: row.lang,
        sense: row.sense_id ? ({ id: row.sense_id, entry: entryModel } as Sense) : undefined,
        customClue: row.custom_clue,
        customDisplayText: row.custom_display_text,
    } as Clue;
};

export default getClueByEntryInCollection;
