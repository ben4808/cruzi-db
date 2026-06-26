import { sqlQuery } from '../../pool/postgres';

export interface PhraseGeneratorQueueRow {
  id: number;
  prompt: string;
  lang: string;
}

const getPhraseGeneratorQueueTop1 = async (): Promise<PhraseGeneratorQueueRow | null> => {
  const results = await sqlQuery(true, 'get_phrase_generator_queue_top_1', []);

  if (results.length === 0) {
    return null;
  }

  return {
    id: results[0].id,
    prompt: results[0].prompt,
    lang: results[0].lang,
  };
};

export default getPhraseGeneratorQueueTop1;
export { getPhraseGeneratorQueueTop1 };
