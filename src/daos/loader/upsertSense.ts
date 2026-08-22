import { Sense } from 'cruzi-models';
import { deepConvertToObject } from '../../lib/dbUtils';
import { sqlQuery } from '../../pool/postgres';

export const upsertSense = async (entry: string, lang: string, sense: Sense): Promise<void> => {
  const senseData = deepConvertToObject({
    id: sense.id,
    part_of_speech: sense.partOfSpeech,
    classification: sense.classification,
    frequency: sense.frequency,
    summary: sense.summary,
    definition: sense.definition,
    similar_entries: sense.similarEntries,
    translations: sense.translations,
    source_ai: sense.sourceAi,
    ...(sense.displayText !== undefined ? { display_text: sense.displayText } : {}),
    ...(sense.baseForm !== undefined ? { base_form: sense.baseForm } : {}),
    ...(sense.inflections !== undefined ? { inflections: sense.inflections } : {}),
    ...(sense.exampleSentences !== undefined ? { example_sentences: sense.exampleSentences } : {}),
  });

  await sqlQuery(true, 'upsert_sense', [
    { name: 'p_entry', value: entry },
    { name: 'p_lang', value: lang },
    { name: 'sense_data', value: senseData as object },
  ]);
};
