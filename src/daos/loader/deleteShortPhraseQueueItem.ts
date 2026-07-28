import { sqlQuery } from '../../pool/postgres';

const deleteShortPhraseQueueItem = async (prompt: string, lang: string): Promise<void> => {
  await sqlQuery(true, 'delete_short_phrase_queue_item', [
    { name: 'p_prompt', value: prompt },
    { name: 'p_lang', value: lang },
  ]);
};

export default deleteShortPhraseQueueItem;
export { deleteShortPhraseQueueItem };
