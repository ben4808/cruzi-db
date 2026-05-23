import { Clue, Entry } from 'cruzi-models';
import { sqlQuery } from "../../pool/postgres";
import { mapClueProgressData } from "./mappers";

const getCrosswordClues = async (collectionId: string, userId?: string): Promise<Clue[]> => {
    const result = await sqlQuery(true, 'get_clues', [
        { name: 'p_collection_id', value: collectionId },
        { name: 'p_user_id', value: userId || null }
    ]);

    if (!result || result.length === 0 || !result[0].clues_json) {
        return [];
    }

    const rawData = result[0].clues_json;
    return rawData.map((raw: any) => ({
        id: raw.id,
        entry: {
            entry: raw.entry,
            lang: raw.lang,
            loadingStatus: raw.loading_status,
        } as Entry,
        lang: raw.lang,
        customClue: raw.clue,
        order: raw.collection_order,
        metadata1: raw.metadata1,
        metadata2: raw.metadata2,
        progressData: mapClueProgressData(raw.user_progress),
    } as Clue));
};

export default getCrosswordClues;
