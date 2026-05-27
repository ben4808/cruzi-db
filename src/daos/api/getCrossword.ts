import { ClueCollection, CollectionClueWithProgress, Entry } from 'cruzi-models';
import { sqlQuery } from "../../pool/postgres";
import { mapCollectionProgressData, mapCreator } from "./mappers";

const mapClueProgress = (progress: any) => {
    if (!progress) {
        return undefined;
    }

    return {
        hintsUsed: progress.hints_used ?? 0,
    };
};

const mapCollectionClue = (raw: any): CollectionClueWithProgress => {
    const clueRaw = raw.clue ?? {};
    const entryModel = {
        entry: clueRaw.entry,
        lang: clueRaw.lang,
        displayText: clueRaw.display_text,
        loadingStatus: clueRaw.loading_status,
        rootEntry: clueRaw.root_entry,
        entryType: clueRaw.entry_type,
        familiarityScore: clueRaw.familiarity_score,
        qualityScore: clueRaw.quality_score,
    } as Entry;

    return {
        order: raw.order,
        metadata1: raw.metadata1,
        metadata2: raw.metadata2,
        clue: {
            id: clueRaw.id,
            entry: entryModel,
            lang: clueRaw.lang,
            customClue: clueRaw.custom_clue,
            customDisplayText: clueRaw.custom_display_text,
            progressData: mapClueProgress(clueRaw.user_progress),
        },
    };
};

const getCrossword = async (collectionId: string, userId?: string): Promise<ClueCollection | null> => {
    const result = await sqlQuery(true, 'get_crossword', [
        { name: 'p_collection_id', value: collectionId },
        { name: 'p_user_id', value: userId ?? null },
    ]);

    const raw = result?.[0]?.get_crossword;
    if (!raw) {
        return null;
    }

    const puzzleRaw = raw.puzzle;
    const puzzleDate = puzzleRaw?.date ? new Date(puzzleRaw.date) : new Date(raw.created_date);

    return {
        id: raw.id,
        title: raw.title,
        lang: raw.lang ?? 'en',
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
        progressData: mapCollectionProgressData(raw.user_progress, userId),
        puzzle: puzzleRaw
            ? {
                  id: puzzleRaw.id,
                  title: puzzleRaw.title ?? raw.title ?? '',
                  publicationId: puzzleRaw.publication_id,
                  date: puzzleDate,
                  width: puzzleRaw.width ?? 0,
                  height: puzzleRaw.height ?? 0,
                  author: puzzleRaw.author,
                  copyright: puzzleRaw.copyright,
                  notes: puzzleRaw.notes,
                  lang: puzzleRaw.lang ?? raw.lang,
                  sourceLink: puzzleRaw.source_link,
              }
            : undefined,
        clues: (raw.clues ?? []).map(mapCollectionClue),
    } as ClueCollection;
};

export default getCrossword;
