import { CollectionClueTableRow } from 'cruzi-models';
import { sqlQuery } from "../../pool/postgres";

const getCollectionClues = async (
    collectionId: string,
    userId?: string,
    sortBy?: string,
    sortDirection?: string,
    progressFilter?: string,
    statusFilter?: string,
    page?: number
): Promise<CollectionClueTableRow[]> => {
    const result = await sqlQuery(true, 'get_collection_clues', [
        { name: 'p_collection_id', value: collectionId },
        { name: 'p_user_id', value: userId || null },
        { name: 'p_sort_by', value: sortBy || 'Answer' },
        { name: 'p_sort_direction', value: sortDirection || 'asc' },
        { name: 'p_progress_filter', value: progressFilter || null },
        { name: 'p_status_filter', value: statusFilter || null },
        { name: 'p_page', value: page || 1 }
    ]);

    if (!result || result.length === 0 || !result[0].get_collection_clues) {
        return [];
    }

    const rawData = result[0].get_collection_clues;
    return rawData.map((raw: any) => ({
        id: raw.id,
        answer: raw.answer,
        sense: raw.sense,
        clue: raw.clue,
        progress: raw.progress,
        status: raw.status,
        senses: raw.senses || [],
    } as CollectionClueTableRow));
};

export default getCollectionClues;
