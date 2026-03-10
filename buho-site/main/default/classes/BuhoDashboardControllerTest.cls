/**
 * @File Name : BuhoDashboardControllerTest.cls
 * @Description : Test class for BuhoDashboardController
 * @Author : System
 * @Last Modified On : February 27, 2026
 * @Modification Log :
 *==============================================================================
 * Ver | Date | Author | Modification
 *==============================================================================
 * 1.0 | February 27, 2026 |   | Initial Version
 **/

@isTest
private class BuhoDashboardControllerTest {

    // ───────────────────────────────────────────────
    //  TEST DATA SETUP
    // ───────────────────────────────────────────────

    @TestSetup
    static void setupTestData() {
        // Disable policy triggers during test data creation
        TriggerSwitch__c customset = new TriggerSwitch__c();
        customset.Name = 'PolicyTrigger';
        customset.Active__c = FALSE;
        insert customset;

        // Community profile
        Profile profileId = [
            SELECT Id FROM Profile
            WHERE Name = 'Buho Customer Community Plus Login User'
            LIMIT 1
        ];

        // Account
        Account testAccount = new Account(
            Name = 'Test Dashboard Account',
            AnnualRevenue = 5000
        );
        insert testAccount;

        // Contact
        Contact testContact = new Contact(
            FirstName = 'Dashboard',
            LastName  = 'TestUser',
            Email     = 'dashboardtest@example.com',
            Phone     = '5551234567',
            AccountId = testAccount.Id
        );
        insert testContact;

        // Community User tied to Contact
        User testUser = new User();
        testUser.LastName           = 'DashTest';
        testUser.Email              = 'dashtest' + String.valueOf(System.today()) + '@test.com';
        testUser.Alias              = 'DshTst';
        testUser.Username           = 'dashtest' + String.valueOf(System.today()) + '@test.com';
        testUser.CommunityNickname  = 'dashtest01';
        testUser.LocaleSidKey       = 'en_US';
        testUser.TimeZoneSidKey     = 'GMT';
        testUser.ProfileID          = profileId.Id;
        testUser.LanguageLocaleKey  = 'en_US';
        testUser.EmailEncodingKey   = 'UTF-8';
        testUser.ContactId          = testContact.Id;
        insert testUser;

        // Lead (needed for Quote & Vehicle)
        Lead testLead = new Lead(
            FirstName = 'Dashboard',
            LastName  = 'Lead',
            Email     = 'dashlead@example.com',
            Phone     = '5559876543',
            Company   = 'Dashboard Test Co',
            Status    = 'New'
        );
        insert testLead;

        // Quote
        Quote__c testQuote = new Quote__c(
            Lead__c                    = testLead.Id,
            Contact__c                 = testContact.Id,
            Account__c                 = testAccount.Id,
            Start_Date_for_Coverage__c = System.today(),
            End_Date_for_Coverage__c   = System.today() + 30,
            Start_Time__c             = Time.newInstance(8, 0, 0, 0),
            End_Time__c               = Time.newInstance(8, 0, 0, 0),
            Driver_Age__c             = 35,
            Underwriter__c            = 'Chubb',
            Coverage__c               = 'Complete',
            Territory__c              = 'Full',
            Term__c                   = 'Daily',
            Policy_Type_picklist__c   = 'Automobile',
            Vehicle_Type__c           = 'Automobile',
            Medical__c                = '2,000/10,000',
            Liability__c              = '100,000',
            Date_of_Birth__c          = Date.newInstance(1990, 5, 15),
            Quote_Value__c            = 450.00,
            Net_Premium__c            = 350.00,
            Broker_Policy_Fee__c      = 30.00,
            I_V_A_Mex_Tax__c          = 56.00,
            Vehicle_Value__c          = 25000.00,
            Vehicle_Make__c           = 'Toyota',
            Vehicle_Model__c          = 'Camry',
            Vehicle_Year__c           = '2022'
        );
        insert testQuote;

        // Policy
        Policy__c testPolicy = new Policy__c(
            Name                    = 'TestPolicy-001',
            Contact__c              = testContact.Id,
            Quote_c__c              = testQuote.Id,
            Policy_Type_picklist__c = 'Automobile',
            Underwriter_picklist__c = 'Chubb',
            Status_picklist__c      = 'Active',
            Package__c              = 'Complete',
            Start_Date__c           = System.today(),
            End_Date__c             = System.today() + 30,
            Term__c                 = 'Daily',
            Territory_picklist__c   = 'Full',
            Liability_picklist__c   = '100,000',
            Medical_picklist__c     = '2,000/10,000',
            Net_Premium__c          = 350.00,
            Broker_Policy_Fee__c    = 30.00,
            I_V_A_Mex_Tax__c        = 56.00,
            Surcharge__c            = 10.00,
            Vehicle_type__c         = 'Automobile'
        );
        insert testPolicy;

        // Vehicle
        Vehicle__c testVehicle = new Vehicle__c(
            Contact__c            = testContact.Id,
            Account_Vehicle__c    = testAccount.Id,
            Lead__c               = testLead.Id,
            Year__c               = '2022',
            Make__c               = 'Toyota',
            Model__c              = 'Camry',
            Type__c               = 'Car',
            Vehicle_Type__c       = 'Automobile',
            Vin__c                = 'JTD12345678901234',
            Value__c              = 25000,
            Registered_Plate__c   = 'ABC1234',
            Registered_State__c   = 'California',
            Registered_Country__c = 'USA',
            Vehicle_Owner_Name__c = 'Dashboard TestUser',
            Policy__c             = testPolicy.Id,
            Deleted_vehicle__c    = false,
            Company_Name__c       = 'Dashboard Test Co',
            Company_Address__c    = '123 Test St'
        );
        insert testVehicle;

        // Driver
        Driver__c testDriver = new Driver__c(
            Contact__c        = testContact.Id,
            First_Name__c     = 'Dashboard',
            Last_Name__c      = 'Driver',
            Email__c          = 'dashdriver@example.com',
            Driver_Type__c    = 'Owner',
            Phone__c          = '5551112222',
            Address__c        = '123 Test St',
            Address_Line_2__c = 'Suite 100',
            City__c           = 'San Diego',
            State_Province__c = 'California',
            Country__c        = 'USA',
            Postal_Code__c    = '92101',
            Default__c        = 'Yes',
            Deleted_Driver__c = false,
            Policy__c         = testPolicy.Id
        );
        insert testDriver;

        // Transaction
        Transaction__c testTransaction = new Transaction__c(
            Quote_c__c             = testQuote.Id,
            Policy_Transaction__c  = testPolicy.Id,
            Account_Transaction__c = testAccount.Id,
            Amount__c              = 450.00
        );
        insert testTransaction;
    }

    // ───────────────────────────────────────────────
    //  HELPER – run as community user
    // ───────────────────────────────────────────────

    private static User getTestUser() {
        return [SELECT Id FROM User WHERE Alias = 'DshTst' LIMIT 1];
    }

    // ───────────────────────────────────────────────
    //  POLICY TESTS
    // ───────────────────────────────────────────────

    @isTest
    static void testGetUserPolicies_AsLoggedInUser() {
        User testUser = getTestUser();

        System.runAs(testUser) {
            Test.startTest();
            List<Policy__c> policies = BuhoDashboardController.getUserPolicies();
            Test.stopTest();

            System.assertNotEquals(null, policies, 'Policies list should not be null');
            System.assertEquals(1, policies.size(), 'Should return one policy');
            System.assertEquals('Active', policies[0].Status_picklist__c, 'Policy status should be Active');
        }
    }

    @isTest
    static void testGetUserPolicies_AsGuestUser() {
        // Running as default test context (system admin) – contactId will be null
        Test.startTest();
        List<Policy__c> policies = BuhoDashboardController.getUserPolicies();
        Test.stopTest();

        System.assertNotEquals(null, policies, 'Policies list should not be null');
        System.assertEquals(0, policies.size(), 'Guest user should get empty policy list');
    }

    @isTest
    static void testGetPolicyById_ValidId() {
        Policy__c existingPolicy = [SELECT Id FROM Policy__c LIMIT 1];

        Test.startTest();
        Policy__c result = BuhoDashboardController.getPolicyById(existingPolicy.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Policy should be returned');
        System.assertEquals(existingPolicy.Id, result.Id, 'Returned policy Id should match');
        System.assertNotEquals(null, result.Status_picklist__c, 'Status should be queried');
        System.assertNotEquals(null, result.Policy_Type_picklist__c, 'Policy type should be queried');
    }

    @isTest
    static void testGetPolicyById_NullId() {
        Test.startTest();
        Policy__c result = BuhoDashboardController.getPolicyById(null);
        Test.stopTest();

        System.assertEquals(null, result, 'Null Id should return null');
    }

    // ───────────────────────────────────────────────
    //  VEHICLE TESTS
    // ───────────────────────────────────────────────

    @isTest
    static void testGetUserVehicles_AsLoggedInUser() {
        User testUser = getTestUser();

        System.runAs(testUser) {
            Test.startTest();
            List<Vehicle__c> vehicles = BuhoDashboardController.getUserVehicles();
            Test.stopTest();

            System.assertNotEquals(null, vehicles, 'Vehicles list should not be null');
            System.assertEquals(1, vehicles.size(), 'Should return one vehicle');
            System.assertEquals('Toyota', vehicles[0].Make__c, 'Vehicle make should be Toyota');
        }
    }

    @isTest
    static void testGetUserVehicles_AsGuestUser() {
        Test.startTest();
        List<Vehicle__c> vehicles = BuhoDashboardController.getUserVehicles();
        Test.stopTest();

        System.assertNotEquals(null, vehicles, 'Vehicles list should not be null');
        System.assertEquals(0, vehicles.size(), 'Guest user should get empty vehicle list');
    }

    @isTest
    static void testGetVehicleById_ValidId() {
        Vehicle__c existingVehicle = [SELECT Id FROM Vehicle__c LIMIT 1];

        Test.startTest();
        Vehicle__c result = BuhoDashboardController.getVehicleById(existingVehicle.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Vehicle should be returned');
        System.assertEquals(existingVehicle.Id, result.Id, 'Returned vehicle Id should match');
        System.assertEquals('Toyota', result.Make__c, 'Make should be Toyota');
        System.assertEquals('Camry', result.Model__c, 'Model should be Camry');
        System.assertEquals('2022', result.Year__c, 'Year should be 2022');
    }

    @isTest
    static void testGetVehicleById_NullId() {
        Test.startTest();
        Vehicle__c result = BuhoDashboardController.getVehicleById(null);
        Test.stopTest();

        System.assertEquals(null, result, 'Null Id should return null');
    }

    @isTest
    static void testSaveVehicle_Insert() {
        User testUser = getTestUser();

        System.runAs(testUser) {
            Vehicle__c newVehicle = new Vehicle__c(
                Year__c  = '2024',
                Make__c  = 'Honda',
                Model__c = 'Civic',
                Type__c  = 'Car',
                Value__c = 28000,
                Vin__c   = 'HND98765432101234'
            );

            Test.startTest();
            Id vehicleId = BuhoDashboardController.saveVehicle(newVehicle);
            Test.stopTest();

            System.assertNotEquals(null, vehicleId, 'Vehicle Id should not be null after insert');

            Vehicle__c saved = [SELECT Id, Make__c, Contact__c FROM Vehicle__c WHERE Id = :vehicleId];
            System.assertEquals('Honda', saved.Make__c, 'Make should be Honda');
            System.assertNotEquals(null, saved.Contact__c, 'Contact should be auto-stamped');
        }
    }

    @isTest
    static void testSaveVehicle_Update() {
        User testUser = getTestUser();
        Vehicle__c existingVehicle = [SELECT Id, Value__c FROM Vehicle__c LIMIT 1];

        System.runAs(testUser) {
            existingVehicle.Value__c = 30000;

            Test.startTest();
            Id vehicleId = BuhoDashboardController.saveVehicle(existingVehicle);
            Test.stopTest();

            System.assertEquals(existingVehicle.Id, vehicleId, 'Vehicle Id should match on update');

            Vehicle__c updated = [SELECT Value__c FROM Vehicle__c WHERE Id = :vehicleId];
            System.assertEquals(30000, updated.Value__c, 'Value should be updated to 30000');
        }
    }

    @isTest
    static void testRemoveVehicle_ValidId() {
        Vehicle__c existingVehicle = [SELECT Id FROM Vehicle__c LIMIT 1];

        Test.startTest();
        BuhoDashboardController.removeVehicle(existingVehicle.Id);
        Test.stopTest();

        Vehicle__c deleted = [SELECT Deleted_vehicle__c FROM Vehicle__c WHERE Id = :existingVehicle.Id];
        System.assertEquals(true, deleted.Deleted_vehicle__c, 'Vehicle should be soft-deleted');
    }

    @isTest
    static void testRemoveVehicle_NullId() {
        Test.startTest();
        BuhoDashboardController.removeVehicle(null);
        Test.stopTest();

        // No exception should be thrown; vehicle count unchanged
        Integer count = [SELECT COUNT() FROM Vehicle__c WHERE Deleted_vehicle__c = false];
        System.assertEquals(1, count, 'Vehicle count should remain unchanged');
    }

    // ───────────────────────────────────────────────
    //  DRIVER TESTS
    // ───────────────────────────────────────────────

    @isTest
    static void testGetUserDrivers_AsLoggedInUser() {
        User testUser = getTestUser();

        System.runAs(testUser) {
            Test.startTest();
            List<Driver__c> drivers = BuhoDashboardController.getUserDrivers();
            Test.stopTest();

            System.assertNotEquals(null, drivers, 'Drivers list should not be null');
            System.assertEquals(1, drivers.size(), 'Should return one driver');
            System.assertEquals('Dashboard', drivers[0].First_Name__c, 'First name should match');
        }
    }

    @isTest
    static void testGetUserDrivers_AsGuestUser() {
        Test.startTest();
        List<Driver__c> drivers = BuhoDashboardController.getUserDrivers();
        Test.stopTest();

        System.assertNotEquals(null, drivers, 'Drivers list should not be null');
        System.assertEquals(0, drivers.size(), 'Guest user should get empty driver list');
    }

    @isTest
    static void testGetDriverById_ValidId() {
        Driver__c existingDriver = [SELECT Id FROM Driver__c LIMIT 1];

        Test.startTest();
        Driver__c result = BuhoDashboardController.getDriverById(existingDriver.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Driver should be returned');
        System.assertEquals(existingDriver.Id, result.Id, 'Returned driver Id should match');
        System.assertEquals('Dashboard', result.First_Name__c, 'First name should be Dashboard');
        System.assertEquals('Driver', result.Last_Name__c, 'Last name should be Driver');
    }

    @isTest
    static void testGetDriverById_NullId() {
        Test.startTest();
        Driver__c result = BuhoDashboardController.getDriverById(null);
        Test.stopTest();

        System.assertEquals(null, result, 'Null Id should return null');
    }

    // ───────────────────────────────────────────────
    //  QUOTE TESTS
    // ───────────────────────────────────────────────

    @isTest
    static void testGetUserQuotes_AsLoggedInUser() {
        User testUser = getTestUser();

        System.runAs(testUser) {
            Test.startTest();
            List<Quote__c> quotes = BuhoDashboardController.getUserQuotes();
            Test.stopTest();

          
        }
    }

    @isTest
    static void testGetUserQuotes_AsGuestUser() {
        Test.startTest();
        List<Quote__c> quotes = BuhoDashboardController.getUserQuotes();
        Test.stopTest();

        System.assertNotEquals(null, quotes, 'Quotes list should not be null');
        System.assertEquals(0, quotes.size(), 'Guest user should get empty quote list');
    }

    @isTest
    static void testGetQuoteById_ValidId() {
        Quote__c existingQuote = [SELECT Id FROM Quote__c LIMIT 1];

        Test.startTest();
        Quote__c result = BuhoDashboardController.getQuoteById(existingQuote.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Quote should be returned');
        System.assertEquals(existingQuote.Id, result.Id, 'Returned quote Id should match');
        System.assertEquals('Chubb', result.Underwriter__c, 'Underwriter should be Chubb');
        System.assertEquals('Complete', result.Coverage__c, 'Coverage should be Complete');
    }

    @isTest
    static void testGetQuoteById_NullId() {
        Test.startTest();
        Quote__c result = BuhoDashboardController.getQuoteById(null);
        Test.stopTest();

        System.assertEquals(null, result, 'Null Id should return null');
    }

    // ───────────────────────────────────────────────
    //  TRANSACTION TESTS
    // ───────────────────────────────────────────────

    @isTest
    static void testGetUserTransactions_AsLoggedInUser() {
        User testUser = getTestUser();

        System.runAs(testUser) {
            Test.startTest();
            List<Transaction__c> transactions = BuhoDashboardController.getUserTransactions();
            Test.stopTest();

            System.assertNotEquals(null, transactions, 'Transactions list should not be null');
            System.assertEquals(1, transactions.size(), 'Should return one transaction');
            System.assertEquals(450.00, transactions[0].Amount__c, 'Amount should be 450.00');
        }
    }

    @isTest
    static void testGetUserTransactions_AsGuestUser() {
        Test.startTest();
        List<Transaction__c> transactions = BuhoDashboardController.getUserTransactions();
        Test.stopTest();

        System.assertNotEquals(null, transactions, 'Transactions list should not be null');
        System.assertEquals(0, transactions.size(), 'Guest user should get empty transaction list');
    }

    // ───────────────────────────────────────────────
    //  USER HELPER TESTS
    // ───────────────────────────────────────────────

    @isTest
    static void testGetUserName_AsLoggedInUser() {
        User testUser = getTestUser();

        System.runAs(testUser) {
            Test.startTest();
            String userName = BuhoDashboardController.getUserName();
            Test.stopTest();
        }
    }

    @isTest
    static void testGetUserName_AsDefaultUser() {
        Test.startTest();
        String userName = BuhoDashboardController.getUserName();
        Test.stopTest();

        System.assertNotEquals(null, userName, 'User name should not be null even for default context');
    }

    // ───────────────────────────────────────────────
    //  EDGE CASES & BULK
    // ───────────────────────────────────────────────

    @isTest
    static void testGetUserPolicies_MultiplePolicies() {
        User testUser = getTestUser();
        Contact testContact = [SELECT Id FROM Contact WHERE Email = 'dashboardtest@example.com' LIMIT 1];
        Quote__c testQuote   = [SELECT Id FROM Quote__c LIMIT 1];

        // Create a second policy
        Policy__c secondPolicy = new Policy__c(
            Name                    = 'TestPolicy-002',
            Contact__c              = testContact.Id,
            Quote_c__c              = testQuote.Id,
            Policy_Type_picklist__c = 'Automobile',
            Status_picklist__c      = 'Expired',
            Start_Date__c           = System.today().addDays(-60),
            End_Date__c             = System.today().addDays(-30),
            Term__c                 = 'Daily',
            Package__c              = 'Liability'
        );
        insert secondPolicy;

        System.runAs(testUser) {
            Test.startTest();
            List<Policy__c> policies = BuhoDashboardController.getUserPolicies();
            Test.stopTest();

            System.assertEquals(2, policies.size(), 'Should return two policies');
        }
    }

    @isTest
    static void testGetUserVehicles_ExcludesDeletedVehicles() {
        User testUser = getTestUser();
        Contact testContact = [SELECT Id FROM Contact WHERE Email = 'dashboardtest@example.com' LIMIT 1];
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Dashboard Account' LIMIT 1];

        // Create a deleted vehicle – should NOT appear in results
        Vehicle__c deletedVehicle = new Vehicle__c(
            Contact__c         = testContact.Id,
            Account_Vehicle__c = testAccount.Id,
            Year__c            = '2018',
            Make__c            = 'Nissan',
            Model__c           = 'Altima',
            Type__c            = 'Car',
            Deleted_vehicle__c = true
        );
        insert deletedVehicle;

        System.runAs(testUser) {
            Test.startTest();
            List<Vehicle__c> vehicles = BuhoDashboardController.getUserVehicles();
            Test.stopTest();

            System.assertEquals(1, vehicles.size(), 'Should only return non-deleted vehicles');
            System.assertEquals('Toyota', vehicles[0].Make__c, 'Non-deleted vehicle should be Toyota');
        }
    }

    

    @isTest
    static void testGetPolicyById_AllFieldsQueried() {
        Policy__c existingPolicy = [SELECT Id FROM Policy__c LIMIT 1];

        Test.startTest();
        Policy__c result = BuhoDashboardController.getPolicyById(existingPolicy.Id);
        Test.stopTest();

        // Verify key detail fields are returned by the query
        System.assertNotEquals(null, result.Name, 'Name should be queried');
        System.assertNotEquals(null, result.Start_Date__c, 'Start date should be queried');
        System.assertNotEquals(null, result.End_Date__c, 'End date should be queried');
        System.assertNotEquals(null, result.Package__c, 'Package should be queried');
        System.assertNotEquals(null, result.Net_Premium__c, 'Net premium should be queried');
        System.assertNotEquals(null, result.Broker_Policy_Fee__c, 'Broker policy fee should be queried');
        System.assertNotEquals(null, result.I_V_A_Mex_Tax__c, 'IVA Mex tax should be queried');
        System.assertNotEquals(null, result.Total_Premium_Amount__c, 'Total premium amount should be queried');
        System.assertNotEquals(null, result.Vehicle_type__c, 'Vehicle type should be queried');
        System.assertNotEquals(null, result.Territory_picklist__c, 'Territory should be queried');
    }
    
        // ───────────────────────────────────────────────
    //  USER PROFILE TESTS
    // ───────────────────────────────────────────────

    @isTest
    static void testGetUserProfile_AsLoggedInUser() {
        User testUser = getTestUser();

        System.runAs(testUser) {
            Test.startTest();
            User result = BuhoDashboardController.getUserProfile();
            Test.stopTest();

            System.assertNotEquals(null, result, 'Profile should not be null');
        }
    }

    @isTest
    static void testGetUserProfile_AsDefaultUser() {
        Test.startTest();
        User result = BuhoDashboardController.getUserProfile();
        Test.stopTest();

        // System admin user should still return a record
        System.assertNotEquals(null, result, 'Profile should not be null for default context');
    }

}