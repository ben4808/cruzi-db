/** Loader pipeline puzzle shape (subset used by savePuzzle). */
export interface Puzzle {
    id?: string;
    title: string;
    publication?: string;
    date: Date;
    width: number;
    height: number;
    authors?: string[];
    copyright?: string;
    notes?: string;
    lang?: string;
    sourceLink?: string;
}
