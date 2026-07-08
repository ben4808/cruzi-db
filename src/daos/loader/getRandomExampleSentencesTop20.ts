import { sqlQuery } from '../../pool/postgres';

export interface RandomExampleSentence {
  exampleSentenceId: string;
  senseId: string;
  displayText: string;
  partOfSpeech: string;
  senseSummary: string;
  sentenceEn: string;
  sentenceEs: string;
}

const getRandomExampleSentencesTop20 = async (): Promise<RandomExampleSentence[]> => {
  const results = await sqlQuery(true, 'get_random_example_sentences_top_20', []);

  return results.map((row) => ({
    exampleSentenceId: row.example_sentence_id,
    senseId: row.sense_id,
    displayText: row.display_text,
    partOfSpeech: row.part_of_speech ?? '',
    senseSummary: row.sense_summary,
    sentenceEn: row.sentence_en,
    sentenceEs: row.sentence_es,
  }));
};

export default getRandomExampleSentencesTop20;
