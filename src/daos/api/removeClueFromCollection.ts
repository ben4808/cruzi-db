import { sqlQuery } from "../../pool/postgres";

const removeClueFromCollection = async (collectionId: string, clueId: string): Promise<void> => {
    await sqlQuery(true, 'remove_clue_from_collection', [
        { name: 'p_collection_id', value: collectionId },
        { name: 'p_clue_id', value: clueId }
    ]);
};

export default removeClueFromCollection;
