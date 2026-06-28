import { Clue, Entry, Sense } from 'cruzi-models';
import { pickLocalizedText } from "../../lib/dbUtils";
import { sqlQuery } from "../../pool/postgres";
import { mapClueProgressData } from "./mappers";

const transformExampleSentences = (exampleSentences: any[]): any[] => {
    if (!exampleSentences || !Array.isArray(exampleSentences)) {
        return [];
    }

    const grouped = new Map<string, { _id: string; [lang: string]: string | undefined }>();

    for (const ex of exampleSentences) {
        if (!ex.id || !ex.lang || !ex.sentence) continue;

        if (!grouped.has(ex.id)) {
            grouped.set(ex.id, { _id: ex.id });
        }

        const example = grouped.get(ex.id)!;
        const lang = ex.lang;
        const sentence = ex.sentence;

        example[lang] = sentence;
    }

    return Array.from(grouped.values());
};

const populateCollectionBatch = async (clueIds: string[], userId?: string): Promise<Clue[]> => {
    const result = await sqlQuery(true, 'populate_collection_batch', [
        { name: 'p_clue_ids', value: clueIds },
        { name: 'p_user_id', value: userId || null }
    ]);

    if (!result || result.length === 0 || !result[0].populate_collection_batch) {
        return [];
    }

    const rawData = result[0].populate_collection_batch;

    const clueMap = new Map<string, any>();
    for (const raw of rawData) {
        clueMap.set(raw.id, raw);
    }

    return clueIds.map((clueId: string) => {
        const raw = clueMap.get(clueId);
        if (!raw) {
            return {
                id: clueId,
                entry: { entry: "", lang: "" },
                lang: "",
            } as Clue;
        }

        const entryModel = {
            entry: raw.entry,
            lang: raw.lang,
            displayText: raw.display_text,
            loadingStatus: raw.loading_status,
        } as Entry;

        return {
            id: raw.id,
            entry: entryModel,
            lang: raw.lang,
            sense: raw.sense
                ? ({
                      id: raw.sense.id,
                      entry: entryModel,
                      partOfSpeech: raw.sense.partOfSpeech,
                      classification: raw.sense.classification,
                      frequency: raw.sense.frequency,
                      summary: pickLocalizedText(raw.sense.summary),
                      definition: pickLocalizedText(raw.sense.definition),
                      exampleSentences: transformExampleSentences(
                          raw.sense.exampleSentences
                      ) as Sense["exampleSentences"],
                      familiarityScore: raw.sense.familiarityScore,
                      qualityScore: raw.sense.qualityScore,
                      sourceAi: raw.sense.sourceAi,
                  } as Sense)
                : undefined,
            customClue: raw.custom_clue,
            customDisplayText: raw.custom_display_text,
            progressData: raw.progress_data ? mapClueProgressData(raw.progress_data) : undefined,
        } as Clue;
    });
};

export default populateCollectionBatch;
