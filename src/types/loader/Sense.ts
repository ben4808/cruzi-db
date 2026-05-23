import { Sense as BaseSense } from 'cruzi-models';
import { Entry } from './Entry';

/** Loader pipeline sense with optional nested entry and map-backed text fields. */
export interface Sense extends Omit<BaseSense, 'entry' | 'summary' | 'definition' | 'translations'> {
    entry?: Entry;
    summary?: string | Map<string, string>;
    definition?: string | Map<string, string>;
    translations?: Map<string, unknown>;
}
