import { sqlQuery } from "../../pool/postgres";

export interface CrosswordCalendarDay {
    date: string;
    hints_used: number;
}

const getCrosswordCalendar = async (
    publicationId: string,
    month: number,
    year: number,
    userId?: string
): Promise<CrosswordCalendarDay[]> => {
    const result = await sqlQuery(true, 'get_crossword_calendar', [
        { name: 'p_user_id', value: userId ?? null },
        { name: 'p_publication_id', value: publicationId },
        { name: 'p_month', value: month },
        { name: 'p_year', value: year },
    ]);

    const rawData = result?.[0]?.get_crossword_calendar ?? [];

    return rawData.map((raw: any) => ({
        date: raw.date,
        hints_used: raw.hints_used ?? 0,
    }));
};

export default getCrosswordCalendar;
