global class ScheduleTranscationUpdateOnceBatch implements schedulable{
    global void execute(Schedulablecontext sc){
		Database.executeBatch(new TranscationUpdateOnceBatch());
    }
}