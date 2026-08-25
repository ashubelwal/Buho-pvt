public without sharing class AffiliateController {
    @AuraEnabled(cacheable = true)
    public static string getAffiliateUser(String affiliateId){
        try{
            if(affiliateId != null){
                List<Affiliate__c> affiliateUserList = [SELECT Affiliate_Id__c, Agency_Logo__c, 
                                                        Agent_Id__c,                                                          
                                                        Agent_Contact__c,
                                                        Agent_Fee__c ,
                                                        Agency_Id__c, 
                                                        Owner_Name__c, 
                                                        Owner_Photo__c,
                                                        Theme_Primary_Color__c,
                                                        Theme_Accent_Color__c,
                                                        Theme_Light_Color__c
                                                        FROM Affiliate__c WHERE Affiliate_Id__c =: affiliateId];
                if(affiliateUserList.size() > 0){
                    if(affiliateUserList[0].Agent_Fee__c == null){
                        affiliateUserList[0].Agent_Fee__c = 0;
                    }
                }
                
                System.debug(affiliateUserList);
                
                
                if(affiliateUserList.size() > 0){
                    return JSON.serialize(affiliateUserList[0]);
                }else{
                    throw new MyCustomException('Unable to query affiliate user using Id ' + affiliateId);
                }
            }
            else{
                throw new MyCustomException('Affiliate Id is null');
            }
        }catch(Exception ex){
            throw new MyCustomException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static string saveLeadDetails(String leadJson, String quoteJSON, String vehicleJSON, String towedlistJSON, String affiliateCode){
        try {
            if(String.isNotBlank(leadJson)){
                
                if(affiliateCode != null){
                    List<Affiliate__c> affiliateUserList = [SELECT Id, 
                                                                 Affiliate_Id__c, Agency_Logo__c, 
                                                                 Agent_Id__c,  Agency_Contact__c,
                                                                 Agent_Contact__c,Agent_Fee__c ,
                                                                 Agency_Id__c, Owner_Name__c, 
                                                                 Owner_Photo__c
                                                                 FROM Affiliate__c Where Affiliate_Id__c =: affiliateCode];
                    
                    
                    System.debug(affiliateUserList);
                    
                    if(affiliateUserList.size() > 0){
                        Lead getLeadData = new Lead();
                        getLeadData = (Lead)JSON.deserialize(leadJson, lead.class);
                        getLeadData.Company = getLeadData.FirstName + ' '+ getLeadData.LastName;
                        getLeadData.Insurance_Type__c = getLeadData.Policy_Type__c;
                        getLeadData.Quote_Details__c = quoteJSON;
                        if(getLeadData.Policy_Type__c == 'Watercraft'){
                            getLeadData.Watercraft_Detail__c = vehicleJSON;
                        }else{
                            getLeadData.Vehicle_Details__c = vehicleJSON;
                        }
                        
                        if(affiliateUserList.size() > 0 && affiliateUserList[0].Agency_Contact__c != null){
                            getLeadData.Agency__c = affiliateUserList[0].Agency_Contact__c;
                        }
                        
                        if(affiliateUserList.size() > 0 && affiliateUserList[0].Agent_Contact__c != null){
                            getLeadData.Agent__c = affiliateUserList[0].Agent_Contact__c;
                        }

                        getLeadData.Affiliate__c = affiliateUserList[0].Id;
                        
                        getLeadData.Towing__c = towedlistJSON;
                        System.debug('Lead Before Saving'+getLeadData);
                        upsert getLeadData;
                        System.debug('Lead AFTER Saving'+getLeadData);
                        return JSON.serialize(getLeadData);
                    }else{
                        throw new AuraHandledException('Affiliate List is Null');
                    }
                }else{
                    throw new AuraHandledException('AffiliateCode is Null');
                }
                
                
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    
    public class MyCustomException extends Exception {}
    
}