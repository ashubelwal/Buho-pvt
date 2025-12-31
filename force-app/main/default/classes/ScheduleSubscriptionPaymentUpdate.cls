global class ScheduleSubscriptionPaymentUpdate implements Schedulable {
    global void execute(Schedulablecontext sc){
        Database.executeBatch(new SubscriptionPaymentUpdateBatch(), 50);
    }
}