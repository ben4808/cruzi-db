import { generateId } from "./dbUtils";

/** Uppercase, lowercase, digits, hyphen, and underscore. Eleven characters. */
const MAGIC_PUZZLE_ID = /^[A-Za-z0-9_-]{11}$/;

/** Id stored on a magic_puzzle row. Invalid values are replaced with a new id. */
export function ensureMagicPuzzleId(id?: string): string {
  const trimmed = (id ?? "").trim();
  return MAGIC_PUZZLE_ID.test(trimmed) ? trimmed : generateId();
}
