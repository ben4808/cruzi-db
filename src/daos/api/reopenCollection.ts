import { sqlQuery } from "../../pool/postgres";

const reopenCollection = async (userId: string, collectionId: string): Promise<void> => {
    await sqlQuery(true, 'reopen_collection', [
        { name: 'p_user_id', value: userId },
        { name: 'p_collection_id', value: collectionId }
    ]);
};

export default reopenCollection;
