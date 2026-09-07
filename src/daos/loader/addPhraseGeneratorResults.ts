import { sqlQuery } from '../../pool/postgres';

export interface PhraseGeneratorSecondaryClassInput {
  secondaryClass: string;
  secondaryDisplay: string;
  secondaryBaseForm?: string;
  unityBucket?: string;
  familiarityBucket?: string;
}

export interface PhraseGeneratorResultInput {
  prompt: string;
  entry: string;
  lang: string;
  baseForm?: string;
  isVulgar?: boolean;
  entryType?: string;
  displayText?: string;
  unityBucket?: string;
  familiarityBucket?: string;
  secondaryClasses?: PhraseGeneratorSecondaryClassInput[];
}

const addPhraseGeneratorResults = async (results: PhraseGeneratorResultInput[]): Promise<void> => {
  if (results.length === 0) {
    return;
  }

  const payload = results.map((result) => ({
    prompt: result.prompt,
    entry: result.entry,
    lang: result.lang,
    base_form: result.baseForm ?? undefined,
    is_vulgar: result.isVulgar,
    entry_type: result.entryType ?? undefined,
    display_text: result.displayText ?? undefined,
    unity_bucket: result.unityBucket ?? undefined,
    familiarity_bucket: result.familiarityBucket ?? undefined,
    secondary_classes: (result.secondaryClasses ?? []).map((secondary) => ({
      secondary_class: secondary.secondaryClass,
      secondary_display: secondary.secondaryDisplay,
      secondary_base_form: secondary.secondaryBaseForm ?? undefined,
      unity_bucket: secondary.unityBucket ?? undefined,
      familiarity_bucket: secondary.familiarityBucket ?? undefined,
    })),
  }));

  await sqlQuery(true, 'add_phrase_generator_results', [
    { name: 'p_results', value: payload },
  ]);
};

export default addPhraseGeneratorResults;
export { addPhraseGeneratorResults };
