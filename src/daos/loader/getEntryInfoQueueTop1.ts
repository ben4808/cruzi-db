import { sqlQuery } from '../../pool/postgres';
import { mapEntryInfoQueueRow } from './mapEntryInfoQueueRow';

export interface ExistingSenseInfo {
  id: string;
  summary: string;
}

export interface EntryInfoQueueItem {
  entry: string;
  display_text: string;
  lang: string;
  existing_sense_info: ExistingSenseInfo[];
  example_sentence_count: number;
}

const getEntryInfoQueueTop1 = async (): Promise<EntryInfoQueueItem | null> => {
  const results = await sqlQuery(true, 'get_entry_info_queue_top_1', []);

  if (results.length === 0) {
    return null;
  }

  return mapEntryInfoQueueRow(results[0]);
};

export default getEntryInfoQueueTop1;
export { getEntryInfoQueueTop1 };
