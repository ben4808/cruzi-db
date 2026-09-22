import { sqlQuery } from '../../pool/postgres';
import { PostgresParameter } from '../../pool/PostgresParameter';

export interface PuzzleSenseForProcessing {
  id: string;
  entry: string;
  lang: string;
  summary: string;
  displayText: string;
  classification: string;
  partOfSpeech: string;
  reviewedStatus: string | null;
  hasReferences: boolean;
}

export interface PuzzleClueForProcessing {
  clueId: string;
  entry: string;
  lang: string;
  customClue: string | null;
  senseId: string | null;
  matchAttempted: boolean;
  displayText: string | null;
  entryExists: boolean;
  clueOrder: number;
  senses: PuzzleSenseForProcessing[];
}

export interface SenseGeneratorQueueItemInput {
  puzzleId: string;
  entry: string;
  lang: string;
  hint: string | null;
}

export interface ClueSenseMatchUpdate {
  clueId: string;
  senseId: string | null;
  matchAttempted: boolean;
}

export interface ExistingSenseSummary {
  id: string;
  summary: string;
  displayText: string;
}

export interface SenseGeneratorQueueItem {
  queueId: number;
  entry: string;
  lang: string;
  hint: string | null;
  entryDisplayText: string | null;
  secondaryDisplays: string[];
  existingSenses: ExistingSenseSummary[];
}

export interface GeneratedSenseTranslation {
  translation_lang: string;
  natural_translations: string[];
  colloquial_translations: string[];
}

export interface GeneratedSenseInsert {
  id: string;
  entry: string;
  lang: string;
  display_text: string;
  summary: string;
  definition: string;
  part_of_speech: string;
  classification: string;
  similar_entries: string[];
  translations: GeneratedSenseTranslation[];
}

export interface SenseScoringQueueItem {
  queueId: number;
  senseId: string;
  entry: string;
  lang: string;
  displayText: string | null;
  summary: string | null;
  classification: string | null;
  partOfSpeech: string | null;
  unityBucket: string | null;
  familiarityBucket: string | null;
  qualityBucket: string | null;
  reviewedStatus: string | null;
}

export interface PuzzleSenseScoringItem {
  senseId: string;
  entry: string;
  lang: string;
  displayText: string | null;
  summary: string | null;
  classification: string | null;
  partOfSpeech: string | null;
  unityBucket: string | null;
  familiarityBucket: string | null;
  qualityBucket: string | null;
  reviewedStatus: string | null;
}

export interface SenseScoringUpdate {
  senseId: string;
  unityBucket?: string;
  familiarityBucket?: string;
  qualityBucket?: string;
  reviewedStatus: string;
  flags?: string[];
}

export interface SenseReferenceQueueItem {
  queueId: number;
  senseId: string;
  entry: string;
  lang: string;
  displayText: string | null;
  summary: string | null;
}

export interface PuzzleSenseReferenceItem {
  senseId: string;
  entry: string;
  lang: string;
  displayText: string | null;
  summary: string | null;
}

export interface SenseReferenceInsert {
  id: string;
  senseId: string;
  referenceType: string;
  referenceText: string;
  referenceSource: string | null;
  referenceUrl: string | null;
}

function asArray(raw: unknown): unknown[] {
  if (raw == null) {
    return [];
  }
  if (typeof raw === 'string') {
    try {
      const parsed = JSON.parse(raw);
      return Array.isArray(parsed) ? parsed : [];
    } catch {
      return [];
    }
  }
  return Array.isArray(raw) ? raw : [];
}

function asString(value: unknown): string {
  return value == null ? '' : String(value);
}

function asNullableString(value: unknown): string | null {
  if (value == null) {
    return null;
  }
  const text = String(value);
  return text.trim() === '' ? null : text;
}

function parseSenses(raw: unknown): PuzzleSenseForProcessing[] {
  return asArray(raw)
    .map((item) => {
      const row = item as Record<string, unknown>;
      return {
        id: asString(row.id).trim(),
        entry: asString(row.entry).trim(),
        lang: asString(row.lang).trim(),
        summary: asString(row.summary).trim(),
        displayText: asString(row.display_text).trim(),
        classification: asString(row.classification).trim(),
        partOfSpeech: asString(row.part_of_speech).trim(),
        reviewedStatus: asNullableString(row.reviewed_status),
        hasReferences: row.has_references === true || row.has_references === 'true',
      };
    })
    .filter((sense) => sense.id !== '');
}

function parseExistingSenses(raw: unknown): ExistingSenseSummary[] {
  return asArray(raw)
    .map((item) => {
      const row = item as Record<string, unknown>;
      return {
        id: asString(row.id).trim(),
        summary: asString(row.summary).trim(),
        displayText: asString(row.display_text).trim(),
      };
    })
    .filter((sense) => sense.id !== '');
}

function parseStringList(raw: unknown): string[] {
  return asArray(raw)
    .map((item) => asString(item).trim())
    .filter((item) => item !== '');
}

async function callVoid(functionName: string, parameters: PostgresParameter[]): Promise<void> {
  if (parameters.length === 1 && Array.isArray(parameters[0].value) && parameters[0].value.length === 0) {
    return;
  }
  await sqlQuery(true, functionName, parameters);
}

export async function pullCrosswordProcessingPuzzle(): Promise<string | null> {
  const rows = await sqlQuery(true, 'pull_crossword_processing_puzzle', []);
  const puzzleId = asString(rows[0]?.puzzle_id).trim();
  return puzzleId || null;
}

export async function enqueueCrosswordProcessingPuzzle(puzzleId: string): Promise<void> {
  await sqlQuery(true, 'enqueue_crossword_processing_puzzle', [
    { name: 'p_puzzle_id', value: puzzleId },
  ]);
}

export async function deleteCrosswordProcessingPuzzle(puzzleId: string): Promise<void> {
  await sqlQuery(true, 'delete_crossword_processing_puzzle', [
    { name: 'p_puzzle_id', value: puzzleId },
  ]);
}

export async function deferCrosswordProcessingPuzzle(puzzleId: string): Promise<void> {
  await sqlQuery(true, 'defer_crossword_processing_puzzle', [
    { name: 'p_puzzle_id', value: puzzleId },
  ]);
}

export async function getPuzzleCluesForProcessing(puzzleId: string): Promise<PuzzleClueForProcessing[]> {
  const rows = await sqlQuery(true, 'get_puzzle_clues_for_processing', [
    { name: 'p_puzzle_id', value: puzzleId },
  ]);

  return rows
    .map((row) => ({
      clueId: asString(row.clue_id).trim(),
      entry: asString(row.entry).trim(),
      lang: asString(row.lang).trim(),
      customClue: asNullableString(row.custom_clue),
      senseId: asNullableString(row.sense_id),
      matchAttempted: row.match_attempted === true || row.match_attempted === 'true',
      displayText: asNullableString(row.display_text),
      entryExists: row.entry_exists === true || row.entry_exists === 'true',
      clueOrder: Number(row.clue_order ?? 0),
      senses: parseSenses(row.senses),
    }))
    .filter((clue) => clue.clueId !== '')
    .sort((a, b) => a.clueOrder - b.clueOrder || a.clueId.localeCompare(b.clueId));
}

export async function enqueueSenseGeneratorItems(items: SenseGeneratorQueueItemInput[]): Promise<void> {
  await callVoid('enqueue_sense_generator_items', [{
    name: 'p_items',
    value: items.map((item) => ({
      puzzle_id: item.puzzleId,
      entry: item.entry,
      lang: item.lang,
      hint: item.hint,
    })),
  }]);
}

export async function updateClueSenseMatches(updates: ClueSenseMatchUpdate[]): Promise<void> {
  await callVoid('update_clue_sense_matches', [{
    name: 'p_updates',
    value: updates.map((update) => ({
      clue_id: update.clueId,
      sense_id: update.senseId,
      match_attempted: update.matchAttempted,
    })),
  }]);
}

export async function enqueueSenseScoringItems(
  items: Array<{ puzzleId: string; senseId: string }>,
): Promise<void> {
  await callVoid('enqueue_sense_scoring_items', [{
    name: 'p_items',
    value: items.map((item) => ({
      puzzle_id: item.puzzleId,
      sense_id: item.senseId,
    })),
  }]);
}

export async function enqueueSenseReferenceItems(
  items: Array<{ puzzleId: string; senseId: string }>,
): Promise<void> {
  await callVoid('enqueue_sense_reference_items', [{
    name: 'p_items',
    value: items.map((item) => ({
      puzzle_id: item.puzzleId,
      sense_id: item.senseId,
    })),
  }]);
}

export async function getSenseGeneratorQueueForPuzzle(
  puzzleId: string,
  limit: number,
  excludeIds: number[] = [],
): Promise<SenseGeneratorQueueItem[]> {
  const rows = await sqlQuery(true, 'get_sense_generator_queue_for_puzzle', [
    { name: 'p_puzzle_id', value: puzzleId },
    { name: 'p_limit', value: limit },
    { name: 'p_exclude', value: excludeIds },
  ]);

  return rows.map((row) => ({
    queueId: Number(row.queue_id),
    entry: asString(row.entry).trim(),
    lang: asString(row.lang).trim(),
    hint: asNullableString(row.hint),
    entryDisplayText: asNullableString(row.entry_display_text),
    secondaryDisplays: parseStringList(row.secondary_displays),
    existingSenses: parseExistingSenses(row.existing_senses),
  }));
}

export async function deleteSenseGeneratorQueueItems(ids: number[]): Promise<void> {
  await callVoid('delete_sense_generator_queue_items', [{ name: 'p_ids', value: ids }]);
}

export async function insertGeneratedSenses(senses: GeneratedSenseInsert[]): Promise<void> {
  await callVoid('insert_generated_senses', [{ name: 'p_senses', value: senses }]);
}

export async function getMatchedSensesForScoring(
  puzzleId: string,
  limit: number,
  excludeIds: string[] = [],
): Promise<PuzzleSenseScoringItem[]> {
  const rows = await sqlQuery(true, 'get_matched_senses_for_scoring', [
    { name: 'p_puzzle_id', value: puzzleId },
    { name: 'p_limit', value: limit },
    { name: 'p_exclude', value: excludeIds },
  ]);

  return rows.map((row) => ({
    senseId: asString(row.sense_id).trim(),
    entry: asString(row.entry).trim(),
    lang: asString(row.lang).trim(),
    displayText: asNullableString(row.display_text),
    summary: asNullableString(row.summary),
    classification: asNullableString(row.classification),
    partOfSpeech: asNullableString(row.part_of_speech),
    unityBucket: asNullableString(row.unity_bucket),
    familiarityBucket: asNullableString(row.familiarity_bucket),
    qualityBucket: asNullableString(row.quality_bucket),
    reviewedStatus: asNullableString(row.reviewed_status),
  })).filter((row) => row.senseId !== '');
}

export async function getSenseScoringQueueForPuzzle(
  puzzleId: string,
  limit: number,
  excludeIds: number[] = [],
): Promise<SenseScoringQueueItem[]> {
  const rows = await sqlQuery(true, 'get_sense_scoring_queue_for_puzzle', [
    { name: 'p_puzzle_id', value: puzzleId },
    { name: 'p_limit', value: limit },
    { name: 'p_exclude', value: excludeIds },
  ]);

  return rows.map((row) => ({
    queueId: Number(row.queue_id),
    senseId: asString(row.sense_id).trim(),
    entry: asString(row.entry).trim(),
    lang: asString(row.lang).trim(),
    displayText: asNullableString(row.display_text),
    summary: asNullableString(row.summary),
    classification: asNullableString(row.classification),
    partOfSpeech: asNullableString(row.part_of_speech),
    unityBucket: asNullableString(row.unity_bucket),
    familiarityBucket: asNullableString(row.familiarity_bucket),
    qualityBucket: asNullableString(row.quality_bucket),
    reviewedStatus: asNullableString(row.reviewed_status),
  }));
}

export async function updateSenseScoringResults(updates: SenseScoringUpdate[]): Promise<void> {
  await callVoid('update_sense_scoring_results', [{
    name: 'p_updates',
    value: updates.map((update) => ({
      sense_id: update.senseId,
      ...(update.unityBucket ? { unity_bucket: update.unityBucket } : {}),
      ...(update.familiarityBucket ? { familiarity_bucket: update.familiarityBucket } : {}),
      ...(update.qualityBucket ? { quality_bucket: update.qualityBucket } : {}),
      reviewed_status: update.reviewedStatus,
      ...(update.flags ? { flags: update.flags } : {}),
    })),
  }]);
}

export async function deleteSenseScoringQueueItems(ids: number[]): Promise<void> {
  await callVoid('delete_sense_scoring_queue_items', [{ name: 'p_ids', value: ids }]);
}

export async function getMatchedSensesWithoutReferences(
  puzzleId: string,
  limit: number,
  excludeIds: string[] = [],
): Promise<PuzzleSenseReferenceItem[]> {
  const rows = await sqlQuery(true, 'get_matched_senses_without_references', [
    { name: 'p_puzzle_id', value: puzzleId },
    { name: 'p_limit', value: limit },
    { name: 'p_exclude', value: excludeIds },
  ]);

  return rows.map((row) => ({
    senseId: asString(row.sense_id).trim(),
    entry: asString(row.entry).trim(),
    lang: asString(row.lang).trim(),
    displayText: asNullableString(row.display_text),
    summary: asNullableString(row.summary),
  })).filter((row) => row.senseId !== '');
}

export async function getSenseReferenceQueueForPuzzle(
  puzzleId: string,
  limit: number,
  excludeIds: number[] = [],
): Promise<SenseReferenceQueueItem[]> {
  const rows = await sqlQuery(true, 'get_sense_reference_queue_for_puzzle', [
    { name: 'p_puzzle_id', value: puzzleId },
    { name: 'p_limit', value: limit },
    { name: 'p_exclude', value: excludeIds },
  ]);

  return rows.map((row) => ({
    queueId: Number(row.queue_id),
    senseId: asString(row.sense_id).trim(),
    entry: asString(row.entry).trim(),
    lang: asString(row.lang).trim(),
    displayText: asNullableString(row.display_text),
    summary: asNullableString(row.summary),
  }));
}

export async function insertSenseReferences(references: SenseReferenceInsert[]): Promise<void> {
  await callVoid('insert_sense_references', [{
    name: 'p_references',
    value: references.map((reference) => ({
      id: reference.id,
      sense_id: reference.senseId,
      reference_type: reference.referenceType,
      reference_text: reference.referenceText,
      reference_source: reference.referenceSource,
      reference_url: reference.referenceUrl,
    })),
  }]);
}

export async function deleteSenseReferenceQueueItems(ids: number[]): Promise<void> {
  await callVoid('delete_sense_reference_queue_items', [{ name: 'p_ids', value: ids }]);
}
