import { sqlQuery } from '../../pool/postgres';

export interface PhraseGeneratorQueueRow {
  prompt: string;
  lang: string;
}

const getPhraseGeneratorQueue = async (
  limit: number,
): Promise<PhraseGeneratorQueueRow[]> => {
  const results = await sqlQuery(true, 'get_phrase_generator_queue', [
    { name: 'p_limit', value: limit },
  ]);

  return results.map((row) => ({
    prompt: row.prompt,
    lang: row.lang,
  }));
};

export default getPhraseGeneratorQueue;
export { getPhraseGeneratorQueue };
