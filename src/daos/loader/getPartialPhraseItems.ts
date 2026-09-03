import { sqlQuery } from "../../pool/postgres";

export interface PartialPhraseItem {
  displayText: string;
  lang: string;
}

const getPartialPhraseItems = async (
  items: PartialPhraseItem[],
): Promise<PartialPhraseItem[]> => {
  if (items.length === 0) {
    return [];
  }

  const results = await sqlQuery(true, "get_partial_phrase_items", [
    {
      name: "p_items",
      value: items.map((item) => ({
        display_text: item.displayText,
        lang: item.lang,
      })),
    },
  ]);

  return results.map((row) => ({
    displayText: row.display_text,
    lang: row.lang,
  }));
};

export default getPartialPhraseItems;
