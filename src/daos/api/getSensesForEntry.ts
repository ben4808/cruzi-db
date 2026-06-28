import { Entry, Sense } from 'cruzi-models';
import { deepConvertToObject, pickLocalizedText } from "../../lib/dbUtils";
import { sqlQuery } from "../../pool/postgres";

const getSensesForEntry = async (entry: string, lang: string): Promise<Sense[]> => {
    const result = await sqlQuery(true, 'get_senses_for_entry', [
        { name: 'p_entry', value: entry },
        { name: 'p_lang', value: lang }
    ]);

    if (!result || result.length === 0) {
        return [];
    }

    const entryModel = { entry, lang } as Entry;

    return result.map((row: any) => ({
        id: row.id,
        entry: entryModel,
        partOfSpeech: row.part_of_speech,
        classification: row.classification,
        frequency: row.frequency,
        summary: pickLocalizedText(deepConvertToObject(row.summary)),
        definition: pickLocalizedText(deepConvertToObject(row.definition)),
        similarEntries: row.similar_entries ?? undefined,
        exampleSentences: row.example_sentences || [],
        translations: deepConvertToObject(row.translations),
        sourceAi: row.source_ai,
    } as Sense));
};

export default getSensesForEntry;
