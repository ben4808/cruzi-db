import { sqlQuery } from "../../pool/postgres";

export interface UsedClueInput {
  entry: string;
  lang?: string;
  clue: string;
}

const incrementUsedClues = async (clues: UsedClueInput[]): Promise<number> => {
  const inputs = clues.filter((clue) => clue.entry.trim() !== "" && clue.clue.trim() !== "");
  if (inputs.length === 0) {
    return 0;
  }

  const results = await sqlQuery(true, "increment_used_clues", [
    {
      name: "p_clues",
      value: inputs.map((clue) => ({
        entry: clue.entry,
        lang: clue.lang || "en",
        clue: clue.clue,
      })),
    },
  ]);

  return Number(results[0]?.increment_used_clues ?? 0);
};

export default incrementUsedClues;
