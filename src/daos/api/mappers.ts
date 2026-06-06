export const mapCreator = (creator: any) => {
    if (!creator) return undefined;
    return {
        id: creator.creator_id,
        firstName: creator.creator_first_name,
        lastName: creator.creator_last_name,
        email: creator.email ?? "",
        createdAt: creator.created_at ? new Date(creator.created_at) : undefined,
    };
};

export const mapCollectionProgressData = (progress: any, userId?: string) => {
    if (!progress) return undefined;
    return {
        userId: userId,
        unseen: progress.unseen ?? 0,
        inProgress: progress.in_progress ?? 0,
        completed: progress.completed ?? 0,
        hintsUsed: progress.hints_used ?? 0,
        collectionCompleted: progress.collection_completed ?? false,
    };
};

export const mapClueProgressData = (progress: any) => {
    if (!progress) return undefined;
    return {
        userId: progress.user_id ?? "",
        clueId: progress.clue_id ?? "",
        correctSolvesNeeded: progress.correct_solves_needed ?? 0,
        correctSolves: progress.correct_solves ?? 0,
        incorrectSolves: progress.incorrect_solves ?? 0,
        lastSolveDate: progress.last_solve ? new Date(progress.last_solve) : undefined,
    };
};
