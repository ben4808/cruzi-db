import { sqlQuery } from '../../pool/postgres';

const deletePhraseGeneratorQueueItem = async (prompt: string, lang: string): Promise<void> => {
  await sqlQuery(true, 'delete_phrase_generator_queue_item', [
    { name: 'p_prompt', value: prompt },
    { name: 'p_lang', value: lang },
  ]);
};

export default deletePhraseGeneratorQueueItem;
export { deletePhraseGeneratorQueueItem };
