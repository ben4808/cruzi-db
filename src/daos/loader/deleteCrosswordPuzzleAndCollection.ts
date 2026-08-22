import { sqlQuery } from '../../pool/postgres';
import { formatDateKey } from '../../lib/dbUtils';

const deleteCrosswordPuzzleAndCollection = async (
  publicationId: string,
  date: Date,
): Promise<void> => {
  await sqlQuery(true, 'delete_crossword_puzzle_and_collection', [
    { name: 'p_publication_id', value: publicationId },
    { name: 'p_date', value: formatDateKey(date) },
  ]);
};

export default deleteCrosswordPuzzleAndCollection;
export { deleteCrosswordPuzzleAndCollection };
