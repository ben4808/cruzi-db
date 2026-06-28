import { sqlQuery } from '../../pool/postgres';

export const removeFromEntryInfoQueue = async (
  entry: string,
  lang: string,
): Promise<void> => {
  await sqlQuery(true, 'remove_from_entry_info_queue', [
    { name: 'p_entry', value: entry },
    { name: 'p_lang', value: lang },
  ]);
};
