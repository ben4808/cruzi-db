import { sqlQuery } from "../../pool/postgres";
import { ExampleSentence } from "cruzi-models";

const addExampleSentences = async (senseId: string, exampleSentences: ExampleSentence[]): Promise<void> => {
  await sqlQuery(true, "add_example_sentences", [
    { name: "p_sense_id", value: senseId },
    { name: "p_example_sentences", value: JSON.stringify(exampleSentences) },
  ]);
};

export default addExampleSentences;
