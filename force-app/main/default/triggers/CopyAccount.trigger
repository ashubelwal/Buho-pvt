trigger CopyAccount on Account (after insert) {
   /*list<contact> cn=new list<contact>();
    for(Account acc: Trigger.New){
        contact Cnt= new contact();
        string[] name= acc.Name.split(' ');
        system.debug(name);
          if(name.Size()>1) 
          {
             cnt.FirstName= name[0];
              cnt.LastName=name[1];
          }
        else 
             cnt.LastName=name[0];
         cnt.AccountId=acc.id;
          cnt.Affiliate_Id__c=acc.Affiliate__c;
          cnt.City__c=acc.City__c;
         cnt.Country__c=acc.Country__c;
         cnt.Created_At__c=acc.Created_At__c;
         cnt.Customer_Id__c=acc.Customer_Id__c;
         cnt.Driver_Id__c=acc.Driver_Id__c;
         cnt.Group__c=acc.Group__c;
         cnt.Hear_About__c=acc.Hear_About__c;
         cnt.Id__c=acc.Id__c;
         cnt.Last_Login__c= acc.Last_Login__c;
         cnt.Login_Hash__c=acc.Login_Hash__c;
         cnt.Newsletter__c=acc.Newsletter__c;
         cnt.Password__c=acc.Password__c;
         cnt.Phone=acc.Phone__c;
         cnt.Postal_Code__c=acc.Postal_Code__c;
         cnt.Site__c=acc.Site__c;
         cnt.State__c=acc.State__c;
         cnt.Email=acc.Email__c;
         cnt.Street__c=acc.Street__c;
         cnt.Street_2__c=acc.Street_2__c;
         cnt.Updated_At__c=acc.Updated_At__c;
         cnt.Username__c=acc.Username__c;
           cn.add(cnt);    
    }
    insert cn;*/
}