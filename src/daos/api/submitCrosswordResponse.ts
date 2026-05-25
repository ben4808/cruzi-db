import { CrosswordResponse } from 'cruzi-models';
import { sqlQuery } from "../../pool/postgres";

const submitCrosswordResponse = async (userId: string, response: CrosswordResponse): Promise<void> => {
    await sqlQuery(true, 'submit_crossword_response', [
        { name: 'p_user_id', value: userId },
        { name: 'p_response', value: response },
    ]);
};

export default submitCrosswordResponse;
