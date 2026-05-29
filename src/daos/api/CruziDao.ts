import { ICruziDao } from "./ICruziDao";
import addClueToCollection from "./addClueToCollection";
import removeClueFromCollection from "./removeClueFromCollection";
import addOrUpdateEntries from "./addOrUpdateEntries";
import addOrUpdateSense from "./addOrUpdateSense";
import getCrosswordList from "./getCrosswordList";
import getCrossword from "./getCrossword";
import getCrosswordCalendar from "./getCrosswordCalendar";
import getCollectionProgress from "./getCollectionsProgress";
import getCollectionById from "./getCollectionById";
import getCollectionList from "./getCollectionList";
import getCrosswordId from "./getCrosswordId";
import getCrosswordCollectionId from "./getCrosswordCollectionId";
import selectCollectionBatch from "./selectCollectionBatch";
import populateCollectionBatch from "./populateCollectionBatch";
import getCrosswordClues from "./getCrosswordClues";
import getCollectionClues from "./getCollectionClues";
import submitUserResponse from "./submitUserResponse";
import submitCrosswordResponse from "./submitCrosswordResponse";
import reopenCollection from "./reopenCollection";
import getSingleClue from "./getSingleClue";
import updateSingleClue from "./updateSingleClue";
import getEntry from "./getEntry";
import queryEntries from "./queryEntries";
import insertUserIfNotExists from "./insertUserIfNotExists";
import initializeUserCollectionProgress from "./initializeUserCollectionProgress";
import getSensesForEntry from "./getSensesForEntry";
import getClueByEntryInCollection from "./getClueByEntryInCollection";
import addToEntryInfoQueue from "./addToEntryInfoQueue";

class CruziDao implements ICruziDao {
    getCrosswordList = getCrosswordList;

    getCrossword = getCrossword;

    getCrosswordCalendar = getCrosswordCalendar;

    getCollectionProgress = getCollectionProgress;

    getCollectionList = getCollectionList;

    getCollectionById = getCollectionById;

    getCrosswordId = getCrosswordId;

    getCrosswordCollectionId = getCrosswordCollectionId;

    selectCollectionBatch = selectCollectionBatch;

    populateCollectionBatch = populateCollectionBatch;

    getCrosswordClues = getCrosswordClues;

    getCollectionClues = getCollectionClues;

    submitUserResponse = submitUserResponse;

    submitCrosswordResponse = submitCrosswordResponse;

    reopenCollection = reopenCollection;

    addClueToCollection = addClueToCollection;

    removeClueFromCollection = removeClueFromCollection;

    addOrUpdateEntries = addOrUpdateEntries;

    addOrUpdateSense = addOrUpdateSense;

    getSingleClue = getSingleClue;

    updateSingleClue = updateSingleClue;

    getEntry = getEntry;

    getSensesForEntry = getSensesForEntry;

    getClueByEntryInCollection = getClueByEntryInCollection;

    addToEntryInfoQueue = addToEntryInfoQueue;

    queryEntries = queryEntries;

    insertUserIfNotExists = insertUserIfNotExists;

    initializeUserCollectionProgress = initializeUserCollectionProgress;
}

export default CruziDao;
