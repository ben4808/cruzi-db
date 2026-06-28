import { EntryInfoQueueItem, ExistingSenseInfo } from './getEntryInfoQueueTop1';

export function mapEntryInfoQueueRow(row: {
  entry: string;
  display_text: string;
  lang: string;
  existing_sense_ids?: string[];
  existing_sense_summaries?: string[];
  example_sentence_count?: string | number;
}): EntryInfoQueueItem {
  const senseIds = row.existing_sense_ids || [];
  const senseSummaries = row.existing_sense_summaries || [];
  const existingSenseInfo: ExistingSenseInfo[] = [];

  for (let i = 0; i < Math.min(senseIds.length, senseSummaries.length); i++) {
    existingSenseInfo.push({
      id: senseIds[i],
      summary: senseSummaries[i],
    });
  }

  return {
    entry: row.entry,
    display_text: row.display_text,
    lang: row.lang,
    existing_sense_info: existingSenseInfo,
    example_sentence_count: parseInt(String(row.example_sentence_count), 10) || 0,
  };
}
