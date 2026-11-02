import { sqlQuery } from "../../pool/postgres";

export interface MagicPuzzleViewClue {
  key: string;
  clue: string;
  order: number;
}

export interface MagicPuzzleRecord {
  id: string;
  lang: string;
  width: number;
  height: number;
  grid: string;
  clues: MagicPuzzleViewClue[];
}

const getMagicPuzzle = async (id: string): Promise<MagicPuzzleRecord | null> => {
  const trimmed = id.trim();
  if (!trimmed) return null;

  const result = await sqlQuery(true, "get_magic_puzzle", [
    { name: "p_id", value: trimmed },
  ]);
  const raw = result?.[0]?.get_magic_puzzle;
  if (!raw) return null;
  const data = typeof raw === "string" ? JSON.parse(raw) : raw;
  if (!data?.id || !data?.grid) return null;

  const clues = Array.isArray(data.clues) ? data.clues : [];
  return {
    id: String(data.id),
    lang: String(data.lang || "en"),
    width: Number(data.width) || 0,
    height: Number(data.height) || 0,
    grid: String(data.grid),
    clues: clues.map((clue: { key?: string; clue?: string; order?: number }, index: number) => ({
      key: String(clue?.key || ""),
      clue: String(clue?.clue || ""),
      order: Number.isFinite(Number(clue?.order)) ? Number(clue.order) : index,
    })),
  };
};

export default getMagicPuzzle;
