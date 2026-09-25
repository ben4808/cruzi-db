import { sqlQuery } from '../../pool/postgres';
import { SenseTagInput } from './addSenseTags';

const deleteSenseTags = async (tags: SenseTagInput[]): Promise<void> => {
  if (tags.length === 0) {
    return;
  }

  const payload = tags.map((tag) => ({
    sense_id: tag.senseId,
    tag: tag.tag,
  }));

  await sqlQuery(true, 'delete_sense_tags', [{ name: 'p_tags', value: payload }]);
};

export default deleteSenseTags;
export { deleteSenseTags };
