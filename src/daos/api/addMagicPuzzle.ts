import { ensureMagicPuzzleId } from "../../lib/magicPuzzleId";
import { sqlQuery } from "../../pool/postgres";

export interface MagicPuzzleInsert {
  id?: string;
  lang?: string;
  width: number;
  height: number;
  seedAnswer: string;
}

/** Inserts the puzzle and returns the 11-character base64 id that was stored. */
const addMagicPuzzle = async (puzzle: MagicPuzzleInsert): Promise<string> => {
  const id = ensureMagicPuzzleId(puzzle.id);
  await sqlQuery(true, "add_magic_puzzle", [
    { name: "p_id", value: id },
    { name: "p_lang", value: puzzle.lang || "en" },
    { name: "p_width", value: puzzle.width },
    { name: "p_height", value: puzzle.height },
    { name: "p_seed_answer", value: puzzle.seedAnswer },
  ]);
  return id;
};

export default addMagicPuzzle;
