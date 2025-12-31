@isTest
public class CopyAccounttest{
   public static testmethod void Copyaccount(){
         Account acc= new Account();
         acc.Name='Nikhil sharma';
         acc.Phone='9815841993';
         acc.Affiliate__c=123;
         acc.Email__c='omveer@mobilyte.com';
         acc.City__c='chandigarh';
         acc.Country__c='india';
         acc.Created_At__c=system.today();
         acc.Customer_Id__c='78945ghs784';
         acc.Driver_Id__c='457896';
         acc.Group__c=145236;
         acc.Hear_About__c='Insurance Agent (please specify)';
         acc.Id__c='1234567896';
         acc.Last_Login__c='1/20/1970';
         acc.Login_Hash__c='55dcdgvchvc54';
         acc.Newsletter__c='yes';
         acc.Password__c='gcgvccc5c45cddj';
         acc.Phone__c='9815841993';
         acc.Postal_Code__c='4454';
         acc.Site__c='fhvjfbvjhfb';
         acc.State__c='india';
         acc.Street__c='ght14';
         acc.Street_2__c='ghb14';
         acc.Updated_At__c=system.today();
         acc.Username__c='omveer@gmail.com';
       
       
       
        insert acc;
        
        
    }
    
}