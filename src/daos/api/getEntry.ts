import { Entry, Sense } from 'cruzi-models';
import { pickLocalizedText } from "../../lib/dbUtils";
import { sqlQuery } from "../../pool/postgres";

const getEntry = async (entry: string): Promise<Entry | null> => {
    const result = await sqlQuery(true, 'get_entry', [
        { name: 'p_entry', value: entry }
    ]);

    if (!result || result.length === 0 || !result[0].get_entry) {
        return null;
    }

    const raw = result[0].get_entry;
    const baseEntry: Entry = {
        entry: raw.entry,
        lang: raw.lang,
        displayText: raw.display_text,
        entryType: raw.entry_type,
        familiarityScore: raw.familiarity_score,
        qualityScore: raw.quality_score,
        loadingStatus: raw.loading_status,
    };

    const sensesMap = new Map<string, Sense>();
    for (const sense of raw.senses || []) {
        sensesMap.set(sense.id, {
            id: sense.id,
            entry: baseEntry,
            summary: pickLocalizedText(sense.summary),
            definition: pickLocalizedText(sense.definition),
            familiarityScore: sense.familiarity_score,
            qualityScore: sense.quality_score,
            sourceAi: sense.source_ai,
            exampleSentences: (sense.example_sentences || []).map((ex: any) => ({
                id: ex.id,
                senseId: sense.id,
                translations: ex.sentence
                    ? new Map([[raw.lang, ex.sentence]])
                    : undefined,
                source_ai: ex.source_ai,
            })),
        } as Sense);
    }

    return {
        ...baseEntry,
        senses: sensesMap,
    } as unknown as Entry;
};

export default getEntry;
