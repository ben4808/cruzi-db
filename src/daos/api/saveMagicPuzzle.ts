import { CollectionClue } from "cruzi-models";
import { generateId } from "../../lib/dbUtils";
import { sqlQuery } from "../../pool/postgres";
import addCluesToCollection from "../loader/addCluesToCollection";
import addCommunityClues, { CommunityClueInput } from "./addCommunityClues";
import addMagicPuzzle from "./addMagicPuzzle";
import incrementUsedClues from "./incrementUsedClues";

export interface MagicPuzzleClueInput {
  entry: string;
  clue: string;
  order: number;
  metadata1: string;
}

export interface SaveMagicPuzzleInput {
  id?: string;
  lang?: string;
  width: number;
  height: number;
  seedAnswer: string;
  title?: string;
  source?: string;
  grid?: string;
  clues: MagicPuzzleClueInput[];
  communityClues?: CommunityClueInput[];
}

export interface SaveMagicPuzzleResult {
  magicPuzzleId: string;
  collectionId: string;
}

const saveMagicPuzzle = async (input: SaveMagicPuzzleInput): Promise<SaveMagicPuzzleResult> => {
  const lang = input.lang || "en";
  const collectionId = generateId();
  const now = new Date();

  const magicPuzzleId = await addMagicPuzzle({
    id: input.id,
    lang,
    width: input.width,
    height: input.height,
    seedAnswer: input.seedAnswer,
  });

  await sqlQuery(true, "add_magic_clue_collection", [
    { name: "p_collection_id", value: collectionId },
    { name: "p_magic_puzzle_id", value: magicPuzzleId },
    { name: "p_title", value: input.title || "Magic Crossword" },
    { name: "p_lang", value: lang },
    { name: "p_source", value: input.source || "magic" },
    { name: "p_metadata2", value: input.grid || "" },
    { name: "p_clue_count", value: input.clues.length },
    { name: "p_created_date", value: now },
    { name: "p_modified_date", value: now },
  ]);

  const collectionClues: CollectionClue[] = input.clues.map((clue) => ({
    clue: {
      id: generateId(),
      lang,
      entry: { entry: clue.entry, lang },
      customClue: clue.clue,
    },
    order: clue.order,
    metadata1: clue.metadata1,
  }));
  await addCluesToCollection(collectionId, collectionClues);

  // Count every used clue that already exists. New community clues are inserted
  // afterward so they start at times_used = 1 instead of being incremented too.
  await incrementUsedClues(input.clues.map((clue) => ({
    entry: clue.entry,
    lang,
    clue: clue.clue,
  })));

  if (input.communityClues && input.communityClues.length > 0) {
    await addCommunityClues(input.communityClues.map((clue) => ({
      entry: clue.entry,
      lang: clue.lang || lang,
      clue: clue.clue,
    })));
  }

  return { magicPuzzleId, collectionId };
};

export default saveMagicPuzzle;
