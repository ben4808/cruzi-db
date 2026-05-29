import { sqlQuery } from "../../pool/postgres";

const getCrosswordCollectionId = async (
    publicationId: string,
    date: Date
): Promise<string | null> => {
    const result = await sqlQuery(true, 'get_crossword_collection_id', [
        { name: 'p_publication_id', value: publicationId },
        { name: 'p_date', value: date.toISOString().split('T')[0] },
    ]);

    if (!result || result.length === 0 || !result[0].get_crossword_collection_id) {
        return null;
    }

    return result[0].get_crossword_collection_id.collection_id;
};

export default getCrosswordCollectionId;
