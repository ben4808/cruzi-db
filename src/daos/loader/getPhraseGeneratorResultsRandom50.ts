import { sqlQuery } from '../../pool/postgres';

export interface PhraseGeneratorResultRow {
  phrase_generator_queue_id: number;
  phrase: string;
  lang: string;
}

const getPhraseGeneratorResultsRandom50 = async (): Promise<PhraseGeneratorResultRow[]> => {
  const results = await sqlQuery(true, 'get_phrase_generator_results_random_50', []);

  return results.map((row) => ({
    phrase_generator_queue_id: Number(row.phrase_generator_queue_id),
    phrase: row.phrase as string,
    lang: row.lang as string,
  }));
};

export default getPhraseGeneratorResultsRandom50;
export { getPhraseGeneratorResultsRandom50 };
