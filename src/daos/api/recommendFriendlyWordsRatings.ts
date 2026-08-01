import { sqlQuery } from '../../pool/postgres';

/** Returns a map of entry text -> recommended rating label. */
const recommendFriendlyWordsRatings = async (
  entries: string[]
): Promise<Record<string, string>> => {
  if (entries.length === 0) return {};

  const result = await sqlQuery(true, 'recommend_friendly_words_ratings', [
    { name: 'p_entries', value: entries },
  ]);

  const raw = result?.[0]?.recommend_friendly_words_ratings;
  if (!raw || typeof raw !== 'object') return {};
  return raw as Record<string, string>;
};

export default recommendFriendlyWordsRatings;
