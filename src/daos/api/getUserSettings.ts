import { DEFAULT_USER_SETTINGS, UserSettings } from 'cruzi-models';
import { sqlQuery } from '../../pool/postgres';

const mapUserSettings = (raw: any): UserSettings => ({
    crosswordSolverMinigame: Boolean(raw?.crossword_solver_minigame),
});

const getUserSettings = async (userId: string): Promise<UserSettings> => {
    const result = await sqlQuery(true, 'get_user_settings', [
        { name: 'p_user_id', value: userId },
    ]);

    const raw = result?.[0]?.get_user_settings;
    if (!raw) {
        return { ...DEFAULT_USER_SETTINGS };
    }

    return mapUserSettings(raw);
};

export default getUserSettings;
