import { sqlQuery } from "../../pool/postgres";

export interface EntrySentenceInput {
  entry: string;
  originalLang: string;
  originalSentence: string;
  translatedLang?: string;
  translatedSentence?: string;
}

const addEntrySentences = async (sentences: EntrySentenceInput[]): Promise<number> => {
  if (sentences.length === 0) {
    return 0;
  }

  const results = await sqlQuery(true, "add_entry_sentences", [
    {
      name: "p_sentences",
      value: sentences.map((sentence) => ({
        entry: sentence.entry,
        original_lang: sentence.originalLang,
        original_sentence: sentence.originalSentence,
        translated_lang: sentence.translatedLang ?? null,
        translated_sentence: sentence.translatedSentence ?? null,
      })),
    },
  ]);

  return Number(results[0]?.add_entry_sentences ?? 0);
};

export default addEntrySentences;
