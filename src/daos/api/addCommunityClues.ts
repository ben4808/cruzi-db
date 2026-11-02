import { sqlQuery } from "../../pool/postgres";

export interface CommunityClueInput {
  entry: string;
  lang?: string;
  clue: string;
}

const addCommunityClues = async (clues: CommunityClueInput[]): Promise<number> => {
  const inputs = clues.filter((clue) => clue.entry.trim() !== "" && clue.clue.trim() !== "");
  if (inputs.length === 0) {
    return 0;
  }

  const results = await sqlQuery(true, "add_community_clues", [
    {
      name: "p_clues",
      value: inputs.map((clue) => ({
        entry: clue.entry,
        lang: clue.lang || "en",
        clue: clue.clue,
      })),
    },
  ]);

  return Number(results[0]?.add_community_clues ?? 0);
};

export default addCommunityClues;
