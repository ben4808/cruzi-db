import { sqlQuery } from "../../pool/postgres";

export interface GeneratedClueInput {
  entry: string;
  lang?: string;
  generatedClue: string;
  isSeedword: boolean;
  clueType?: string | null;
}

const addGeneratedClues = async (clues: GeneratedClueInput[]): Promise<number> => {
  if (clues.length === 0) {
    return 0;
  }

  const results = await sqlQuery(true, "add_generated_clues", [
    {
      name: "p_clues",
      value: clues.map((clue) => ({
        entry: clue.entry,
        lang: clue.lang || "en",
        generated_clue: clue.generatedClue,
        is_seedword: clue.isSeedword,
        clue_type: clue.clueType || null,
      })),
    },
  ]);

  return Number(results[0]?.add_generated_clues ?? 0);
};

export default addGeneratedClues;
