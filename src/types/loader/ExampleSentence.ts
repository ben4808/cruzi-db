import { ExampleSentence as BaseExampleSentence } from 'cruzi-models';

/** Loader pipeline example sentence with map-backed translations. */
export interface ExampleSentence extends Omit<BaseExampleSentence, 'translations' | 'sourceAi'> {
    translations?: Map<string, string>;
    source_ai?: string;
}
