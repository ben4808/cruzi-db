import { sqlQuery } from '../../pool/postgres';

export interface ExampleSentenceImprovementInput {
  exampleSentenceId: string;
  oldSentence: string;
  newSentence: string;
  newTranslation: string;
}

const addExampleSentenceImprovement = async (
  improvement: ExampleSentenceImprovementInput,
): Promise<void> => {
  await sqlQuery(true, 'add_example_sentence_improvement', [
    { name: 'p_example_sentence_id', value: improvement.exampleSentenceId },
    { name: 'p_old_sentence', value: improvement.oldSentence },
    { name: 'p_new_sentence', value: improvement.newSentence },
    { name: 'p_new_translation', value: improvement.newTranslation },
  ]);
};

export default addExampleSentenceImprovement;
