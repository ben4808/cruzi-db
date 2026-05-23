import { sqlQuery } from "../../pool/postgres";

const selectCollectionBatch = async (userId: string | undefined, collectionId: string): Promise<string[]> => {
    const result = await sqlQuery(true, 'select_collection_batch', [
        { name: 'p_collection_id', value: collectionId },
        { name: 'p_user_id', value: userId || null }
    ]);

    if (!result || result.length === 0 || !result[0].select_collection_batch) {
        return [];
    }

    return result[0].select_collection_batch;
};

export default selectCollectionBatch;
