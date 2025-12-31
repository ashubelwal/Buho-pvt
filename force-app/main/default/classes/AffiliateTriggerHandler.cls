public without sharing class AffiliateTriggerHandler {
    
    public static void getUniqueAffiliateId(List<Affiliate__c> newaffiliateList){
        try{
            if(newaffiliateList.size() > 0){
                for(Affiliate__c aff : newaffiliateList){
                    if(aff.Affiliate_Id__c == null){
                        aff.Affiliate_Id__c = AffiliateTriggerHandler.generateCode();
                    }
                }
            }
        }catch(Exception e){
            throw new MyCustomException('Unable to create the Unique Id . Error : '+e.getMessage() +'ClassName : getUnqiueAffiliateId');
        }
    }
    
    public static String generateCode() {
        // Generate a 3-digit random number
        Integer threeDigitNumber = (Integer)Math.floor(Math.random() * 900) + 10; // Generates a number between 100-999
        
        // Generate a random number
        Integer randomNumber = (Integer)Math.floor(Math.random() * 10); // Generates a number between 0-9
        String alphabets = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        // Generate two random indices between 0 and 25
        Integer index1 = (Integer)(Math.random() * 26);
        Integer index2 = (Integer)(Math.random() * 26);
        
        // Retrieve random characters using the generated indices
        String randomAlphabet1 = alphabets.substring(index1, index1 + 1);
        String randomAlphabet2 = alphabets.substring(index2, index2 + 1);
        
        System.debug('Random Alphabets: ' + randomAlphabet1 + randomAlphabet2);
        
        
        
        // Construct the final code
        String generatedCode = 'AFT' + threeDigitNumber + randomNumber + randomAlphabet1 + randomAlphabet2;
        
        return generatedCode;
    }
    
    public class MyCustomException extends Exception {}
    
}