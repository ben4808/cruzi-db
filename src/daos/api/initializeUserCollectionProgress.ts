import { sqlQuery } from "../../pool/postgres";

const initializeUserCollectionProgress = async (userId: string, collectionId: string): Promise<void> => {
    await sqlQuery(true, 'initialize_user_collection_progress', [
        { name: 'p_user_id', value: userId },
        { name: 'p_collection_id', value: collectionId }
    ]);
};

export default initializeUserCollectionProgress;
