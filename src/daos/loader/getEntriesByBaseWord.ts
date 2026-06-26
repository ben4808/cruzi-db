import { sqlQuery } from '../../pool/postgres';

export type BaseWordPosition = 'start' | 'end';

const getEntriesByBaseWord = async (
  baseWord: string,
  lang: string,
  position: BaseWordPosition,
): Promise<string[]> => {
  const results = await sqlQuery(true, 'get_entries_by_base_word', [
    { name: 'p_base_word', value: baseWord },
    { name: 'p_lang', value: lang },
    { name: 'p_position', value: position },
  ]);

  return results.map((row) => row.display_text as string);
};

export default getEntriesByBaseWord;
export { getEntriesByBaseWord };
