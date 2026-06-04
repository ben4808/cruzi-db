import { ClueCollection } from 'cruzi-models';
import { sqlQuery } from "../../pool/postgres";
import getCollectionsProgress from "./getCollectionsProgress";
import { mapCreator } from "./mappers";
import { formatDateKey } from '../../lib/dbUtils';

const mapCrosswordCollection = (raw: any, date: Date): ClueCollection => ({
    id: raw.id,
    title: raw.title,
    lang: raw.lang ?? "en",
    author: raw.author,
    description: raw.description,
    createdDate: new Date(raw.created_date),
    modifiedDate: raw.modified_date ? new Date(raw.modified_date) : new Date(raw.created_date),
    source: raw.source,
    isPrivate: raw.is_private ?? false,
    metadata1: raw.metadata1,
    metadata2: raw.metadata2,
    clueCount: raw.clue_count,
    clueCount6Plus: raw.clue_count_6_plus,
    creator: mapCreator(raw.creator),
    puzzle: raw.puzzle_id
        ? {
              id: raw.puzzle_id,
              title: raw.puzzle_title ?? raw.title ?? "",
              publicationId: raw.publication_id,
              date: raw.puzzle_date ? new Date(raw.puzzle_date) : date,
              width: raw.width ?? 0,
              height: raw.height ?? 0,
              authors: raw.puzzle_author?.split(', ') ?? [],
              lang: raw.puzzle_lang ?? raw.lang,
          }
        : undefined,
});

const getCrosswordList = async (date: Date, userId?: string): Promise<ClueCollection[]> => {
    const result = await sqlQuery(true, 'get_crosswords_list', [
        { name: 'p_date', value: formatDateKey(date) }
    ]);

    const rawData = result?.[0]?.get_crosswords_list;
    if (!rawData || rawData.length === 0) {
        return [];
    }

    const collections = rawData.map((raw: any) => mapCrosswordCollection(raw, date));

    if (!userId) {
        return collections;
    }

    const collectionIds = collections
        .map((collection: ClueCollection) => collection.id)
        .filter((id: string | undefined): id is string => !!id);

    const progressByCollectionId = await getCollectionsProgress(userId, collectionIds);

    return collections.map((collection: ClueCollection) => ({
        ...collection,
        progressData: collection.id ? progressByCollectionId.get(collection.id) : undefined,
    }));
};

export default getCrosswordList;
