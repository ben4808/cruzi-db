import { CollectionClue } from 'cruzi-models';
import { ClueCollection } from 'cruzi-models';
import { Entry } from 'cruzi-models';
import { ExampleSentence } from 'cruzi-models';
import { Puzzle } from 'cruzi-models';
import { Sense } from 'cruzi-models';
import { EntryInfoQueueItemInput } from './addEntryInfoQueueEntries';
import { EntryInfoQueueItem } from './getEntryInfoQueueTop10';

export interface ILoaderDao {
    savePuzzle: (puzzle: Puzzle) => Promise<void>;
    saveClueCollection: (clueCollection: ClueCollection) => Promise<void>;
    addCluesToCollection: (collectionId: string, clues: CollectionClue[]) => Promise<void>;
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
