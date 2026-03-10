/**
 * @description Controller for BÚHO Dashboard, My Policy, My Vehicles & Vehicle Edit LWC components.
 * Provides policy and vehicle data for the logged-in community user.
 * @author BÚHO Insurance
 * @date 2026
 */
public without sharing class BuhoDashboardController {

    // ───────────────────────────────────────────────
    //  POLICY METHODS
    // ───────────────────────────────────────────────

    /**
     * @description Retrieves all policies belonging to the currently logged-in
     *              community user's Contact record.
     * @return List<Policy__c> The user's policies ordered by most recent first.
     */
    @AuraEnabled(cacheable=true)
    public static List<Policy__c> getUserPolicies() {
        Id contactId = getLoggedInContactId();

        if (contactId == null) {
            return new List<Policy__c>();
        }

        return [
            SELECT Id,
                   Name,
                   Reference_number__c,
                   Vehicle_Year__c,
                   Vehicle_Make__c,
                   Vehicle_Model__c,
                   Vehicle_type__c,
                   Start_Date__c,
                   End_Date__c,
                   Package__c,
                   Total_Premium_Amount__c,
                   Net_Premium__c,
                   Term__c,
                   Term_days__c,
                   Status_picklist__c,
                   status__c,
                   Policy_Type_picklist__c,
                   Vehicle_Policy__c,
                   Vehicle_Value__c,
                   Surcharge__c,
                   Issued_At__c,
                   Contact__c
            FROM Policy__c
            WHERE Contact__c = :contactId
            ORDER BY Start_Date__c DESC
        ];
    }

    /**
     * @description Retrieves a single policy record by its Id with all detail fields.
     * @param policyId The Id of the Policy__c record.
     * @return Policy__c The full policy record.
     */
    @AuraEnabled(cacheable=true)
    public static Policy__c getPolicyById(Id policyId) {
        if (policyId == null) {
            return null;
        }

        List<Policy__c> policies = [
            SELECT Id,
                   Name,
                   Reference_number__c,
                   Status_picklist__c,
                   Policy_Type_picklist__c,
                   Underwriter_picklist__c,
                   Start_Date__c,
                   Start_Time__c,
                   End_Date__c,
                   End_Time__c,
                   Package__c,
                   Vehicle_type__c,
                   Vehicle_Year__c,
                   Vehicle_Make__c,
                   Vehicle_Model__c,
                   Vehicle_Value__c,
                   Quote_c__c,
                   Quote_c__r.Name,
                   Term__c,
                   Term_days__c,
                   Policy__c,
                   Policy__r.Name,
                   Fully_Earned__c,
                   Issued_At__c,
                   Agent_Name__c,
                   Agency_Name__c,
                   Source__c,
                   Why_Terminate_Policy__c,
                   Gold__c,
                   Max__c,
                   Platinum__c,
                   Medical__c,
                   Medical_picklist__c,
                   Insured_value__c,
                   Liability__c,
                   Liability_picklist__c,
                   Territory_picklist__c,
                   Net_Premium__c,
                   Physical_Damage__c,
                   Broker_Policy_Fee__c,
                   Total_Theft_Payment__c,
                   I_V_A_Mex_Tax__c,
                   Liability_Payment__c,
                   Surcharge__c,
                   Medical_Payment__c,
                   Total_Premium_Amount__c,
                   Platinum_Endorsement_Payment__c,
                   What_is_your_trip_destination_in_US__c,
                   What_is_the_purpose_of_trip__c,
                   Contact__c
            FROM Policy__c
            WHERE Id = :policyId
            LIMIT 1
        ];

        return policies.isEmpty() ? null : policies[0];
    }

    // ───────────────────────────────────────────────
    //  VEHICLE METHODS
    // ───────────────────────────────────────────────

    /**
     * @description Retrieves all non-deleted vehicles belonging to the currently
     *              logged-in community user's Contact record.
     *              Includes the related Policy lookup fields for coverage context.
     * @return List<Vehicle__c> The user's vehicles ordered by newest first.
     */
    @AuraEnabled(cacheable=true)
    public static List<Vehicle__c> getUserVehicles() {
        Id contactId = getLoggedInContactId();

        if (contactId == null) {
            return new List<Vehicle__c>();
        }
        System.debug('@@@contactId'+contactId);
        List<Vehicle__c> lstVehicle = [
                SELECT Id,
                    Name,
                    Year__c,
                    Make__c,
                    Model__c,
                    Vin__c,
                    Value__c,
                    Vehicle_Type__c,
                    Vehicle_sub_type__c,
                    Type__c,
                    Registered_Plate__c,
                    Registered_State__c,
                    Registered_Country__c,
                    Vehicle_Owner_Name__c,
                    vehicle_coverage_status__c,
                    Created_At__c,
                    Policy__c,
                    Policy__r.Name,
                    Policy__r.Reference_number__c,
                    Policy__r.Package__c,
                    Policy__r.Status_picklist__c,
                    Policy__r.Total_Premium_Amount__c,
                    Policy__r.Surcharge__c,
                    Policy__r.Term__c,
                    Policy__r.Vehicle_deductible_collision__c,
                    Policy_Expiration__c,
                    Deleted_vehicle__c,
                    Contact__c
                FROM Vehicle__c
                WHERE Contact__c = :contactId
                AND Deleted_vehicle__c = false
                ORDER BY CreatedDate DESC
                ];
        return lstVehicle;
    }

    /**
     * @description Retrieves a single vehicle record by its Id.
     * @param vehicleId The Id of the Vehicle__c record.
     * @return Vehicle__c The vehicle record with full field set.
     */
    @AuraEnabled(cacheable=true)
    public static Vehicle__c getVehicleById(Id vehicleId) {
        if (vehicleId == null) {
            return null;
        }

        List<Vehicle__c> vehicles = [
            SELECT Id,
                   Name,
                   Year__c,
                   Make__c,
                   Model__c,
                   Vin__c,
                   Value__c,
                   Vehicle_Type__c,
                   Vehicle_sub_type__c,
                   Type__c,
                   Registered_Plate__c,
                   Registered_State__c,
                   Registered_Country__c,
                   Vehicle_Owner_Name__c,
                   vehicle_coverage_status__c,
                   Created_At__c,
                   Policy__c,
                   Policy__r.Name,
                   Policy__r.Reference_number__c,
                   Policy__r.Package__c,
                   Policy__r.Status_picklist__c,
                   Policy__r.Total_Premium_Amount__c,
                   Policy__r.Surcharge__c,
                   Policy__r.Term__c,
                   Policy__r.Vehicle_deductible_collision__c,
                   Policy_Expiration__c,
                   Deleted_vehicle__c,
                   Contact__c
            FROM Vehicle__c
            WHERE Id = :vehicleId
            LIMIT 1
        ];

        return vehicles.isEmpty() ? null : vehicles[0];
    }

    /**
     * @description Creates or updates a Vehicle__c record for the logged-in community user.
     *              Automatically stamps the current user's Contact on the record.
     *              Accepts the full Vehicle__c sObject so new fields can be added in
     *              the LWC without requiring Apex changes.
     * @param vehicle The Vehicle__c sObject instance to upsert.
     * @return Id     The Id of the created / updated Vehicle__c record.
     */
    @AuraEnabled
    public static Id saveVehicle(Vehicle__c vehicle) {
        Id contactId = getLoggedInContactId();
        vehicle.Contact__c = contactId;

        upsert vehicle;
        return vehicle.Id;
    }

    /**
     * @description Soft-deletes a vehicle by setting Deleted_vehicle__c = true.
     * @param vehicleId The Id of the Vehicle__c record to remove.
     */
    @AuraEnabled
    public static void removeVehicle(Id vehicleId) {
        if (vehicleId == null) {
            return;
        }
        Vehicle__c veh = new Vehicle__c(Id = vehicleId, Deleted_vehicle__c = true);
        update veh;
    }

    // ───────────────────────────────────────────────
    //  DRIVER METHODS
    // ───────────────────────────────────────────────

    /**
     * @description Retrieves all non-deleted drivers belonging to the currently
     *              logged-in community user's Contact record.
     * @return List<Driver__c> The user's drivers ordered by newest first.
     */
    @AuraEnabled(cacheable=true)
    public static List<Driver__c> getUserDrivers() {
        Id contactId = getLoggedInContactId();

        if (contactId == null) {
            return new List<Driver__c>();
        }

        return [
            SELECT Id,
                   Name,
                   First_Name__c,
                   Last_Name__c,
                   Dob__c,
                   Age_Range__c,
                   Driver_Type__c,
                   Email__c,
                   Phone__c,
                   Address__c,
                   Address_Line_2__c,
                   City__c,
                   State_Province__c,
                   Country__c,
                   Postal_Code__c,
                   license_number__c,
                   License_state__c,
                   License_Country__c,
                   License_Expire__c,
                   Primary_insured__c,
                   default__c,
                   Deleted_Driver__c,
                   created_at__c,
                   Contact__c,
                   Policy__c,
                   Policy__r.Name,
                   Policy__r.Reference_number__c,
                   Vehicle_Driver__c,
                   Vehicle_Driver__r.Name
            FROM Driver__c
            WHERE Contact__c = :contactId
              AND Deleted_Driver__c = false
            ORDER BY CreatedDate DESC
        ];
    }

    /**
     * @description Retrieves a single driver record by its Id with all detail fields.
     * @param driverId The Id of the Driver__c record.
     * @return Driver__c The full driver record.
     */
    @AuraEnabled(cacheable=true)
    public static Driver__c getDriverById(Id driverId) {
        if (driverId == null) {
            return null;
        }

        List<Driver__c> drivers = [
            SELECT Id,
                   Name,
                   First_Name__c,
                   Last_Name__c,
                   Dob__c,
                   Age_Range__c,
                   Driver_Type__c,
                   Email__c,
                   Phone__c,
                   Address__c,
                   Address_Line_2__c,
                   City__c,
                   State_Province__c,
                   Country__c,
                   Postal_Code__c,
                   license_number__c,
                   License_state__c,
                   License_Country__c,
                   License_Expire__c,
                   Primary_insured__c,
                   default__c,
                   Deleted_Driver__c,
                   created_at__c,
                   Contact__c,
                   Policy__c,
                   Policy__r.Name,
                   Policy__r.Reference_number__c,
                   Vehicle_Driver__c,
                   Vehicle_Driver__r.Name
            FROM Driver__c
            WHERE Id = :driverId
            LIMIT 1
        ];

        return drivers.isEmpty() ? null : drivers[0];
    }

    // ───────────────────────────────────────────────
    //  QUOTE METHODS
    // ───────────────────────────────────────────────

    /**
     * @description Retrieves all quotes belonging to the currently logged-in
     *              community user's Contact record.
     * @return List<Quote__c> The user's quotes ordered by most recent first.
     */
    @AuraEnabled(cacheable=true)
    public static List<Quote__c> getUserQuotes() {
        Id contactId = getLoggedInContactId();

        if (contactId == null) {
            return new List<Quote__c>();
        }

        return [
            SELECT Id,
                   Name,
                   Quote_Status__c,
                   Quote_Value__c,
                   Net_Premium__c,
                   Policy_Fee__c,
                   Broker_Policy_Fee__c,
                   I_V_A_Mex_Tax__c,
                   Policy_Type__c,
                   Underwriter__c,
                   Vehicle_Age__c,
                   Driver_Age__c,
                   Vehicle_Make__c,
                   Vehicle_Model__c,
                   Vehicle_Year__c,
                   Vehicle_Value__c,
                   Vehicle_Type__c,
                   Coverage__c,
                   Medical__c,
                   Liability__c,
                   Territory__c,
                   Term_Days__c,
                   Start_Date_for_Coverage__c,
                   End_Date_for_Coverage__c,
                   Start_Time__c,
                   End_Time__c,
                   Time_Zone__c,
                   Physical_Damage__c,
                   Total_Theft_Payment__c,
                   Liability_Payment__c,
                   Medical_Payment__c,
                   Platinum_Endorsment__c,
                   Surcharge__c,
                   Gold__c,
                   Max__c,
                   Platinum__c,
                   Trailering__c,
                   Date_of_Birth__c,
                   Type_of_Vessel__c,
                   Is_the_Maximum_Speed_more_than_50_mph__c,
                   Is_the_owner_living_in_Mexico__c,
                   Any_Boat_Operator_Under_22__c,
                   Vessel_Length__c,
                   Third_Party_Bodily_Injury__c,
                   Property_Damage_Liability__c,
                   Vehicle_Sub_type__c,
                   Vehicle_Deductible_Collision__c,
                   Vehicle_Deductible_Comprehensive__c,
                   Renew_Quote__c,
                   Lead_Id__c,
                   Contact__c,
                   Vehicle__c,
                   Vehicle__r.Name
            FROM Quote__c
            WHERE Contact__c = :contactId
            ORDER BY CreatedDate DESC
        ];
    }

    /**
     * @description Retrieves a single quote record by its Id with all detail fields.
     * @param quoteId The Id of the Quote__c record.
     * @return Quote__c The full quote record.
     */
    @AuraEnabled(cacheable=true)
    public static Quote__c getQuoteById(Id quoteId) {
        if (quoteId == null) {
            return null;
        }

        List<Quote__c> quotes = [
            SELECT Id,
                   Name,
                   Quote_Status__c,
                   Quote_Value__c,
                   Net_Premium__c,
                   Policy_Fee__c,
                   Broker_Policy_Fee__c,
                   I_V_A_Mex_Tax__c,
                   Policy_Type__c,
                   Underwriter__c,
                   Vehicle_Age__c,
                   Driver_Age__c,
                   Vehicle_Make__c,
                   Vehicle_Model__c,
                   Vehicle_Year__c,
                   Vehicle_Value__c,
                   Vehicle_Type__c,
                   Coverage__c,
                   Medical__c,
                   Liability__c,
                   Territory__c,
                   Term_Days__c,
                   Start_Date_for_Coverage__c,
                   End_Date_for_Coverage__c,
                   Start_Time__c,
                   End_Time__c,
                   Time_Zone__c,
                   Physical_Damage__c,
                   Total_Theft_Payment__c,
                   Liability_Payment__c,
                   Medical_Payment__c,
                   Platinum_Endorsment__c,
                   Surcharge__c,
                   Gold__c,
                   Max__c,
                   Platinum__c,
                   Trailering__c,
                   Date_of_Birth__c,
                   Type_of_Vessel__c,
                   Is_the_Maximum_Speed_more_than_50_mph__c,
                   Is_the_owner_living_in_Mexico__c,
                   Any_Boat_Operator_Under_22__c,
                   Vessel_Length__c,
                   Third_Party_Bodily_Injury__c,
                   Property_Damage_Liability__c,
                   Vehicle_Sub_type__c,
                   Vehicle_Deductible_Collision__c,
                   Vehicle_Deductible_Comprehensive__c,
                   Renew_Quote__c,
                   Lead_Id__c,
                   Contact__c,
                   Vehicle__c,
                   Vehicle__r.Name
            FROM Quote__c
            WHERE Id = :quoteId
            LIMIT 1
        ];

        return quotes.isEmpty() ? null : quotes[0];
    }

    // ───────────────────────────────────────────────
    //  TRANSACTION METHODS
    // ───────────────────────────────────────────────

    /**
     * @description Retrieves all transactions belonging to the currently logged-in
     *              community user's Contact / Account.
     * @return List<Transaction__c> The user's transactions ordered by most recent first.
     */
    @AuraEnabled(cacheable=true)
    public static List<Transaction__c> getUserTransactions() {
        Id contactId = getLoggedInContactId();

        if (contactId == null) {
            return new List<Transaction__c>();
        }

        // Derive AccountId from the contact
        List<Contact> contacts = [SELECT AccountId FROM Contact WHERE Id = :contactId LIMIT 1];
        Id accountId = (!contacts.isEmpty()) ? contacts[0].AccountId : null;

        if (accountId == null) {
            return new List<Transaction__c>();
        }

        return [
            SELECT Id,
                   Name,
                   Name__c,
                   Amount__c,
                   Premium_Amount__c,
                   Premium_Base__c,
                   Tax_Iva__c,
                   Option_Total__c,
                   Avq_Total__c,
                   Latin_Assist__c,
                   Payment_Type__c,
                   Mode__c,
                   type__c,
                   Description__c,
                   CC_Mask__c,
                   Gateway_Id__c,
                   gateway_source__c,
                   Invoice_ID__c,
                   Coupon_ID__c,
                   IP__c,
                   Street__c,
                   Street_2__c,
                   City__c,
                   State__c,
                   Country__c,
                   Postal_Code__c,
                   Term_Days__c,
                   Created_At__c,
                   Updated_At__c,
                   Policy_Transaction__c,
                   Policy_Transaction__r.Name,
                   Policy_Transaction__r.Reference_number__c,
                   Quote_c__c,
                   Quote_c__r.Name,
                   Account_Transaction__c
            FROM Transaction__c
            WHERE Account_Transaction__c = :accountId
            ORDER BY Created_At__c DESC
        ];
    }

    // ───────────────────────────────────────────────
    //  USER / PROFILE METHODS
    // ───────────────────────────────────────────────

    /**
     * @description Returns the first name of the currently logged-in user.
     * @return String The user's first name.
     */
    @AuraEnabled(cacheable=true)
    public static String getUserName() {
        return UserInfo.getFirstName();
    }

    /**
     * @description Returns the logged-in User record with related Contact fields.
     *              All formatting / display logic is handled in the LWC JS layer.
     * @return User The current user with Contact relationship fields.
     */
    @AuraEnabled(cacheable=true)
    public static User getUserProfile() {
        Id userId = UserInfo.getUserId();

        List<User> users = [
            SELECT Id, FirstName, LastName, Email, Phone, ContactId,
                   Contact.Birthdate,
                   Contact.Date_of_Birth__c,
                   Contact.Phone,
                   Contact.MailingStreet,
                   Contact.MailingCity,
                   Contact.MailingState,
                   Contact.MailingPostalCode,
                   Contact.MailingCountry
            FROM User
            WHERE Id = :userId
            LIMIT 1
        ];

        return users.isEmpty() ? null : users[0];
    }

    /**
     * @description Resolves the ContactId for the currently logged-in community user.
     * @return Id The Contact Id associated with the running user, or null if not found.
     */
    private static Id getLoggedInContactId() {
        Id userId = UserInfo.getUserId();

        List<User> users = [
            SELECT ContactId
            FROM User
            WHERE Id = :userId
            LIMIT 1
        ];

        if (!users.isEmpty() && users[0].ContactId != null) {
            return users[0].ContactId;
        }
        ///return '003VD000017Vlz1YAC';
        return null;
    }
}
