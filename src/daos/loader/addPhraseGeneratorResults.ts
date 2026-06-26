import { sqlQuery } from '../../pool/postgres';

const addPhraseGeneratorResults = async (queueId: number, phrases: string[]): Promise<void> => {
  if (phrases.length === 0) {
    return;
  }

  await sqlQuery(true, 'add_phrase_generator_results', [
    { name: 'p_queue_id', value: queueId },
    { name: 'p_phrases', value: phrases },
  ]);
};

export default addPhraseGeneratorResults;
export { addPhraseGeneratorResults };
