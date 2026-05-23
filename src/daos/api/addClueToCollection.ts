import { Clue } from 'cruzi-models';
import { sqlQuery } from "../../pool/postgres";

const addClueToCollection = async (collectionId: string, clue: Clue): Promise<void> => {
    const clueData = {
        collection_id: collectionId,
        id: clue.id,
        entry: clue.entry.entry,
        lang: clue.lang,
        custom_clue: clue.customClue,
        custom_display_text: clue.customDisplayText,
    };

    await sqlQuery(true, 'add_clues_to_collection', [
        { name: 'clue_data', value: [clueData]}
    ]);
};

export default addClueToCollection;
