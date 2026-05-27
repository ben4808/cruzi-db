import { sqlQuery } from "../../pool/postgres";
import { CollectionClue } from "cruzi-models";
import { generateId } from "../../lib/dbUtils";

/**
 * Payload shape for add_clues_to_collection(clues_data jsonb).
 * Each element is inserted into clue and collection__clue; collection_id is read from the first element.
 */
interface CluesDataElement {
    collection_id: string;
    id: string;
    order: number;
    entry: string;
    lang: string;
    sense_id: string | null;
    custom_clue: string | null;
    custom_display_text: string | null;
    metadata1: string | null;
    metadata2: string | null;
}

const addCluesToCollection = async (collectionId: string, clues: CollectionClue[]) => {
    if (clues.length === 0) return;

    const cluesData: CluesDataElement[] = clues.map((clue, index) => {
        return {
            collection_id: collectionId,
            id: clue.clue.id ?? generateId(),
            order: index,
            entry: clue.clue.entry?.entry ?? "",
            lang: clue.clue.lang ?? "en",
            sense_id: clue.clue.sense?.id ?? null,
            custom_clue: clue.clue.customClue ?? null,
            custom_display_text: clue.clue.customDisplayText ?? null,
            metadata1: clue.metadata1 ?? null,
            metadata2: clue.metadata2 ?? null,
        };
    }).filter(x => x.entry.length > 0);

    await sqlQuery(true, "add_clues_to_collection", [
        { name: "clues_data", value: cluesData },
    ]);
};

export default addCluesToCollection;
