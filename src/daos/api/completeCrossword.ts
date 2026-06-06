import { sqlQuery } from "../../pool/postgres";

const completeCrossword = async (userId: string, collectionId: string): Promise<void> => {
    await sqlQuery(true, 'complete_crossword', [
        { name: 'p_user_id', value: userId },
        { name: 'p_collection_id', value: collectionId },
    ]);
};

export default completeCrossword;
