public class CreateMessagingUserAsync implements Queueable {
    
    List<Lead> leadsToProcess;
    Static List<MessagingEndUser> newMessagingUsers = new List<MessagingEndUser>();
    
    public CreateMessagingUserAsync(List<Lead> leads) {
        this.leadsToProcess = leads;
    }
    
    public void execute(QueueableContext context) {
        Map<Id, Lead> leadsMap = new Map<Id, Lead>([SELECT Id, FirstName, LastName, Phone, 
                                                    Company FROM Lead WHERE Id IN :leadsToProcess AND IsConverted = false ]);
        for (Lead lead : leadsMap.values()) {
            if (!String.isBlank(lead.Phone)) {
                createMessagingUser(lead.FirstName ,lead.LastName , lead.Phone, lead.Id);
            }
        }
    }
    
    private static  void createMessagingUser(String FirstName, String LastName , String Phone ,String leadId){
        Map<Id,String> messagingChannelIdMap = new  Map<Id,String>();
        List<Messaging_Channel_Id__mdt	> messagingchannellist = [SELECT Messaging_Channel_Id__c, Type__c  FROM Messaging_Channel_Id__mdt] ;
         System.debug('Messaging Channel Ids and Types: ' + messagingchannellist);
        
        System.debug('Id is' +messagingchannellist);
        for(Messaging_Channel_Id__mdt messChen : messagingchannellist){
            messagingChannelIdMap.put(messChen.Messaging_Channel_Id__c, messChen.Type__c);
        }
         System.debug('Messaging Channel Id Map: ' + messagingChannelIdMap);
        for(Id messaging : messagingChannelIdMap.keySet()){
            MessagingEndUser newUser = new MessagingEndUser();
            newUser.Name = FirstName + ' ' + LastName;
            newUser.IsoCountryCode = '+1'; // Assuming US leads, adjust if needed
            newUser.MessageType = messagingChannelIdMap.get(messaging);
            newUser.MessagingChannelId = messaging; 
            newUser.MessagingConsentStatus = 'ImplicitlyOptedIn';
            newUser.MessagingPlatformKey = Phone; 
            newUser.LeadId = leadId; 
            newMessagingUsers.add(newUser);
        }
         System.debug('New Messaging Users to be upserted: ' + newMessagingUsers);
        if (!newMessagingUsers.isEmpty()) {
            try {
                upsert newMessagingUsers;
            } catch (Exception e) {
                System.debug('Error inserting remaining MessagingEndUsers: ' + e.getMessage());
            }
        }
        
    }
}