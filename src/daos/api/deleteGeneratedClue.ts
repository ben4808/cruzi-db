import { sqlQuery } from "../../pool/postgres";

const deleteGeneratedClue = async (
  entry: string,
  clue: string,
  lang: string = "en",
): Promise<number> => {
  const trimmedEntry = entry.trim();
  const trimmedClue = clue.trim();
  if (!trimmedEntry || !trimmedClue) return 0;

  const results = await sqlQuery(true, "delete_generated_clue", [
    { name: "p_entry", value: trimmedEntry },
    { name: "p_clue", value: trimmedClue },
    { name: "p_lang", value: lang },
  ]);

  return Number(results[0]?.delete_generated_clue ?? 0);
};

export default deleteGeneratedClue;
