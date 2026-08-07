@isTest
public class Mex_ShowSelectedQuotePdfTest {
    @isTest static void postiveMethod(){
        TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;
        
        Watercraft__c watercraftrecord = new Watercraft__c();
        watercraftrecord.year__c = '2010';
        insert watercraftrecord;
        List <Driver__c> drive = new List <Driver__c>();
        for(integer i=0; i<2; i++){
            Driver__c drivers = new Driver__c ();
            drivers.First_Name__c = 'test'+ i;
            drive.add(drivers);
        }
        insert drive;
        Account acc = new Account();
        acc.Name = 'testAccount';
        
        insert acc;
        
        Policy__c policyrecord=new policy__c();
        Time myTime = Time.newInstance(1, 2, 3, 4);
        Time expected = Time.newInstance(4, 2, 3, 4);
        policyrecord.name='policy';
        policyrecord.Account_Policy__c = acc.Id;
        policyrecord.Policy_Type_picklist__c = 'Watercraft';
        policyrecord.Start_Time__c =  myTime;
        policyrecord.End_Time__c =  expected;
        policyrecord.Watercraft__c = watercraftrecord.Id;
        policyRecord.Medical_picklist__c = '2,000/10,000';
        insert policyrecord;
        Quote__c quotes = new Quote__c ();
        date myDate = date.newInstance(1988, 12, 17);
        quotes.Date_of_Birth__c = myDate;
        quotes.Start_Time__c = myTime;
        quotes.End_Time__c = expected;
        quotes.Territory__c = 'Baja/Sonora';
        quotes.Coverage__c = 'Liability';
        quotes.Policy_Type_picklist__c = 'Watercraft';
        quotes.Underwriter__c = 'Chubb';
        quotes.QuotePdfJson__c = '{"Chubb":{"Liability (Damage You Cause)":{"Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Liability-Damage-You-Cause.png","Order":"1.0"},"Damage to Vehicle":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Collision-Damage-to-Vehicle.png","Order":"2.0"},"Damage to Towed Unit while Attached":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Theft-of-Towed-Units-While-Attached.png","Order":"3.0"},"Uninsured or Underinsured Damage to Vehicle":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Uninsured-or-Underinsured-Damage-to-Vehicle.png","Order":"4.0"},"Eligible to Repair in the U.S.":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Eligible-to-Repair-in-the-U.S.png","Order":"6.0"},"Vehicle Theft":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Vehicle-Theft.png","Order":"7.0"},"Theft of Towed Unit(s) While Attached":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Theft-of-Towed-Units-While-Attached.png","Order":"8.0"},"Partial Theft":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Partial-Theft.png","Order":"9.0"},"Gap Coverage":{"Title":"Not Included","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Towing.png","Order":"10.0"},"Medical for Occupants of Your Vehicle":{"Title":"Covered with 10000/50000","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Medical-Coverage-For-Occupants-of-your-Vehicle.png","Order":"11.0"},"Glass Coverage":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Glass-Coverage.png","Order":"12.0"},"Legal Assistance Coverage":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Legal-Assitance.png","Order":"13.0"},"Towing Benefit":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Towing-Benefit.png","Order":"14.0"},"Roadside Assistance":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Roadside-Assistance.png","Order":"15.0"},"Rental Car Benefit":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Rental-Car-Benefit.png","Order":"16.0"},"Vandalism Coverage":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Vandalism.png","Order":"16.0"},"Trip Interruption":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Trip-Interruption.png","Order":"17.0"},"Bail Bond Limit":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Untitled.png","Order":"18.0"},"Air Ambulance":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Air-Ambulance-1.png","Order":"19.0"}},"Mapfre":{"Liability (Damage You Cause)":{"Title":"Covered with 300000","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Liability-Damage-You-Cause.png","Order":"1.0"},"Damage to Vehicle":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Collision-Damage-to-Vehicle.png","Order":"2.0"},"Damage to Towed Unit while Attached":{"Title":"Not Included","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Theft-of-Towed-Units-While-Attached.png","Order":"3.0"},"Uninsured or Underinsured Damage to Vehicle":{"Title":"Not Included","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Uninsured-or-Underinsured-Damage-to-Vehicle.png","Order":"4.0"},"Eligible to Repair in the U.S.":{"Title":"Not Included","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Eligible-to-Repair-in-the-U.S.png","Order":"6.0"},"Vehicle Theft":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Vehicle-Theft.png","Order":"7.0"},"Theft of Towed Unit(s) While Attached":{"Title":"Not Included","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Theft-of-Towed-Units-While-Attached.png","Order":"8.0"},"Partial Theft":{"Title":"Not Included","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Partial-Theft.png","Order":"9.0"},"Gap Coverage":{"Title":"Not Included","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Towing.png","Order":"10.0"},"Medical for Occupants of Your Vehicle":{"Title":"Covered with 20000","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Medical-Coverage-For-Occupants-of-your-Vehicle.png","Order":"11.0"},"Glass Coverage":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Glass-Coverage.png","Order":"12.0"},"Legal Assistance Coverage":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Legal-Assitance.png","Order":"13.0"},"Towing Benefit":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Towing-Benefit.png","Order":"14.0"},"Roadside Assistance":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Roadside-Assistance.png","Order":"15.0"},"Rental Car Benefit":{"Title":"Not Included","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Rental-Car-Benefit.png","Order":"16.0"},"Vandalism Coverage":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Vandalism.png","Order":"16.0"},"Trip Interruption":{"Title":"Not Included","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Trip-Interruption.png","Order":"17.0"},"Bail Bond Limit":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Untitled.png","Order":"18.0"},"Air Ambulance":{"Title":"Not Included","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Air-Ambulance-1.png","Order":"19.0"}},"Qualitas":{"Liability (Damage You Cause)":{"Title":"Covered with 100000","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Liability-Damage-You-Cause.png","Order":"1.0"},"Damage to Vehicle":{"Title":"Not Included","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Collision-Damage-to-Vehicle.png","Order":"2.0"},"Damage to Towed Unit while Attached":{"Title":"Not Included","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Theft-of-Towed-Units-While-Attached.png","Order":"3.0"},"Uninsured or Underinsured Damage to Vehicle":{"Title":"Not Included","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Uninsured-or-Underinsured-Damage-to-Vehicle.png","Order":"4.0"},"Eligible to Repair in the U.S.":{"Title":"Not Included","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Eligible-to-Repair-in-the-U.S.png","Order":"6.0"},"Vehicle Theft":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Vehicle-Theft.png","Order":"7.0"},"Theft of Towed Unit(s) While Attached":{"Title":"Not Included","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Theft-of-Towed-Units-While-Attached.png","Order":"8.0"},"Partial Theft":{"Title":"Not Included","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Partial-Theft.png","Order":"9.0"},"Gap Coverage":{"Title":"Not Included","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Towing.png","Order":"10.0"},"Medical for Occupants of Your Vehicle":{"Title":"Covered with 5000","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Medical-Coverage-For-Occupants-of-your-Vehicle.png","Order":"11.0"},"Glass Coverage":{"Title":"Not Included","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Glass-Coverage.png","Order":"12.0"},"Legal Assistance Coverage":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Legal-Assitance.png","Order":"13.0"},"Towing Benefit":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Towing-Benefit.png","Order":"14.0"},"Roadside Assistance":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Roadside-Assistance.png","Order":"15.0"},"Rental Car Benefit":{"Title":"Not Included","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Rental-Car-Benefit.png","Order":"16.0"},"Vandalism Coverage":{"Title":"Not Included","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Vandalism.png","Order":"16.0"},"Trip Interruption":{"Title":"Not Included","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Trip-Interruption.png","Order":"17.0"},"Bail Bond Limit":{"Title":"Covered","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Untitled.png","Order":"18.0"},"Air Ambulance":{"Title":"Not Included","Description":"description is here","Image":"https://www.mexinsurance.com/wp-content/uploads/2025/06/Air-Ambulance-1.png","Order":"19.0"}}}';
        
        insert quotes;
        
        List<Coverage_Detail__c> coverageList = new List<Coverage_Detail__c>();
        for(integer i = 0; i < 3; i++){
            Coverage_Detail__c CoverageDetails = new Coverage_Detail__c();
            CoverageDetails.Policy_Type__c = 'Watercraft';
            CoverageDetails.Package__c = 'Liability';
            if(i == 0){
                CoverageDetails.Underwriter__c = 'Qualitas';
            }else if(i == 1){
                CoverageDetails.Underwriter__c = 'Chubb';
            }else if(i == 2){
                CoverageDetails.Underwriter__c = 'Mapfre';
            }
            CoverageDetails.Territory_Discount__c = 'Yes';
            coverageList.add(CoverageDetails);
        }
        
        insert coverageList;
        
        
        
        Test.startTest();
        
        PageReference pgRef = Page.selectedQuoteNewRate; 
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('Id', quotes.Id);
        // System.currentPageReference().getParameters().put('params', 'CRLAL-22-DXQL4');
        Mex_ShowSelectedQuotePdf controller = new Mex_ShowSelectedQuotePdf() ; 
        test.stopTest();   
    }
    @isTest static void testmethodSecond(){
         Test.startTest();

        /*Mex_ShowSelectedQuotePdf.qualitasQuotes qualitasRateTable = new Mex_ShowSelectedQuotePdf.qualitasQuotes();
        qualitasRateTable.collision_deductible = '344';
        qualitasRateTable.days = '7';
        qualitasRateTable.iva = 90.00;
        qualitasRateTable.net_premium = 908.00;
        qualitasRateTable.Policy_Fee = 30.00;
        qualitasRateTable.rateValue = 98.98;
        qualitasRateTable.showQualitas = true;
        qualitasRateTable.surcharge = 56.52;
        qualitasRateTable.Term_Tempc = 'Daily';
        qualitasRateTable.theft_Total = '89';
        
        Mex_ShowSelectedQuotePdf.mapfreQuotes mapfreRateTable = new Mex_ShowSelectedQuotePdf.mapfreQuotes();
        mapfreRateTable.collision_deductible = '344';
        mapfreRateTable.days = '7';
        mapfreRateTable.iva = 90.00;
        mapfreRateTable.net_premium = 908.00;
        mapfreRateTable.Policy_Fee = 30.00;
        mapfreRateTable.rateValue = 98.98;
        mapfreRateTable.showMapfre = true;
        mapfreRateTable.Term_Tempc = 'Daily';
        mapfreRateTable.theft_Total = '89';
       
        
        Mex_ShowSelectedQuotePdf.chubbQuotes chubbRateTable = new Mex_ShowSelectedQuotePdf.chubbQuotes();
        chubbRateTable.collision_deductible = '344';
        chubbRateTable.days = '7';
        chubbRateTable.iva = 90.00;
        chubbRateTable.net_premium = 908.00;
        chubbRateTable.Policy_Fee = 30.00;
        chubbRateTable.rateValue = 98.98;
        chubbRateTable.showChubb = true;
        chubbRateTable.surcharge = 56.52;
        chubbRateTable.Term_Tempc = 'Daily';
        chubbRateTable.theft_Total = '89';
        chubbRateTable.LiabilityPayment = 89.00;
        chubbRateTable.medicalPayment = 1000.00;
        chubbRateTable.physicalDamagePayment = 45.20;
        chubbRateTable.platinumEndorsementPayment = 65.30;
        chubbRateTable.totalTheftPayment = 78.30;
        
        Mex_ShowSelectedQuotePdf.quotePdfJsonWrapper ratetables = new Mex_ShowSelectedQuotePdf.quotePdfJsonWrapper();
        ratetables.chubbQuote = chubbRateTable;
        ratetables.Chubb = true;
        ratetables.Mapfre = true;
        ratetables.mapfreQuote = mapfreRateTable;
         ratetables.Qualitas = true;
        ratetables.qualitasQuote = qualitasRateTable;*/
        //PageReference pdfpage = Page.selectedQuoteNewRate;
           // pdfPage.getParameters().put('Id',quoteId);
        
        
        test.stopTest(); 
    }
    @isTest static void testAffiliateFlow() {
        TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;

        // Create an Affiliate record with a known ID
        Affiliate__c affiliate = new Affiliate__c();
        affiliate.Affiliate_Id__c = 'AFF-TEST-001';
        affiliate.Owner_Name__c = 'Test Owner';
        affiliate.Agent_Fee__c = 10;
        affiliate.Agency_Logo__c = 'https://example.com/logo.png';
        insert affiliate;

        // Create a Quote to pass as the 'Id' parameter
        Quote__c quotes = new Quote__c();
        Time myTime = Time.newInstance(1, 2, 3, 4);
        quotes.Start_Time__c = myTime;
        quotes.End_Time__c = myTime;
        quotes.Territory__c = 'Baja/Sonora';
        quotes.Coverage__c = 'Liability';
        quotes.Policy_Type_picklist__c = 'Watercraft';
        quotes.Underwriter__c = 'Chubb';
        insert quotes;

        Test.startTest();

        PageReference pgRef = Page.selectedQuoteNewRate;
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('Id', quotes.Id);
        ApexPages.currentPage().getParameters().put('affiliateCode', 'AFF-TEST-001');

        Mex_ShowSelectedQuotePdf controller = new Mex_ShowSelectedQuotePdf();

        // Assert affiliate path was taken
        System.assertEquals(true, controller.isAffiliate, 'isAffiliate should be true when a matching affiliate code is passed');
        System.assertNotEquals(null, controller.affiliateRecord, 'affiliateRecord should be populated');
        System.assertEquals('AFF-TEST-001', controller.affiliateRecord.Affiliate_Id__c);

        Test.stopTest();
    }

    @isTest static void testNoAffiliateCode() {
        TriggerSwitch__c customsetting = new TriggerSwitch__c();
        customsetting.Name = 'PolicyTrigger';
        customsetting.Active__c = false;
        insert customsetting;

        Quote__c quotes = new Quote__c();
        Time myTime = Time.newInstance(1, 2, 3, 4);
        quotes.Start_Time__c = myTime;
        quotes.End_Time__c = myTime;
        quotes.Territory__c = 'Baja/Sonora';
        quotes.Coverage__c = 'Complete';
        quotes.Policy_Type_picklist__c = 'Watercraft';
        quotes.Underwriter__c = 'Mapfre';
        insert quotes;

        Test.startTest();

        PageReference pgRef = Page.selectedQuoteNewRate;
        Test.setCurrentPage(pgRef);
        ApexPages.currentPage().getParameters().put('Id', quotes.Id);
        // No affiliateCode parameter — isAffiliate should remain false

        Mex_ShowSelectedQuotePdf controller = new Mex_ShowSelectedQuotePdf();

        System.assertEquals(false, controller.isAffiliate, 'isAffiliate should be false when no affiliateCode is passed');

        Test.stopTest();
    }
}