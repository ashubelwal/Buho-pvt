/**
* @File Name : UserProfileController.cls
* @Description :
* @Author : Cloudanalogu - Atul
* @Last Modified By :
* @Last Modified On : May 29, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | May 29, 2025 |   | Initial Version
**/

public with sharing class UserProfileController {
    @AuraEnabled(cacheable=true)
    public static User getCurrentUserInfo() {
        return [
            SELECT Id, Name, ContactId, Contact.State__c, Contact.Street__c, Contact.Postal_Code__c, Contact.Country__c, Contact.City__c, Contact.Phone, Contact.Email, Contact.Agency__r.Name, Contact.Date_of_Birth__c, CreatedDate FROM User
			// SELECT Id, Name from User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
    }
}