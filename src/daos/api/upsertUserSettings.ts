import { UserSettings } from 'cruzi-models';
import { sqlQuery } from '../../pool/postgres';

const mapUserSettings = (raw: any): UserSettings => ({
    crosswordSolverMinigame: Boolean(raw?.crossword_solver_minigame),
});

const upsertUserSettings = async (
    userId: string,
    settings: UserSettings,
): Promise<UserSettings> => {
    const result = await sqlQuery(true, 'upsert_user_settings', [
        { name: 'p_user_id', value: userId },
        { name: 'p_crossword_solver_minigame', value: settings.crosswordSolverMinigame },
    ]);

    const raw = result?.[0]?.upsert_user_settings;
    return mapUserSettings(raw);
};

export default upsertUserSettings;
