import { FriendlyWordsGame } from 'cruzi-models';
import { sqlQuery } from '../../pool/postgres';
import { mapFriendlyWordsGame } from './mapFriendlyWordsGame';

const getFriendlyWordsGameByCode = async (gameCode: string): Promise<FriendlyWordsGame | null> => {
  const result = await sqlQuery(true, 'get_friendly_words_game_by_code', [
    { name: 'p_game_code', value: gameCode },
  ]);
  return mapFriendlyWordsGame(result?.[0]?.get_friendly_words_game_by_code);
};

export default getFriendlyWordsGameByCode;
