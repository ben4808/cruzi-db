import { Entry, Sense } from 'cruzi-models';
import { deepConvertToObject } from "../../lib/dbUtils";
import { sqlQuery } from "../../pool/postgres";

const addOrUpdateSense = async (entry: Entry, sense: Sense): Promise<void> => {
    const senseData = deepConvertToObject({
        id: sense.id,
        part_of_speech: sense.partOfSpeech,
        classification: sense.classification,
        frequency: sense.frequency,
        summary: sense.summary,
        definition: sense.definition,
        similar_entries: sense.similarEntries,
        example_sentences: sense.exampleSentences,
        translations: sense.translations,
        source_ai: sense.sourceAi,
    });

    console.log(JSON.stringify(senseData, null, 2));

    await sqlQuery(true, 'upsert_sense', [
        { name: 'p_entry', value: entry.entry },
        { name: 'p_lang', value: entry.lang },
        { name: 'sense_data', value: senseData as object },
    ]);
};

export default addOrUpdateSense;
