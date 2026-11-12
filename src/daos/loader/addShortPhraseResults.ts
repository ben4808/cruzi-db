import { sqlQuery } from '../../pool/postgres';

export interface ShortPhraseSecondaryClassInput {
  secondaryClass: string;
  secondaryDisplay: string;
  secondaryBaseForm?: string;
  unityBucket?: string;
  familiarityBucket?: string;
}

export interface ShortPhraseResultInput {
  prompt: string;
  entry: string;
  lang: string;
  classification?: string;
  displayText?: string;
  baseForm?: string;
  isVulgar?: boolean;
  unityBucket?: string;
  frequency?: string;
  familiarityBucket?: string;
  secondaryClasses?: ShortPhraseSecondaryClassInput[];
}

const addShortPhraseResults = async (results: ShortPhraseResultInput[]): Promise<void> => {
  if (results.length === 0) {
    return;
  }

  const payload = results.map((result) => ({
    prompt: result.prompt,
    entry: result.entry,
    lang: result.lang,
    classification: result.classification ?? undefined,
    display_text: result.displayText ?? undefined,
    base_form: result.baseForm ?? undefined,
    is_vulgar: result.isVulgar,
    unity_bucket: result.unityBucket ?? undefined,
    frequency: result.frequency ?? undefined,
    familiarity_bucket: result.familiarityBucket ?? undefined,
    secondary_classes: (result.secondaryClasses ?? []).map((secondary) => ({
      secondary_class: secondary.secondaryClass,
      secondary_display: secondary.secondaryDisplay,
      secondary_base_form: secondary.secondaryBaseForm ?? undefined,
      unity_bucket: secondary.unityBucket ?? undefined,
      familiarity_bucket: secondary.familiarityBucket ?? undefined,
    })),
  }));

  await sqlQuery(true, 'add_short_phrase_results', [
    { name: 'p_results', value: payload },
  ]);
};

export default addShortPhraseResults;
export { addShortPhraseResults };
