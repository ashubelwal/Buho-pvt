global class GenerateTextFileBatchScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        GenerateTextFileController generateTextFileObj = new GenerateTextFileController();
        database.executebatch(generateTextFileObj);
    }
}