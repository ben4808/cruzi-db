import { sqlQuery } from '../../pool/postgres';
import { EntryTagInput } from './addEntryTags';

const deleteEntryTags = async (tags: EntryTagInput[]): Promise<void> => {
  if (tags.length === 0) {
    return;
  }

  const payload = tags.map((tag) => ({
    entry: tag.entry,
    lang: tag.lang,
    tag: tag.tag,
  }));

  await sqlQuery(true, 'delete_entry_tags', [{ name: 'p_tags', value: payload }]);
};

export default deleteEntryTags;
export { deleteEntryTags };
