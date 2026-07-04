import { ClueCollection } from 'cruzi-models';
import { sqlQuery } from "../../pool/postgres";
import { mapCollectionProgressData, mapCreator } from "./mappers";

const getCollectionList = async (userId?: string): Promise<ClueCollection[]> => {
    const result = await sqlQuery(true, 'get_clue_collections', [
        { name: 'p_user_id', value: userId || null }
    ]);

    if (!result || result.length === 0 || !result[0].get_clue_collections) {
        return [];
    }

    const rawData = result[0].get_clue_collections;
    return rawData.map((raw: any) => ({
        id: raw.id,
        title: raw.title,
        author: raw.author,
        lang: raw.lang,
        description: raw.description,
        isPrivate: raw.is_private,
        createdDate: new Date(raw.created_date),
        modifiedDate: raw.modified_date ? new Date(raw.modified_date) : new Date(raw.created_date),
        lastAccessedDate: raw.last_accessed ? new Date(raw.last_accessed) : undefined,
        clueCount: raw.clue_count,
        metadata1: raw.metadata1,
        metadata2: raw.metadata2,
        creator: mapCreator(raw.creator),
        progressData: mapCollectionProgressData(raw.user_progress, userId),
        clues: [],
    } as ClueCollection));
};

export default getCollectionList;
