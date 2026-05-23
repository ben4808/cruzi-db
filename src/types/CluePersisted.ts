import { Entry, Sense } from 'cruzi-models';

/** Clue with persisted DB fields used by the API DAO layer. */
export interface CluePersisted {
    id: string;
    entry: Entry;
    lang: string;
    sense?: Sense;
    customClue?: string;
    customDisplayText?: string;
    source?: string;
    translatedClues?: unknown;
}
