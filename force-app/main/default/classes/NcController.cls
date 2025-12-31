/**
* @File Name : NcController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : March 3, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | March 3, 2025 |   | Initial Version
**/

public class NcController {
	@AuraEnabled
	public static Datetime getOrgDatetime() {
        try {
        Organization org = [SELECT TimeZoneSidKey FROM Organization LIMIT 1];
        String orgTimezone = org.TimeZoneSidKey;

        Datetime gmtTime = System.now();
        TimeZone tz = TimeZone.getTimeZone(orgTimezone);
        Integer timezoneOffsetSeconds = tz.getOffset(gmtTime) / 1000;

        Datetime orgTime = gmtTime.addSeconds(timezoneOffsetSeconds);
        return orgTime;
        } catch (Exception e) {
            // Handle any exceptions (e.g., query errors)
            System.debug('Error in getOrgDatetime: ' + e.getMessage());
            return null;
        }
    }
    
    @AuraEnabled
    public static Feedback__c submitFeedback(Integer rating, String feedback) {
        try {
            Feedback__c fb = new Feedback__c();
            fb.Rating__c = rating;
            fb.Comments__c = feedback;
            insert fb;
            return fb;
        } catch (Exception e) {
            throw new AuraHandledException('Error saving feedback: ' + e.getMessage());            
        }
    }

    @AuraEnabled
    public static List<Map<String, String>> getTowMetadataRecords() {
        try{
            List<Tow_Type_mdt__mdt> towMetadataList = [Select MasterLabel, Value__c from Tow_Type_mdt__mdt ];

            List<Map<String, String>> formattedList = new List<Map<String, String>>();

            for(Tow_Type_mdt__mdt record : towMetadataList ) {
                formattedList.add(new Map<String, String>{
                    'label' => record.MasterLabel,
                    'value' => record.Value__c
                });
            }

            return formattedList;
        } catch(Exception e) {
            System.debug('Error getching custom metadata: ' + e.getMessage());
            return new List<Map<String, String>>();
        }
    }

}