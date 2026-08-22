import { sqlQuery } from '../../pool/postgres';

export interface PhraseGeneratorResultInput {
  prompt: string;
  entry: string;
  lang: string;
  displayText?: string;
  unityBucket?: string;
  familiarityBucket?: string;
}

const addPhraseGeneratorResults = async (results: PhraseGeneratorResultInput[]): Promise<void> => {
  if (results.length === 0) {
    return;
  }

  const payload = results.map((result) => ({
    prompt: result.prompt,
    entry: result.entry,
    lang: result.lang,
    display_text: result.displayText ?? undefined,
    unity_bucket: result.unityBucket ?? undefined,
    familiarity_bucket: result.familiarityBucket ?? undefined,
  }));

  await sqlQuery(true, 'add_phrase_generator_results', [
    { name: 'p_results', value: payload },
  ]);
};

export default addPhraseGeneratorResults;
export { addPhraseGeneratorResults };
