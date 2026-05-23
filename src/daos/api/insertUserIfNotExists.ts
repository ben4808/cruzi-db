import { User } from 'cruzi-models';
import { sqlQuery } from "../../pool/postgres";

const insertUserIfNotExists = async (user: User): Promise<void> => {
    await sqlQuery(true, 'insert_user_if_not_exists', [
        { name: 'p_id', value: user.id },
        { name: 'p_email', value: user.email },
        { name: 'p_first_name', value: user.firstName || null },
        { name: 'p_last_name', value: user.lastName || null },
        { name: 'p_native_lang', value: user.nativeLang || null }
    ]);
};

export default insertUserIfNotExists;
