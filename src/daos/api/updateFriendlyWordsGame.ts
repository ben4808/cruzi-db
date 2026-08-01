import { FriendlyWordsGame, FriendlyWordsGameState, FriendlyWordsPlayer } from 'cruzi-models';
import { sqlQuery } from '../../pool/postgres';
import { mapFriendlyWordsGame } from './mapFriendlyWordsGame';

const updateFriendlyWordsGame = async (input: {
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
}): Promise<FriendlyWordsGame> => {
  const result = await sqlQuery(true, 'update_friendly_words_game', [
    { name: 'p_id', value: input.id },
    { name: 'p_title', value: input.title },
    { name: 'p_host_player_id', value: input.hostPlayerId },
    { name: 'p_status', value: input.status },
    { name: 'p_player1', value: input.player1 },
    { name: 'p_player2', value: input.player2 },
    { name: 'p_player3', value: input.player3 },
    { name: 'p_player4', value: input.player4 },
    { name: 'p_waitlist', value: JSON.stringify(input.waitlist) },
    { name: 'p_state', value: JSON.stringify(input.state) },
    { name: 'p_completed_at', value: input.completedAt ?? null },
  ]);

  const mapped = mapFriendlyWordsGame(result?.[0]?.update_friendly_words_game);
  if (!mapped) {
    throw new Error(`Failed to update friendly words game: ${input.id}`);
  }
  return mapped;
};

export default updateFriendlyWordsGame;
