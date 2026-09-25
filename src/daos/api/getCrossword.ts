import {
    ClueCollection,
    CollectionClueWithProgress,
    Entry,
    EntryRef,
    EntryTranslation,
    Sense,
    SenseReference,
} from 'cruzi-models';
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

const mapTranslationRefs = (values: unknown, lang: string): EntryRef[] | undefined => {
    if (!Array.isArray(values)) {
        return undefined;
    }

    const refs = values
        .map((value): EntryRef | null => {
            if (typeof value === 'string') {
                const text = value.trim();
                return text ? { entry: text, lang, displayText: text } : null;
            }
            if (value && typeof value === 'object' && 'entry' in value) {
                const raw = value as { entry?: string; lang?: string; displayText?: string; display_text?: string };
                const entry = raw.entry?.trim();
                if (!entry) return null;
                return {
                    entry,
                    lang: raw.lang || lang,
                    displayText: raw.displayText ?? raw.display_text,
                };
            }
            return null;
        })
        .filter((value): value is EntryRef => value != null);

    return refs.length > 0 ? refs : undefined;
};

const mapSenseTranslations = (raw: any): Record<string, EntryTranslation> | undefined => {
    if (!raw || typeof raw !== 'object') {
        return undefined;
    }

    const translations: Record<string, EntryTranslation> = {};
    for (const [lang, value] of Object.entries(raw)) {
        const row = value as {
            natural_translations?: unknown;
            naturalTranslations?: unknown;
            colloquial_translations?: unknown;
            colloquialTranslations?: unknown;
        } | null;
        translations[lang] = {
            naturalTranslations: mapTranslationRefs(row?.natural_translations ?? row?.naturalTranslations, lang),
            colloquialTranslations: mapTranslationRefs(row?.colloquial_translations ?? row?.colloquialTranslations, lang),
        };
    }

    return Object.keys(translations).length > 0 ? translations : undefined;
};

const mapSenseReferences = (raw: any): SenseReference[] | undefined => {
    if (!Array.isArray(raw) || raw.length === 0) {
        return undefined;
    }

    return raw
        .map((row: any): SenseReference | null => {
            const referenceText = row?.reference_text ?? row?.referenceText;
            if (typeof referenceText !== 'string' || !referenceText.trim()) {
                return null;
            }
            return {
                id: row.id,
                senseId: row.sense_id ?? row.senseId,
                referenceType: row.reference_type ?? row.referenceType,
                referenceText,
                referenceSource: row.reference_source ?? row.referenceSource ?? undefined,
                referenceUrl: row.reference_url ?? row.referenceUrl ?? undefined,
            };
        })
        .filter((row): row is SenseReference => row != null);
};

const mapSenseTags = (raw: any): Record<string, string> | undefined => {
    if (!raw || typeof raw !== 'object' || Array.isArray(raw)) {
        return undefined;
    }

    const tags: Record<string, string> = {};
    for (const [key, value] of Object.entries(raw)) {
        if (!key) continue;
        tags[key] = value == null ? '' : String(value);
    }
    return Object.keys(tags).length > 0 ? tags : undefined;
};

const mapSimilarEntries = (raw: unknown): string[] | undefined => {
    if (!Array.isArray(raw) || raw.length === 0) {
        return undefined;
    }
    const entries = raw
        .map((value) => {
            if (typeof value === 'string') return value.trim();
            if (value && typeof value === 'object' && 'entry' in value) {
                return String((value as { displayText?: string; display_text?: string; entry?: string }).displayText
                    ?? (value as { display_text?: string }).display_text
                    ?? (value as { entry?: string }).entry
                    ?? '').trim();
            }
            return '';
        })
        .filter(Boolean);
    return entries.length > 0 ? entries : undefined;
};

const mapSense = (raw: any, fallbackLang: string): Sense | undefined => {
    if (!raw?.id) {
        return undefined;
    }

    const lang = raw.lang || fallbackLang;
    return {
        id: raw.id,
        entry: {
            entry: raw.entry,
            lang,
            displayText: raw.entry_display_text ?? raw.entryDisplayText,
        },
        displayText: raw.display_text ?? raw.displayText ?? undefined,
        summary: raw.summary ?? undefined,
        definition: raw.definition ?? undefined,
        partOfSpeech: raw.part_of_speech ?? raw.partOfSpeech ?? undefined,
        classification: raw.classification ?? undefined,
        unityBucket: raw.unity_bucket ?? raw.unityBucket ?? undefined,
        familiarityBucket: raw.familiarity_bucket ?? raw.familiarityBucket ?? undefined,
        qualityBucket: raw.quality_bucket ?? raw.qualityBucket ?? undefined,
        domain: raw.domain ?? undefined,
        similarEntries: mapSimilarEntries(raw.similar_entries ?? raw.similarEntries),
        tags: mapSenseTags(raw.tags),
        translations: mapSenseTranslations(raw.translations),
        references: mapSenseReferences(raw.references),
    };
};

const mapCollectionClue = (raw: any): CollectionClueWithProgress => {
    const clueRaw = raw.clue ?? {};
    const entryModel = {
        entry: clueRaw.entry,
        lang: clueRaw.lang,
        displayText: clueRaw.display_text,
        loadingStatus: clueRaw.loading_status,
        baseForm: clueRaw.base_form,
        entryType: clueRaw.entry_type,
        familiarityScore: clueRaw.familiarity_score,
        familiarityBucket: clueRaw.familiarity_bucket,
        qualityScore: clueRaw.quality_score,
        qualityBucket: clueRaw.quality_bucket,
        unityBucket: clueRaw.unity_bucket,
        tags: mapSenseTags(clueRaw.tags),
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
            sense: mapSense(clueRaw.sense, clueRaw.lang),
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
                  authors: puzzleRaw.author?.split(', ') ?? [],
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
