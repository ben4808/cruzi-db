import { sqlQuery } from '../../pool/postgres';

export interface EntryTagInput {
  entry: string;
  lang: string;
  tag: string;
  value?: string;
}

const addEntryTags = async (tags: EntryTagInput[]): Promise<void> => {
  if (tags.length === 0) {
    return;
  }

  const payload = tags.map((tag) => ({
    entry: tag.entry,
    lang: tag.lang,
    tag: tag.tag,
    value: tag.value ?? undefined,
  }));

  await sqlQuery(true, 'add_entry_tags', [{ name: 'p_tags', value: payload }]);
};

export default addEntryTags;
export { addEntryTags };
