import { UserResponse } from 'cruzi-models';
import { sqlQuery } from "../../pool/postgres";

const submitUserResponse = async (userId: string, response: UserResponse): Promise<void> => {
    await sqlQuery(true, 'submit_user_response', [
        { name: 'p_user_id', value: userId },
        { name: 'p_response', value: response }
    ]);
};

export default submitUserResponse;
