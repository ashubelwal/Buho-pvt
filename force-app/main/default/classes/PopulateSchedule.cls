public class PopulateSchedule {
    public static void PopulateScheduleMethod(){
         for(Integer i = 0; i<=55; i += 5 ){
            string CRON_EXP = '0 '+i+' * * * ? *'; 
            PopulatePaymentDetailClassbatch PopulatePaymentDetailClass = new PopulatePaymentDetailClassbatch();
            
            system.schedule('Calculate and populate payment 5 mins'+i, CRON_EXP, PopulatePaymentDetailClass);
        }  
    }
}