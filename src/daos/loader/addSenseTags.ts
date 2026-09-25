import { sqlQuery } from '../../pool/postgres';

export interface SenseTagInput {
  senseId: string;
  tag: string;
  value?: string;
}

const addSenseTags = async (tags: SenseTagInput[]): Promise<void> => {
  if (tags.length === 0) {
    return;
  }

  const payload = tags.map((tag) => ({
    sense_id: tag.senseId,
    tag: tag.tag,
    value: tag.value ?? undefined,
  }));

  await sqlQuery(true, 'add_sense_tags', [{ name: 'p_tags', value: payload }]);
};

export default addSenseTags;
export { addSenseTags };
