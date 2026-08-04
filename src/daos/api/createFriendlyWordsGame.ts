import { FriendlyWordsGame, FriendlyWordsGameState, FriendlyWordsLanguage } from 'cruzi-models';
import { sqlQuery } from '../../pool/postgres';
import { mapFriendlyWordsGame } from './mapFriendlyWordsGame';

const createFriendlyWordsGame = async (input: {
  id: string;
  gameCode: string;
  title: string;
  hostPlayerId: string;
  player1: string;
  lang: FriendlyWordsLanguage;
  state: FriendlyWordsGameState;
}): Promise<FriendlyWordsGame> => {
  const result = await sqlQuery(true, 'create_friendly_words_game', [
    { name: 'p_id', value: input.id },
    { name: 'p_game_code', value: input.gameCode },
    { name: 'p_title', value: input.title },
    { name: 'p_host_player_id', value: input.hostPlayerId },
    { name: 'p_player1', value: input.player1 },
    { name: 'p_state', value: JSON.stringify(input.state) },
    { name: 'p_lang', value: input.lang },
  ]);

  const mapped = mapFriendlyWordsGame(result?.[0]?.create_friendly_words_game);
  if (!mapped) {
    throw new Error('Failed to create friendly words game');
  }
  return mapped;
};

export default createFriendlyWordsGame;
