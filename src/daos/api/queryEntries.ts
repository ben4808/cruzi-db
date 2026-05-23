import { Entry, EntryQueryParams } from 'cruzi-models';
import { sqlQuery } from "../../pool/postgres";

const queryEntries = async (params: EntryQueryParams): Promise<Entry[]> => {
    const jsonbParams = {
        query: params.query,
        lang: params.lang,
        minFamiliarityScore: params.minFamiliarityScore,
        maxFamiliarityScore: params.maxFamiliarityScore,
        minQualityScore: params.minQualityScore,
        maxQualityScore: params.maxQualityScore,
        filters: params.filters,
    };

    const result = await sqlQuery(true, 'query_entries', [
        { name: 'params', value: jsonbParams }
    ]);

    if (!result || result.length === 0) {
        return [];
    }

    return result.map((raw: any) => ({
        entry: raw.entry,
        lang: raw.lang,
        displayText: raw.display_text,
        entryType: raw.entry_type,
        familiarityScore: raw.familiarity_score,
        qualityScore: raw.quality_score,
        loadingStatus: raw.loading_status,
    } as Entry));
};

export default queryEntries;
