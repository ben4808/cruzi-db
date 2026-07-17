import { sqlQuery } from "../../pool/postgres";

export interface EntryWithoutUnityBucket {
  entry: string;
  lang: string;
  display_text: string;
}

const getEntriesWithoutUnityBucketTop50 = async (): Promise<EntryWithoutUnityBucket[]> => {
  const results = await sqlQuery(true, "get_entries_without_unity_bucket_top_50", []);

  return results.map((row) => ({
    entry: row.entry,
    lang: row.lang,
    display_text: row.display_text,
  }));
};

export default getEntriesWithoutUnityBucketTop50;
