import {
  FriendlyWordsGame,
  FriendlyWordsGameState,
  FriendlyWordsLanguage,
  FriendlyWordsPlayedWord,
  FriendlyWordsPlayer,
  FriendlyWordsTurn,
} from 'cruzi-models';

type RawFriendlyWordsGame = {
  id: string;
  game_code: string;
  title: string;
  host_player_id: string;
  status: FriendlyWordsGame['status'];
  lang?: string | null;
  created_at: string | Date;
  completed_at: string | Date | null;
  player1: string | null;
  player2: string | null;
  player3: string | null;
  player4: string | null;
  waitlist: FriendlyWordsPlayer[] | string;
  state: FriendlyWordsGameState | string;
  turns?: FriendlyWordsTurn[] | Array<Record<string, unknown>>;
  played_words?: FriendlyWordsPlayedWord[] | Array<Record<string, unknown>>;
};

function parseJsonField<T>(value: T | string | null | undefined, fallback: T): T {
  if (value == null) return fallback;
  if (typeof value === 'string') {
    try {
      return JSON.parse(value) as T;
    } catch {
      return fallback;
    }
  }
  return value;
}

function mapTurn(raw: Record<string, unknown>): FriendlyWordsTurn {
  return {
    id: String(raw.id),
    gameId: String(raw.game_id ?? raw.gameId),
    player: String(raw.player),
    turnNumber: Number(raw.turn_number ?? raw.turnNumber),
    rack: String(raw.rack),
    action: String(raw.action),
    grossScore: raw.gross_score == null && raw.grossScore == null ? null : Number(raw.gross_score ?? raw.grossScore),
    totalMultiplier: (raw.total_multiplier ?? raw.totalMultiplier ?? null) as string | null,
    netScore: raw.net_score == null && raw.netScore == null ? null : Number(raw.net_score ?? raw.netScore),
    startScore: Number(raw.start_score ?? raw.startScore ?? 0),
    endScore: Number(raw.end_score ?? raw.endScore ?? 0),
  };
}

function mapPlayedWord(raw: Record<string, unknown>): FriendlyWordsPlayedWord {
  return {
    id: String(raw.id),
    turnId: String(raw.turn_id ?? raw.turnId),
    entry: String(raw.entry),
    lang: String(raw.lang),
    grossScore: Number(raw.gross_score ?? raw.grossScore ?? 0),
    multiplier: String(raw.multiplier),
  };
}

function mapLang(lang: string | null | undefined): FriendlyWordsLanguage {
  return lang === 'es' ? 'es' : 'en';
}

export function mapFriendlyWordsGame(raw: RawFriendlyWordsGame | null | undefined): FriendlyWordsGame | null {
  if (!raw) return null;

  const turnsRaw = parseJsonField<Array<Record<string, unknown>>>(raw.turns as any, []);
  const playedWordsRaw = parseJsonField<Array<Record<string, unknown>>>(raw.played_words as any, []);

  return {
    id: raw.id,
    gameCode: raw.game_code,
    title: raw.title,
    hostPlayerId: raw.host_player_id,
    status: raw.status,
    lang: mapLang(raw.lang),
    createdAt: new Date(raw.created_at),
    completedAt: raw.completed_at ? new Date(raw.completed_at) : null,
    player1: raw.player1,
    player2: raw.player2,
    player3: raw.player3,
    player4: raw.player4,
    waitlist: parseJsonField<FriendlyWordsPlayer[]>(raw.waitlist, []),
    state: parseJsonField<FriendlyWordsGameState>(raw.state, {
      players: [],
      waitlist: [],
      turnOrder: [],
      currentPlayerIndex: 0,
      turnNumber: 0,
      tilePool: [],
      board: [],
      gamePhase: 'ready',
      confirmation: null,
    }),
    turns: turnsRaw.map(mapTurn),
    playedWords: playedWordsRaw.map(mapPlayedWord),
  };
}
