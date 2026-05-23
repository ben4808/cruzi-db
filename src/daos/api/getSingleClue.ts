import { Clue, Entry, Sense } from 'cruzi-models';
import { sqlQuery } from "../../pool/postgres";

const getSingleClue = async (clueId: string): Promise<Clue | null> => {
    const result = await sqlQuery(true, 'get_single_clue', [
        { name: 'p_clue_id', value: clueId }
    ]);

    if (!result || result.length === 0 || !result[0].get_single_clue) {
        return null;
    }

    const raw = result[0].get_single_clue;
    const entryModel = {
        entry: raw.entry,
        lang: raw.lang,
        loadingStatus: raw.loading_status,
    } as Entry;
    return {
        id: raw.id,
        customClue: raw.custom_clue,
        customDisplayText: raw.custom_display_text,
        entry: entryModel,
        lang: raw.lang,
        sense: raw.sense_id
            ? ({ id: raw.sense_id, entry: entryModel } as Sense)
            : undefined
    } as Clue;
};

export default getSingleClue;
