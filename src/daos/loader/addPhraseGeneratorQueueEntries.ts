import { sqlQuery } from "../../pool/postgres";

export interface PhraseGeneratorQueueItem {
  prompt: string;
  lang: string;
}

const addPhraseGeneratorQueueEntries = async (items: PhraseGeneratorQueueItem[]): Promise<void> => {
  if (items.length === 0) {
    return;
  }

  const payload = items.map((item) => ({
    prompt: item.prompt,
    lang: item.lang,
  }));

  await sqlQuery(true, "add_phrase_generator_queue_entries", [
    { name: "p_items", value: payload },
  ]);
};

export default addPhraseGeneratorQueueEntries;
export { addPhraseGeneratorQueueEntries };
