import { sqlQuery } from '../../pool/postgres';

const completeFriendlyWordsGame = async (id: string): Promise<void> => {
  await sqlQuery(true, 'complete_friendly_words_game', [
    { name: 'p_id', value: id },
  ]);
};

export default completeFriendlyWordsGame;
