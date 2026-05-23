import { ClueCollection } from 'cruzi-models';
import { sqlQuery } from "../../pool/postgres";
import { mapCollectionProgressData, mapCreator } from "./mappers";

const getCollectionById = async (collectionId: string, userId?: string): Promise<ClueCollection | null> => {
    const result = await sqlQuery(true, 'get_collection_by_id', [
        { name: 'p_collection_id', value: collectionId },
        { name: 'p_user_id', value: userId || null }
    ]);

    if (!result || result.length === 0 || !result[0].get_collection_by_id) {
        return null;
    }

    const raw = result[0].get_collection_by_id;
    return {
        id: raw.id,
        title: raw.title,
        author: raw.author,
        lang: raw.lang,
        description: raw.description,
        isPrivate: raw.is_private,
        createdDate: new Date(raw.created_date),
        modifiedDate: raw.modified_date ? new Date(raw.modified_date) : new Date(raw.created_date),
        clueCount: raw.clue_count,
        metadata1: raw.metadata1,
        metadata2: raw.metadata2,
        creator: mapCreator(raw.creator),
        progressData: mapCollectionProgressData(raw.user_progress, userId),
        clues: [],
    } as ClueCollection;
};

export default getCollectionById;
