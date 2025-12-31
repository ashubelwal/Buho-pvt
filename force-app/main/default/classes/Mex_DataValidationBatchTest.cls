@isTest
public class Mex_DataValidationBatchTest {
    
    @isTest static void testCase1() {
        Account newAc = new Account();
        newAc.Name = 'Test Acc Validation';
        newAc.Email__c = 'test@validateAcc.com';
        newAc.Phone = '1234456432';
        newAc.Phone__c = '1234456432';
        newAc.Status_Confirmation__c = 'Pending';
        insert newAc;
       
        Test.startTest();
        Database.executeBatch(new MEX_DataValidationBatch(true));
        Test.stopTest();
    }
    
    @isTest static void testCase12(){
         Account newAc = new Account();
        newAc.Name = 'Test Acc Validation';
        newAc.Email__c = 'test@validateAcc.com';
        newAc.Phone = '1234456432';
        newAc.Phone__c = '1234456432';
        newAc.Status_Confirmation__c = 'Pending';
        insert newAc;
        String text = newAc.Id;
                            Blob key = Crypto.generateAesKey(128);
                            Blob data = Blob.valueOf(text);
                            String b64Data = EncodingUtil.base64Encode(data);
        Test.startTest();
        MEX_DataValidationBatch.updateAccountRecords('Confirmed', b64Data);
        Test.stopTest();
        
    }
    
    
    @isTest static void testCase2() {
      
        
        User newUsr = new User();
        newUsr.FirstName = 'Test dumy';
        newUsr.LastName = 'User Validation';
        newUsr.Email = 'test@validateUsr.com';
        newUsr.Username = 'test@validateUsr.com';
        newUsr.Status_Confirmation__c = 'Pending';
        newUsr.Alias = 'teValU';
        newUsr.LocaleSidKey = 'en_US';
        newUsr.LanguageLocaleKey = 'en_US';
        newUsr.EmailEncodingKey = 'UTF-8';
        newUsr.TimeZoneSidKey = 'America/Los_Angeles';
        newUsr.ProfileId = '00e15000000zYjrAAE';
        
        insert newUsr;
        
         String text = newUsr.Id;
                            Blob key = Crypto.generateAesKey(128);
                            Blob data = Blob.valueOf(text);
                            String b64Data = EncodingUtil.base64Encode(data);
        
        Test.startTest();
        Database.executeBatch(new MEX_DataValidationBatch(false));
        MEX_DataValidationBatch.updateAccountRecords('Confirmed', b64Data);
        Test.stopTest();
        
    }
}