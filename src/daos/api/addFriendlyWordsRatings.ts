import { FriendlyWordsRating } from 'cruzi-models';
import { sqlQuery } from '../../pool/postgres';

const addFriendlyWordsRatings = async (ratings: FriendlyWordsRating[]): Promise<void> => {
  if (ratings.length === 0) return;

  await sqlQuery(true, 'add_friendly_words_ratings', [
    {
      name: 'p_ratings',
      value: JSON.stringify(
        ratings.map((rating) => ({
          playedWordId: rating.playedWordId,
          playerId: rating.playerId,
          entry: rating.entry,
          lang: rating.lang,
          multiplier: rating.multiplier,
          wasUpdated: rating.wasUpdated,
        }))
      ),
    },
  ]);
};

export default addFriendlyWordsRatings;
