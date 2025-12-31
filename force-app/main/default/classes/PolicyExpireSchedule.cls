global class PolicyExpireSchedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        //calling the batch class to be scheduled
        PolicyExpireBatch policyBatch = new PolicyExpireBatch();
       
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(policyBatch,500);
    }
}