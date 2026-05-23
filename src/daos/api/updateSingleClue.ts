import { Clue } from 'cruzi-models';
import { sqlQuery } from "../../pool/postgres";

const updateSingleClue = async (clue: Clue): Promise<Clue> => {
    const clueData = {
        id: clue.id,
        entry: clue.entry.entry,
        lang: clue.lang,
        sense_id: clue.sense?.id,
        custom_clue: clue.customClue,
        custom_display_text: clue.customDisplayText,
    };

    await sqlQuery(true, 'upsert_single_clue', [
        { name: 'clue_data', value: clueData }
    ]);

    return clue;
};

export default updateSingleClue;
