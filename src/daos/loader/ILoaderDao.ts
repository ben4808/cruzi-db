import { Clue } from '../../types/loader/Clue';
import { ClueCollection } from '../../types/loader/ClueCollection';
import { Entry } from '../../types/loader/Entry';
import { ExampleSentence } from '../../types/loader/ExampleSentence';
import { Puzzle } from '../../types/loader/Puzzle';
import { Sense } from '../../types/loader/Sense';
import { TranslateResult } from '../../types/TranslateResult';
import { EntryInfoQueueItemInput } from './addEntryInfoQueueEntries';
import { EntryInfoQueueItem } from './getEntryInfoQueueTop10';

export interface ILoaderDao {
    savePuzzle: (puzzle: Puzzle) => Promise<void>;
    saveClueCollection: (clueCollection: ClueCollection) => Promise<void>;
    addCluesToCollection: (collectionId: string, clues: Clue[]) => Promise<void>;
    addTranslateResults: (translatedResults: TranslateResult[]) => Promise<void>;
    upsertEntries: (entries: Entry[]) => Promise<void>;
    addFamiliarityQualityResults: (entries: Entry[], sourceAI: string) => Promise<void>;
    getEntryInfoQueueTop10: () => Promise<EntryInfoQueueItem[]>;
    upsertEntryInfo: (entry: string, lang: string, senses: Sense[], status: 'Ready' | 'Error' | 'Invalid' | 'Processing') => Promise<void>;
    addExampleSentenceQueueEntries: (senseIds: string[]) => Promise<void>;
    addExampleSentenceQueueEntry: (senseId: string) => Promise<void>;
    addEntryInfoQueueEntries: (items: EntryInfoQueueItemInput[]) => Promise<void>;
    addEntryInfoQueueEntry: (entry: string, lang: string) => Promise<void>;
    addCrosswordFamiliarityQueueEntries: (items: EntryInfoQueueItemInput[]) => Promise<void>;
    addCrosswordFamiliarityQueueEntry: (entry: string, lang: string) => Promise<void>;
    addCrosswordQualityQueueEntries: (items: EntryInfoQueueItemInput[]) => Promise<void>;
    addCrosswordQualityQueueEntry: (entry: string, lang: string) => Promise<void>;
}

export type { ExampleSentence };
