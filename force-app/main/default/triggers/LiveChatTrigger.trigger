trigger LiveChatTrigger on LiveChat_transcript__c (after insert,after update) {
    
    /*List<LiveChat_transcript__c> liveChatList = new List<LiveChat_transcript__c>();
    for(LiveChat_transcript__c objLiveChat : trigger.new){
        if(objLiveChat.Lead__c != null || objLiveChat.Contact__c != null){
            liveChatList.add(objLiveChat);
        }
    }
    if(liveChatList.size() > 0){
        LiveChatTriggerHandler.sendEmailAlert(liveChatList);
    }*/
}