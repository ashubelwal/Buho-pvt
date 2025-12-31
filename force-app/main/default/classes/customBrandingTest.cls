@isTest
public class customBrandingTest {
  @isTest
    static void getBrandingTest(){
        String userId = '0WKEkdjek803720';
        Test.startTest();
         String value = customBranding.getBranding(userId);
        Test.stopTest();
        System.assertEquals(userId,value,'Assert passed');
    }
}