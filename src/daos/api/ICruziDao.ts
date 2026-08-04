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
    FriendlyWordsGame,
    FriendlyWordsGameState,
    FriendlyWordsLanguage,
    FriendlyWordsPlayer,
    FriendlyWordsTurn,
    FriendlyWordsPlayedWord,
    FriendlyWordsRating,
} from 'cruzi-models';

export interface ICruziDao {
  getCrosswordList(date: Date, userId?: string): Promise<ClueCollection[]>;
  getCrossword(collectionId: string, userId?: string): Promise<ClueCollection | null>;
  getCrosswordCalendar(publicationId: string, month: number, year: number, userId?: string): Promise<CrosswordCalendarDay[]>;
  getCollectionProgress(userId: string, collectionIds: string[]): Promise<Map<string, CollectionProgress>>;
  getCollectionList(userId?: string): Promise<ClueCollection[]>;
  getCollectionById(collectionId: string, userId?: string): Promise<ClueCollection | null>;

  getCrosswordId(source: string, date: Date): Promise<string | null>;
  getCrosswordCollectionId(publicationId: string, date: Date): Promise<string | null>;
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
  completeCrossword(userId: string, collectionId: string): Promise<void>;

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

  createFriendlyWordsGame(input: {
    id: string;
    gameCode: string;
    title: string;
    hostPlayerId: string;
    player1: string;
    lang: FriendlyWordsLanguage;
    state: FriendlyWordsGameState;
  }): Promise<FriendlyWordsGame>;
  getFriendlyWordsGame(id: string): Promise<FriendlyWordsGame | null>;
  getFriendlyWordsGameByCode(gameCode: string): Promise<FriendlyWordsGame | null>;
  updateFriendlyWordsGame(input: {
    id: string;
    title: string;
    hostPlayerId: string;
    status: FriendlyWordsGame['status'];
    player1: string | null;
    player2: string | null;
    player3: string | null;
    player4: string | null;
    waitlist: FriendlyWordsPlayer[];
    state: FriendlyWordsGameState;
    completedAt?: Date | null;
  }): Promise<FriendlyWordsGame>;
  submitFriendlyWordsTurn(turn: FriendlyWordsTurn, playedWords: FriendlyWordsPlayedWord[]): Promise<void>;
  recommendFriendlyWordsRatings(entries: string[]): Promise<Record<string, string>>;
  addFriendlyWordsRatings(ratings: FriendlyWordsRating[]): Promise<void>;
  completeFriendlyWordsGame(id: string): Promise<void>;
}
