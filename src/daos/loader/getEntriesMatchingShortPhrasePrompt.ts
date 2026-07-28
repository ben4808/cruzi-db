import { sqlQuery } from '../../pool/postgres';

export type ShortPhrasePosition = 'start' | 'end';

const getEntriesMatchingShortPhrasePrompt = async (
  baseLetters: string,
  lang: string,
  length: number,
  position: ShortPhrasePosition,
): Promise<string[]> => {
  const results = await sqlQuery(true, 'get_entries_matching_short_phrase_prompt', [
    { name: 'p_base_letters', value: baseLetters },
    { name: 'p_lang', value: lang },
    { name: 'p_length', value: length },
    { name: 'p_position', value: position },
  ]);

  return results.map((row) => row.display_text as string);
};

export default getEntriesMatchingShortPhrasePrompt;
export { getEntriesMatchingShortPhrasePrompt };
