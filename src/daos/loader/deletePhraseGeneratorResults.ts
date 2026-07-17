import { sqlQuery } from '../../pool/postgres';

export interface PhraseGeneratorResultKey {
  phrase_generator_queue_id: number;
  phrase: string;
}

const deletePhraseGeneratorResults = async (
  results: PhraseGeneratorResultKey[],
): Promise<number> => {
  if (results.length === 0) {
    return 0;
  }

  const payload = results.map((row) => ({
    phrase_generator_queue_id: row.phrase_generator_queue_id,
    phrase: row.phrase,
  }));

  const rows = await sqlQuery(true, 'delete_phrase_generator_results', [
    { name: 'p_results', value: payload },
  ]);

  return Number(rows[0]?.delete_phrase_generator_results ?? 0);
};

export default deletePhraseGeneratorResults;
export { deletePhraseGeneratorResults };
