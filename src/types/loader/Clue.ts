import { Clue as BaseClue, ClueProgressData } from 'cruzi-models';
import { Entry } from './Entry';
import { Sense } from './Sense';

/** Loader pipeline clue with collection placement and progress metadata. */
export interface Clue extends Omit<BaseClue, 'entry' | 'sense'> {
    entry: Entry;
    sense?: Sense;
    progressData?: ClueProgressData;
    order?: number;
    metadata1?: string;
    metadata2?: string;
}
