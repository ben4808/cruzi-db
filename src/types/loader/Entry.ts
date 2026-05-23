import { Entry as BaseEntry } from 'cruzi-models';
import { Sense } from './Sense';

/** Loader pipeline entry with crossword scoring and in-memory sense/tag maps. */
export interface Entry extends Omit<BaseEntry, 'senses' | 'tags' | 'loadingStatus'> {
    crosswordScore?: number;
    cruziScore?: number;
    loadingStatus?: string;
    senses?: Map<string, Sense>;
    tags?: Map<string, string>;
}
