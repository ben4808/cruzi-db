import { sqlQuery } from "../../pool/postgres";
import { mapEntryInfoQueueRow, EntryInfoQueueItem } from "./mapEntryInfoQueueRow";

const getEntryInfoQueueTop10 = async (): Promise<EntryInfoQueueItem[]> => {
  const results = await sqlQuery(true, "get_entry_info_queue_top_10", []);

  return results.map((row) => mapEntryInfoQueueRow(row));
};

export default getEntryInfoQueueTop10;
