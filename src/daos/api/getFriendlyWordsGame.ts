import { FriendlyWordsGame } from 'cruzi-models';
import { sqlQuery } from '../../pool/postgres';
import { mapFriendlyWordsGame } from './mapFriendlyWordsGame';

const getFriendlyWordsGame = async (id: string): Promise<FriendlyWordsGame | null> => {
  const result = await sqlQuery(true, 'get_friendly_words_game', [
    { name: 'p_id', value: id },
  ]);
  return mapFriendlyWordsGame(result?.[0]?.get_friendly_words_game);
};

export default getFriendlyWordsGame;
