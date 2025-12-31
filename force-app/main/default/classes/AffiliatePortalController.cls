/**
 * @File Name : ContactLoginController.cls
 * @Description :
 * @Author :
 * @Last Modified By :
 * @Last Modified On : November 22, 2024
 * @Modification Log :
 *==============================================================================
 * Ver | Date | Author | Modification
 *==============================================================================
 * 1.0 | November 22, 2024 |   | Initial Version
 **/

public without sharing class AffiliatePortalController {
    
    @AuraEnabled(cacheable=false)
    public static Contact authenticateUser(String username, String password) {
        try {
            // Query the Contact object to find a matching record
            Contact contactRecord = [SELECT Id, Name, Email, Phone
        FROM Contact
        WHERE Username__c = :username 
        AND Password__c = :password 
        LIMIT 1];
            
            if (contactRecord != null) {
                
                //Creating a session Id and updating the contact
                String sessionId = generateSessionId();
                Datetime expirationTime = Datetime.now().addHours(6);
                
                // Update Contact with session details
                contactRecord.Session_Id__c = sessionId;
                contactRecord.Session_Expiration__c = expirationTime;
                update contactRecord;
                
                return contactRecord;
            } else {
                // If no matching contact is found, throw an error
                throw new AuraHandledException('Invalid Username or Password');
            }
        } catch (Exception ex) {
            throw new AuraHandledException('Invalid Username or Password');
        }
        
    }
    
    // Fetch policies related to the contact
    @AuraEnabled(cacheable=true)
    public static List<Policy__c> getPolicies(Id contactId) {
        return [SELECT Id, Name, Start_Date__c, Status_picklist__c, End_Date__c, Status__c ,Contact__r.Session_Id__c,Contact__r.Session_Expiration__c
                FROM Policy__c 
                WHERE Contact__c = :contactId];
    }
    
    @AuraEnabled
    public static Boolean validateSession(String sessionId, String contactId) {
        try {
            List<Contact> contacts = [SELECT Id, Session_Expiration__c 
                                       FROM Contact WHERE Session_Id__c = :sessionId AND Id =:contactId LIMIT 1];
            if (!contacts.isEmpty()) {
                Datetime now = Datetime.now();
                Datetime expirationTime = contacts[0].Session_Expiration__c;
                
                if (expirationTime != null && now > expirationTime) {
                    invalidateSession(contactId);
                    return false;
                }
                return true;
            }
        } catch (Exception ex) {
            throw new AuraHandledException('Error during session validation: ' + ex.getMessage());
        }
        return false; // Invalid session
    }
    
    @AuraEnabled
    public static String validateSessionThroughSessionId(String sessionId) {
        try {
            List<Contact> contacts = [SELECT Id, Session_Expiration__c 
                                       FROM Contact WHERE Session_Id__c = :sessionId LIMIT 1];
            if (!contacts.isEmpty()) {
                Datetime now = Datetime.now();
                Datetime expirationTime = contacts[0].Session_Expiration__c;
                
                if (expirationTime != null && now > expirationTime) {
                    invalidateSession(contacts[0].Id);
                    return 'false';
                }
                return contacts[0].Id;
            }
        } catch (Exception ex) {
            throw new AuraHandledException('Error during session validation: ' + ex.getMessage());
        }
        return 'false'; // Invalid session
    }
    
    @AuraEnabled
    public static Contact getContactData(String sessionId) {
        try {
            List<Contact> contacts = [SELECT Id,Name,Email,Phone, Session_Expiration__c 
                                       FROM Contact WHERE Session_Id__c = :sessionId LIMIT 1];
            if (!contacts.isEmpty()) {
                Datetime now = Datetime.now();
                Datetime expirationTime = contacts[0].Session_Expiration__c;
                
                if (expirationTime != null && now > expirationTime) {
                    invalidateSession(contacts[0].Id);
                    throw new AuraHandledException('Please login again');
                }
                return contacts[0];
            }
        } catch (Exception ex) {
            throw new AuraHandledException('Error during session validation: ' + ex.getMessage());
        }
        throw new AuraHandledException('Please login and try again');
    }
    
    private static String generateSessionId() {
        Blob randomBlob = Crypto.generateAesKey(128);
        return EncodingUtil.base64Encode(randomBlob);
    }
    
    
    
    public static void invalidateSession(String ContactId) {
        try {
            Contact contact = [SELECT Id FROM Contact WHERE Id=:contactId LIMIT 1];
            contact.Session_Id__c = null;
            contact.Session_Expiration__c = null;
            update contact;
        } catch (Exception ex) {
            System.debug('Failed to invalidate session: ' + ex.getMessage());
        }
    }
    
}