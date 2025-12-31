public class ContactTriggerHandler {
    public static void updateLeadData(Map<Id,Contact> condataMap){
        try{
            if(condataMap.size() > 0){
                Set<Id> contactIdSet = condataMap.keySet();
                List<Lead> leaddata = [SELECT LastName, FirstName, Phone, Email, ConvertedContactId,Geographic_State_of_Interest__c FROM Lead WHERE ConvertedContactId IN :contactIdSet ];
                List<Lead> updatedLeadData = new List<Lead>();
                Boolean updated = false;
                for(Lead ld : leaddata){
                    Contact con = condataMap.get(ld.ConvertedContactId);
                    
                    if(ld.Geographic_State_of_Interest__c != con.Policy_Destinations__c && con.Policy_Destinations__c != null){
                        ld.Geographic_State_of_Interest__c = con.Policy_Destinations__c;
                        updated = true; 
                    }
                    
                    if(ld.FirstName != con.FirstName){
                        ld.FirstName = con.FirstName;
                        updated = true;
                    }
                    
                    if(ld.LastName != con.LastName){
                        ld.LastName = con.LastName;
                        updated = true;
                        
                    }
                    
                    if(ld.Phone == null && con.Phone != null){
                        ld.Phone = con.Phone;
                        updated = true;
                        
                    } else if(ld.Phone != null && con.Phone != null && ld.Phone != con.Phone){
                        ld.Phone = con.Phone; 
                        updated = true; 
                    } else if(ld.Phone != null && con.Phone == null){
                         ld.Phone = con.Phone; 
                         updated = true; 
                    }
                    
                    if(ld.Email == null && con.Email != null){
                        ld.Email = con.Email;
                        updated = true;
                    } else if(ld.Email != null && con.Email != null && ld.Email != con.Email){
                        ld.Email = con.Email;
                        updated = true;
                    } else if(ld.Email != null && con.Email == null ){
                        ld.Email = con.Email;
                        updated = true;
                    }
                    
                    if(updated == true){
                        updatedLeadData.add(ld);
                    }
                    updated = false;
                }
                if(updatedLeadData.size() > 0){
                    Database.update(updatedLeadData);
                }
            }
        }catch(Exception e){
            System.debug('Exception caught in update lead data at line number' +e.getLineNumber());
        }
    }
}