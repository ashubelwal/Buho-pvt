global class UpdateBirthdateOnContactBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc){
        system.debug('Inside Start');
        return Database.getQueryLocator('SELECT Id, Date_of_Birth__c, Name, Email FROM Contact WHERE Email != null AND Date_of_Birth__c = null AND isUpdated__c = false LIMIT 50');
    }
    global void execute(Database.BatchableContext bc, List<Contact> scope){   
        system.debug('Inside Execute');
        set<String> emailSet = new set<String>();
        for(Contact objContact : scope){
            if(objContact.Email != null){
                emailSet.add(objContact.Email);
            }
        }
        
        List<Driver__c> objDriverList = [SELECT Id, Name, Dob__c, User_Email__c FROM Driver__c WHERE User_Email__c IN :emailSet AND default__c = 'Yes' AND Dob__c != null];
        Map<string, Driver__c> emailDriverMap = new Map<string, Driver__c>();
        for(Driver__C objDriver : objDriverList){
            if(!emailDriverMap.containsKey(objDriver.User_Email__c)){
                emailDriverMap.put(objDriver.User_Email__c, objDriver);
            }
        }
        
        List<Contact> objContactUpdateList = new List<Contact>();
        for(Contact objContact : scope){
            if(emailDriverMap.containsKey(objContact.Email) && objContact.Name == emailDriverMap.get(objContact.Email).Name){
                objContact.Date_of_Birth__c = emailDriverMap.get(objContact.Email).Dob__c;
            }
            objContact.isUpdated__c = true;
            objContactUpdateList.add(objContact);
        }
        
        system.debug('===> '+objContactUpdateList.size());
        database.update(objContactUpdateList,false);
        
    }
    global void finish(Database.BatchableContext bc){
        system.debug('Inside Finish');
    }
}