import { CollectionProgress } from 'cruzi-models';
import { sqlQuery } from "../../pool/postgres";
import { mapCollectionProgressData } from "./mappers";

const getCollectionsProgress = async (
    userId: string,
    collectionIds: string[]
): Promise<Map<string, CollectionProgress>> => {
    if (collectionIds.length === 0) {
        return new Map();
    }

    const result = await sqlQuery(true, 'get_collections_progress', [
        { name: 'p_user_id', value: userId },
        { name: 'p_collection_ids', value: collectionIds },
    ]);

    const rawData = result?.[0]?.get_collections_progress ?? [];
    const progressByCollectionId = new Map<string, CollectionProgress>();

    for (const raw of rawData) {
        const progress = mapCollectionProgressData(raw, userId);
        if (progress && raw.collection_id) {
            progressByCollectionId.set(raw.collection_id, progress);
        }
    }

    return progressByCollectionId;
};

export default getCollectionsProgress;
