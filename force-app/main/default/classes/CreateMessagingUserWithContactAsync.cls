public class CreateMessagingUserWithContactAsync  implements Queueable{
    
    List<Contact> contactsToProcess;
  static  List<MessagingEndUser> newMessagingUsers = new List<MessagingEndUser>();
  static  List<MessagingEndUser> newMessagingUsersnew = new List<MessagingEndUser>();
  static List<MessagingEndUser> MessagingEndUserList = new List<MessagingEndUser>();

    
    public CreateMessagingUserWithContactAsync(List<Contact> contacts) {
        this.contactsToProcess = contacts;
    }
    
    public void execute(QueueableContext context) {
        
        string str = '';
        String accountIds;
        String contactId;
        
        list<Contact> contactList = new list<Contact>();
          Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id,AccountId, FirstName, LastName, Phone 
                                                     FROM Contact WHERE Id IN :contactsToProcess ]);
        for (Contact Contact : contactMap.values()) {
            if (!String.isBlank(contact.Phone)) {
                
                str = Contact.FirstName + ' ' + Contact.LastName;
                accountIds = Contact.AccountId;
                contactId = Contact.Id;
            
                createMessagingUser(Contact.FirstName ,Contact.LastName , Contact.Phone, Contact.Id , contact.AccountId);
            }
        }
          MessagingEndUserList =[Select Id , Name From MessagingEndUser Where Name =: str];
        if(!MessagingEndUserList.isEmpty()){
            for(MessagingEndUser message : MessagingEndUserList ){
                MessagingEndUser newUser = new MessagingEndUser();
                newUser.Id = message.Id;
                newUser.ContactId = contactId;
                newUser.AccountId = accountIds;
                newMessagingUsers.add(newUser);
                System.debug('1'+newMessagingUsers);

            }
        }
        if (!newMessagingUsers.isEmpty()) {
            try {
                update newMessagingUsers;
                System.debug('2'+newMessagingUsers);

            } catch (Exception e) {
                System.debug('Error inserting remaining MessagingEndUsers: ' + e.getMessage());
            }
           
        }
    }
    

    
    private static  void createMessagingUser(String FirstName, String LastName , String Phone ,String conId, string accId){
        if(MessagingEndUserList.isEmpty()){
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
            newUser.IsoCountryCode = '+2'; // Assuming US leads, adjust if needed
            newUser.MessageType = messagingChannelIdMap.get(messaging);
            newUser.MessagingChannelId = messaging; 
            newUser.MessagingConsentStatus = 'ImplicitlyOptedIn';
            newUser.MessagingPlatformKey = Phone; 
            newUser.ContactId = conId;
            newUser.AccountId = accId;
            newMessagingUsersnew.add(newUser);
        }
         System.debug('New Messaging Users to be upserted: ' + newMessagingUsers);
        if (!newMessagingUsersnew.isEmpty()) {
            try {
                upsert newMessagingUsersnew;
                system.debug('tesst'+newMessagingUsersnew);
            } catch (Exception e) {
                System.debug('Error inserting remaining MessagingEndUsers: ' + e.getMessage());
            }
        } 
        }
    }
    }