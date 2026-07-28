import { sqlQuery } from '../../pool/postgres';

export interface ShortPhraseQueueRow {
  prompt: string;
  lang: string;
  length: number;
}

const getShortPhraseQueue = async (
  limit: number,
): Promise<ShortPhraseQueueRow[]> => {
  const results = await sqlQuery(true, 'get_short_phrase_queue', [
    { name: 'p_limit', value: limit },
  ]);

  return results.map((row) => ({
    prompt: row.prompt,
    lang: row.lang,
    length: row.length,
  }));
};

export default getShortPhraseQueue;
export { getShortPhraseQueue };
