import {
    Clue,
    ClueCollection,
    CollectionClueTableRow,
    CollectionProgress,
    Entry,
    EntryQueryParams,
    Sense,
    User,
    UserResponse,
    CrosswordResponse,
    CrosswordCalendarDay,
} from 'cruzi-models';

export interface ICruziDao {
  getCrosswordList(date: Date, userId?: string): Promise<ClueCollection[]>;
  getCrossword(collectionId: string, userId?: string): Promise<ClueCollection | null>;
  getCrosswordCalendar(publicationId: string, month: number, year: number, userId?: string): Promise<CrosswordCalendarDay[]>;
  getCollectionProgress(userId: string, collectionIds: string[]): Promise<Map<string, CollectionProgress>>;
  getCollectionList(userId?: string): Promise<ClueCollection[]>;
  getCollectionById(collectionId: string, userId?: string): Promise<ClueCollection | null>;

  getCrosswordId(source: string, date: Date): Promise<string | null>;
  selectCollectionBatch(userId: string | undefined, collectionId: string): Promise<string[]>;
  populateCollectionBatch(clueIds: string[], userId?: string): Promise<Clue[]>;
  getCrosswordClues(collectionId: string): Promise<Clue[]>;
  getCollectionClues(
    collectionId: string,
    userId?: string,
    sortBy?: string,
    sortDirection?: string,
    progressFilter?: string,
    statusFilter?: string,
    page?: number
  ): Promise<CollectionClueTableRow[]>;
  submitUserResponse(userId: string, response: UserResponse): Promise<void>;
  submitCrosswordResponse(userId: string, response: CrosswordResponse): Promise<void>;
  reopenCollection(userId: string, collectionId: string): Promise<void>;

  addClueToCollection(collectionId: string, clue: Clue): Promise<void>;
  removeClueFromCollection(collectionId: string, clueId: string): Promise<void>;
  addOrUpdateEntries(entries: Entry[]): Promise<void>;
  addOrUpdateSense(entry: Entry, sense: Sense): Promise<void>;

  getSingleClue(clueId: string): Promise<Clue | null>;
  updateSingleClue(clue: Clue): Promise<Clue>;

  getEntry(entry: string): Promise<Entry | null>;
  getSensesForEntry(entry: string, lang: string): Promise<Sense[]>;
  getClueByEntryInCollection(collectionId: string, entry: string, lang: string): Promise<Clue | null>;
  addToEntryInfoQueue(entry: string, lang: string): Promise<void>;

  queryEntries(params: EntryQueryParams): Promise<Entry[]>;

  insertUserIfNotExists(user: User): Promise<void>;

  initializeUserCollectionProgress(userId: string, collectionId: string): Promise<void>;
}
