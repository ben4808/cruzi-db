import { ClueCollection as BaseClueCollection, CollectionProgressData, User } from 'cruzi-models';
import { Clue } from './Clue';
import { Puzzle } from './Puzzle';

/** Loader pipeline clue collection using loader puzzle and clue shapes. */
export interface ClueCollection extends Omit<BaseClueCollection, 'puzzle' | 'clues' | 'progressData' | 'aiCompositeScore'> {
    puzzle?: Puzzle;
    metadata1?: string;
    clues?: Clue[];
    progressData?: CollectionProgressData;
}

export type { User };
