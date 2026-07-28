import { sqlQuery } from '../../pool/postgres';

export interface ShortPhraseQueueItem {
  prompt: string;
  lang: string;
  length: number;
}

const addShortPhraseQueueEntries = async (items: ShortPhraseQueueItem[]): Promise<void> => {
  if (items.length === 0) {
    return;
  }

  const payload = items.map((item) => ({
    prompt: item.prompt,
    lang: item.lang,
    length: item.length,
  }));

  await sqlQuery(true, 'add_short_phrase_queue_entries', [
    { name: 'p_items', value: payload },
  ]);
};

export default addShortPhraseQueueEntries;
export { addShortPhraseQueueEntries };
