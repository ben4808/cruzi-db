import { sqlQuery } from "../../pool/postgres";

const addToEntryInfoQueue = async (entry: string, lang: string): Promise<void> => {
    await sqlQuery(true, 'add_to_entry_info_queue', [
        { name: 'p_entry', value: entry },
        { name: 'p_lang', value: lang }
    ]);
};

export default addToEntryInfoQueue;
