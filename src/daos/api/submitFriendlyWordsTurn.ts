import { FriendlyWordsPlayedWord, FriendlyWordsTurn } from 'cruzi-models';
import { sqlQuery } from '../../pool/postgres';

const submitFriendlyWordsTurn = async (
  turn: FriendlyWordsTurn,
  playedWords: FriendlyWordsPlayedWord[]
): Promise<void> => {
  await sqlQuery(true, 'submit_friendly_words_turn', [
    {
      name: 'p_turn',
      value: JSON.stringify({
        id: turn.id,
        gameId: turn.gameId,
        player: turn.player,
        turnNumber: turn.turnNumber,
        rack: turn.rack,
        action: turn.action,
        grossScore: turn.grossScore,
        totalMultiplier: turn.totalMultiplier,
        netScore: turn.netScore,
        startScore: turn.startScore,
        endScore: turn.endScore,
      }),
    },
    {
      name: 'p_played_words',
      value: JSON.stringify(
        playedWords.map((word) => ({
          id: word.id,
          entry: word.entry,
          lang: word.lang,
          grossScore: word.grossScore,
          multiplier: word.multiplier,
        }))
      ),
    },
  ]);
};

export default submitFriendlyWordsTurn;
