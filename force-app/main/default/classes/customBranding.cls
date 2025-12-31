public class customBranding {

    @AuraEnabled
    public static String getBranding(String userId) {
        return userId;
    }
}