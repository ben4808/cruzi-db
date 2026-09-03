import { sqlQuery } from '../../pool/postgres';

export interface ShortPhraseResultInput {
  prompt: string;
  entry: string;
  lang: string;
  entryType?: string;
  displayText?: string;
  baseForm?: string;
  isVulgar?: boolean;
  unityBucket?: string;
  frequency?: string;
  familiarityBucket?: string;
}

const addShortPhraseResults = async (results: ShortPhraseResultInput[]): Promise<void> => {
  if (results.length === 0) {
    return;
  }

  const payload = results.map((result) => ({
    prompt: result.prompt,
    entry: result.entry,
    lang: result.lang,
    entry_type: result.entryType ?? undefined,
    display_text: result.displayText ?? undefined,
    base_form: result.baseForm ?? undefined,
    is_vulgar: result.isVulgar,
    unity_bucket: result.unityBucket ?? undefined,
    frequency: result.frequency ?? undefined,
    familiarity_bucket: result.familiarityBucket ?? undefined,
  }));

  await sqlQuery(true, 'add_short_phrase_results', [
    { name: 'p_results', value: payload },
  ]);
};

export default addShortPhraseResults;
export { addShortPhraseResults };
