import { sqlQuery } from "../../pool/postgres";

const getCrosswordId = async (source: string, date: Date): Promise<string | null> => {
    const result = await sqlQuery(true, 'get_crossword_id', [
        { name: 'p_date', value: date.toISOString().split('T')[0] },
        { name: 'p_publication_id', value: source }
    ]);

    if (!result || result.length === 0 || !result[0].get_crossword_id) {
        return null;
    }

    return result[0].get_crossword_id.collection_id;
};

export default getCrosswordId;
