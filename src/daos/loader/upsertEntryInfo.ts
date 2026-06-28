import { sqlQuery } from "../../pool/postgres";
import { Sense } from "cruzi-models";

export const getSensesForEntry = async (entry: string, lang: string): Promise<Sense[]> => {
  const results = await sqlQuery(true, "get_senses_for_entry", [
    { name: "p_entry", value: entry },
    { name: "p_lang", value: lang },
  ]);

  return results.map((row: any) => ({
    id: row.id,
    partOfSpeech: row.part_of_speech,
    classification: row.classification,
    frequency: row.frequency,
    summary: row.summary,
    definition: row.definition,
    similarEntries: row.similar_entries ?? undefined,
    exampleSentences: row.example_sentences || [],
    translations: row.translations ? new Map(Object.entries(row.translations)) : undefined,
    sourceAi: row.source_ai,
  } as Sense));
};

export const upsertEntryInfo = async (
  entry: string,
  lang: string,
  senses: Sense[],
  status: 'Ready' | 'Error' | 'Invalid' | 'Processing'
): Promise<void> => {
  // Convert senses to the format expected by the stored procedure
  const sensesData = senses.map((sense) => {
    const translationLang = sense.translations ? Object.keys(sense.translations)[0] : undefined;
    const translation = translationLang ? sense.translations![translationLang] : undefined;

    return {
      id: sense.id,
      part_of_speech: sense.partOfSpeech,
      classification: sense.classification,
      frequency: sense.frequency,
      summary: sense.summary,
      definition: sense.definition,
      similar_entries: sense.similarEntries ?? [],
      source_ai: sense.sourceAi,
      ...(translationLang && {
        translation_lang: translationLang,
        natural_translations: (translation?.naturalTranslations ?? []).map(
          (t) => t.displayText ?? t.entry,
        ),
        colloquial_translations: (translation?.colloquialTranslations ?? []).map(
          (t) => t.displayText ?? t.entry,
        ),
      }),
      ...(sense as any).corresponds_with && { corresponds_with: (sense as any).corresponds_with },
    };
  });

  // Create single jsonb parameter
  const entryInfoData = {
    entry,
    lang,
    senses: sensesData,
    status,
  };

  await sqlQuery(true, "upsert_entry_info", [
    { name: "p_entry_info", value: JSON.stringify(entryInfoData) },
  ]);
};
