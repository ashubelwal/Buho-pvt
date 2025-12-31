@isTest
public class Mex_ValidateFormDataTest {
    @isTest static void validateFormDataTest() {
        JSONGenerator vehDetails = JSON.createGenerator(true);
        vehDetails.writeStartObject();
    		vehDetails.writeFieldName('Vehicle_details__c');
            vehDetails.writeStartObject();
            	vehDetails.writeStringField('Vehicle_Type__c', 'Automobile');
        		vehDetails.writeStringField('vehicle_sub_type__c', 'Car/Truck/Auto');
        		vehDetails.writeStringField('Year__c', '2019');
        		vehDetails.writeStringField('Make__c', 'Audi');
        		vehDetails.writeStringField('Model__c', 'RS7');
        		vehDetails.writeStringField('Value__c', '10000.00');
        		vehDetails.writeBooleanField('Is_there_a_driver_under_21__c', false);
        		vehDetails.writeBooleanField('Salvage_Vehicle__c', false);
        		vehDetails.writeBooleanField('Is_the_vehicle_used_for_business_purpose__c', false);
        		vehDetails.writeBooleanField('Is_this_a_Rental_Vehicle__c', false);
            vehDetails.writeEndObject();
        vehDetails.writeEndObject();


        JSONGenerator termOpt = JSON.createGenerator(true);
        termOpt.writeStartObject();
        	termOpt.writeFieldName('Term_options__c');
        	termOpt.writeStartObject();
        		termOpt.writeStringField('Start_Date_for_Coverage__c', '2022-09-09');
                termOpt.writeStringField('Start_Time__c', '00:00:00.000Z');
                termOpt.writeStringField('End_Date_for_Coverage__c', '2022-09-12');
                termOpt.writeStringField('End_Time__c', '00:00:00.000Z');
        		termOpt.writeStringField('term__c', 'Daily');
        	termOpt.writeEndObject();
        termOpt.writeEndObject();


        JSONGenerator towDetails = JSON.createGenerator(true);
        towDetails.writeStartObject();
        	towDetails.writeBooleanField('Is_Towing__c', true);
        	towDetails.writeFieldName('Towing__c');
                towDetails.writeStartArray();
        		towDetails.writeStartObject();
        			towDetails.writeStringField('Year__c', '2015');
        			towDetails.writeStringField('Make__c', 'tow make');
        			towDetails.writeStringField('Model__c', 'tow model');
        			towDetails.writeStringField('VIN_Number__c', 'DWAKUHDKAW');
        			towDetails.writeStringField('Plate__c', 'PLAWTWAJDAK');
        			towDetails.writeStringField('Towed_Unit_Value__c', '2000.00');
        			towDetails.writeStringField('Days_in_Tow__c', '2');
        			towDetails.writeStringField('Towed_Unit_Type__c', 'Motorcycle');
        			towDetails.writeStringField('Street_Legal__c', 'Yes');
        		towDetails.writeEndObject();
        		towDetails.writeEndArray();
        towDetails.writeEndObject();
        
        
        JSONGenerator quoteDetails = JSON.createGenerator(true);
        quoteDetails.writeStartObject();
        quoteDetails.writeFieldName('Quote_Details__c');
        quoteDetails.writeStartObject();
        	quoteDetails.writeStringField('Start_Date_for_Coverage__c', '2022-09-09');
        	quoteDetails.writeStringField('End_Date_for_Coverage__c', '2022-09-12');
        	quoteDetails.writeStringField('Start_Time__c', '00:00:00.000Z');
        	quoteDetails.writeStringField('End_Time__c', '00:00:00.000Z');
        	quoteDetails.writeStringField('termDays__c', '2');
        	quoteDetails.writeStringField('vehicleValue__c', '10000.00');
        	quoteDetails.writeStringField('liability__c', '300,000');
        	quoteDetails.writeStringField('medical__c', '$10,000/$50,000');
        	quoteDetails.writeStringField('coverageType__c', 'Complete');
        	quoteDetails.writeStringField('underwriter__c', 'Chubb');
        quoteDetails.writeEndObject();
        quoteDetails.writeEndObject();


        JSONGenerator reviewVeh = JSON.createGenerator(true);
        reviewVeh.writeStartObject();
        reviewVeh.writeFieldName('Review_vehicle__c');
        reviewVeh.writeStartObject();
        	reviewVeh.writeStringField('Year__c', '2019');
        	reviewVeh.writeStringField('Make__c', 'Audi');
        	reviewVeh.writeStringField('Model__c', 'RS7');
        	reviewVeh.writeStringField('Value__c', '10000.00');
        	reviewVeh.writeStringField('Vin__c', 'DWKWLJADWW');
        	reviewVeh.writeStringField('Registered_Country__c', 'United States');
        	reviewVeh.writeStringField('Registered_State__c', 'California');
        	reviewVeh.writeStringField('Registered_Plate__c', 'City');
        	reviewVeh.writeBooleanField('Is_the_vehicle_registered_to_a_business__c', false);
        	reviewVeh.writeBooleanField('Is_Lienholder__c', false);
        reviewVeh.writeEndObject();
        reviewVeh.writeEndObject();


        JSONGenerator cmpDetails = JSON.createGenerator(true);
        cmpDetails.writeStartObject();
        cmpDetails.writeFieldName('Company_details__c');
        cmpDetails.writeStartObject();
        	cmpDetails.writeStringField('Company_Name__c', 'XYZ');
            cmpDetails.writeStringField('Company_Phone__c', '0987654321');
            cmpDetails.writeStringField('Tax_ID__c', 'dwaq32q2');
            cmpDetails.writeStringField('Company_Country__c', 'United States');
            cmpDetails.writeStringField('Company_State__c', 'California');
        	cmpDetails.writeStringField('Company_City__c', 'City');
            cmpDetails.writeStringField('Company_Address__c', 'jlkdalj alknwad');
            cmpDetails.writeStringField('Company_Zip__c', '00810');
        cmpDetails.writeEndObject();
        cmpDetails.writeEndObject();


        JSONGenerator leinDetails = JSON.createGenerator(true);
        leinDetails.writeStartObject();
        leinDetails.writeFieldName('Lienholder_info__c');
        leinDetails.writeStartObject();
        	leinDetails.writeStringField('Lienholder_name__c', 'XYZ');
        	leinDetails.writeStringField('Lienholder_Phone__c', '0987654321');
        	leinDetails.writeStringField('Lienholder_Fax__c', '09876542321');
        	leinDetails.writeStringField('Lienholder_Street__c', 'jlkdalj alknwad');
        	leinDetails.writeStringField('Lienholder_Country__c', 'United States');
        	leinDetails.writeStringField('Lienholder_State__c', 'California');
        	leinDetails.writeStringField('Lienholder_City__c', 'City');
        	leinDetails.writeStringField('Lienholder_Postal_Code__c', '00810');
        leinDetails.writeEndObject();
        leinDetails.writeEndObject();


        JSONGenerator drvDetail = JSON.createGenerator(true);
        drvDetail.writeStartObject();
        drvDetail.writeFieldName('Driver_details__c');
            drvDetail.writeStartArray();
            drvDetail.writeStartObject();
        		drvDetail.writeStringField('First_Name__c', 'driver');
        		drvDetail.writeStringField('Last_Name__c', 'test');
        		drvDetail.writeStringField('Email__c', 'driver@test.com');
        		drvDetail.writeStringField('Phone__c', '09876542321');
        		drvDetail.writeStringField('Dob__c', '2000-09-12');
        		drvDetail.writeStringField('Driver_Type__c', 'Owner');
        		drvDetail.writeStringField('Primary_insured__c', 'Yes');
        		drvDetail.writeStringField('Address__c', 'address');
        		drvDetail.writeStringField('City__c', 'city');
        		drvDetail.writeStringField('Country__c', 'United States');
        		drvDetail.writeStringField('State_Province__c', 'California');
        		drvDetail.writeStringField('Postal_Code__c', '00810');
        		drvDetail.writeStringField('License_Country__c', 'United States');
        		drvDetail.writeStringField('License_State__c', 'California');
        		drvDetail.writeStringField('License_number__c', 'ADWkajijdoad');
            drvDetail.writeEndObject();
            drvDetail.writeEndArray();
        drvDetail.writeEndObject();

        
        JSONGenerator termAggr = JSON.createGenerator(true);
        termAggr.writeStartObject();
        termAggr.writeFieldName('Terms_Alert__c');
        termAggr.writeStartObject();
        	termAggr.writeStringField('What_is_your_trip_destination_in_US__c', 'Baja California');
        	termAggr.writeStringField('What_is_the_purpose_of_trip__c', 'Pleasure');
        	termAggr.writeStringField('How_did_you_hear_about_us__c', 'Facebook');
        	termAggr.writeStringField('Newsletter__c', 'No');
        	termAggr.writeStringField('Announcements__c', 'No');
        	termAggr.writeStringField('Travel_Alerts__c', 'No');
        	termAggr.writeBooleanField('Terms_of_Cancellation_Confirmed__c', true);
        	termAggr.writeBooleanField('Terms_of_Purchase_Confirmed__c', true);
        termAggr.writeEndObject();
        termAggr.writeEndObject();


        Test.startTest();
        Mex_ValidateFormData.validateFormData(vehDetails.getAsString(), 'vehicleDetails');
        Mex_ValidateFormData.validateFormData(termOpt.getAsString(), 'termOptions');
        Mex_ValidateFormData.validateFormData(towDetails.getAsString(), 'towDetails');
        Mex_ValidateFormData.validateFormData(quoteDetails.getAsString(), 'quoteDetails');
        Mex_ValidateFormData.validateFormData(reviewVeh.getAsString(), 'reviewVehicle');
        Mex_ValidateFormData.validateFormData(cmpDetails.getAsString(), 'companyInfo');
        Mex_ValidateFormData.validateFormData(leinDetails.getAsString(), 'lienholderDetails');
        Mex_ValidateFormData.validateFormData(drvDetail.getAsString(), 'driverDetails');
        Mex_ValidateFormData.validateFormData(termAggr.getAsString(), 'termsAndAgreement');
        Mex_ValidateFormData.PaymentWrapper pmwr = new Mex_ValidateFormData.PaymentWrapper();
        pmwr.Street = 'street';
        pmwr.Street_2 = 'street_2';
        pmwr.Country = 'Country';
        pmwr.State = 'State';
        pmwr.City = 'City';
        pmwr.Postal_Code = '00810';
        pmwr.cardName = 'testname';
        pmwr.expMonth = '2';
        pmwr.expYear = '2025';
        pmwr.securityCode = '123';
        Mex_ValidateFormData.validateFormData(null, null);
        Mex_ValidateFormData.validateFormData('dawdadadad', 'awdaw');
        Mex_ValidateFormData.getPicklistValues('Driver__c', 'Driver_Type__c');
        Mex_ValidateFormData.getDependentMap('Policy__c', 'Policy_Type_picklist__c', 'What_is_your_trip_destination_in_US__c');
        Test.stopTest();
    }
    
    @isTest static void validateFormDataTest2() {
        JSONGenerator vehDetails = JSON.createGenerator(true);
        vehDetails.writeStartObject();
    		vehDetails.writeFieldName('Vehicle_details__c');
            vehDetails.writeStartObject();
            	vehDetails.writeStringField('Vehicle_Type__c', '');
        		vehDetails.writeStringField('vehicle_sub_type__c', '');
        		vehDetails.writeStringField('Year__c', '');
        		vehDetails.writeStringField('Make__c', '');
        		vehDetails.writeStringField('Model__c', '');
        		vehDetails.writeStringField('Value__c', '');
        		vehDetails.writeBooleanField('Is_there_a_driver_under_21__c', true);
        		vehDetails.writeBooleanField('Salvage_Vehicle__c', true);
        		vehDetails.writeBooleanField('Is_the_vehicle_used_for_business_purpose__c', true);
        		vehDetails.writeBooleanField('Is_this_a_Rental_Vehicle__c', true);
            vehDetails.writeEndObject();
        vehDetails.writeEndObject();


        JSONGenerator termOpt = JSON.createGenerator(true);
        termOpt.writeStartObject();
        	termOpt.writeFieldName('Term_options__c');
        	termOpt.writeStartObject();
        		termOpt.writeStringField('Start_Date_for_Coverage__c', '');
                termOpt.writeStringField('Start_Time__c', '');
                termOpt.writeStringField('End_Date_for_Coverage__c', '');
                termOpt.writeStringField('End_Time__c', '00:00:00.000Z');
        		termOpt.writeStringField('term__c', '');
        	termOpt.writeEndObject();
        termOpt.writeEndObject();


        JSONGenerator towDetails = JSON.createGenerator(true);
        towDetails.writeStartObject();
        	towDetails.writeBooleanField('Is_Towing__c', true);
        	towDetails.writeFieldName('Towing__c');
                towDetails.writeStartArray();
        		towDetails.writeStartObject();
        			towDetails.writeStringField('Year__c', '');
        			towDetails.writeStringField('Make__c', '');
        			towDetails.writeStringField('Model__c', '');
        			towDetails.writeStringField('VIN_Number__c', '');
        			towDetails.writeStringField('Plate__c', '');
        			towDetails.writeStringField('Towed_Unit_Value__c', '');
        			towDetails.writeStringField('Days_in_Tow__c', '');
        			towDetails.writeStringField('Towed_Unit_Type__c', '');
        			towDetails.writeStringField('Street_Legal__c', '');
        		towDetails.writeEndObject();
        		towDetails.writeEndArray();
        towDetails.writeEndObject();
        
        
        JSONGenerator quoteDetails = JSON.createGenerator(true);
        quoteDetails.writeStartObject();
        quoteDetails.writeFieldName('Quote_Details__c');
        quoteDetails.writeStartObject();
        	quoteDetails.writeStringField('Start_Date_for_Coverage__c', '');
        	quoteDetails.writeStringField('End_Date_for_Coverage__c','');
        	quoteDetails.writeStringField('Start_Time__c', '');
        	quoteDetails.writeStringField('End_Time__c', '');
        	quoteDetails.writeStringField('termDays__c', '');
        	quoteDetails.writeStringField('vehicleValue__c', '');
        	quoteDetails.writeStringField('liability__c', '');
        	quoteDetails.writeStringField('medical__c', '');
        	quoteDetails.writeStringField('coverageType__c', '');
        	quoteDetails.writeStringField('underwriter__c', '');
        quoteDetails.writeEndObject();
        quoteDetails.writeEndObject();


        JSONGenerator reviewVeh = JSON.createGenerator(true);
        reviewVeh.writeStartObject();
        reviewVeh.writeFieldName('Review_vehicle__c');
        reviewVeh.writeStartObject();
        	reviewVeh.writeStringField('Year__c','');
        	reviewVeh.writeStringField('Make__c', '');
        	reviewVeh.writeStringField('Model__c', '');
        	reviewVeh.writeStringField('Value__c', '');
        	reviewVeh.writeStringField('Vin__c', '');
        	reviewVeh.writeStringField('Registered_Country__c', '');
        	reviewVeh.writeStringField('Registered_State__c', '');
        	reviewVeh.writeStringField('Registered_Plate__c', '');
        	reviewVeh.writeBooleanField('Is_the_vehicle_registered_to_a_business__c', true);
        	reviewVeh.writeBooleanField('Is_Lienholder__c', true);
        reviewVeh.writeEndObject();
        reviewVeh.writeEndObject();


        JSONGenerator cmpDetails = JSON.createGenerator(true);
        cmpDetails.writeStartObject();
        cmpDetails.writeFieldName('Company_details__c');
        cmpDetails.writeStartObject();
        	cmpDetails.writeStringField('Company_Name__c', '');
            cmpDetails.writeStringField('Company_Phone__c', '');
            cmpDetails.writeStringField('Tax_ID__c', '');
            cmpDetails.writeStringField('Company_Country__c','');
            cmpDetails.writeStringField('Company_State__c', '');
        	cmpDetails.writeStringField('Company_City__c', '');
            cmpDetails.writeStringField('Company_Address__c', '');
            cmpDetails.writeStringField('Company_Zip__c', '');
        cmpDetails.writeEndObject();
        cmpDetails.writeEndObject();


        JSONGenerator leinDetails = JSON.createGenerator(true);
        leinDetails.writeStartObject();
        leinDetails.writeFieldName('Lienholder_info__c');
        leinDetails.writeStartObject();
        	leinDetails.writeStringField('Lienholder_name__c', '');
        	leinDetails.writeStringField('Lienholder_Phone__c', '');
        	leinDetails.writeStringField('Lienholder_Fax__c', '');
        	leinDetails.writeStringField('Lienholder_Street__c', '');
        	leinDetails.writeStringField('Lienholder_Country__c', '');
        	leinDetails.writeStringField('Lienholder_State__c', '');
        	leinDetails.writeStringField('Lienholder_City__c', '');
        	leinDetails.writeStringField('Lienholder_Postal_Code__c', '');
        leinDetails.writeEndObject();
        leinDetails.writeEndObject();


        JSONGenerator drvDetail = JSON.createGenerator(true);
        drvDetail.writeStartObject();
        drvDetail.writeFieldName('Driver_details__c');
            drvDetail.writeStartArray();
            drvDetail.writeStartObject();
        		drvDetail.writeStringField('First_Name__c', '');
        		drvDetail.writeStringField('Last_Name__c', '');
        		drvDetail.writeStringField('Email__c', '');
        		drvDetail.writeStringField('Phone__c', '');
        		drvDetail.writeStringField('Dob__c', '');
        		drvDetail.writeStringField('Driver_Type__c', '');
        		drvDetail.writeStringField('Primary_insured__c', '');
        		drvDetail.writeStringField('Address__c', '');
        		drvDetail.writeStringField('City__c','');
        		drvDetail.writeStringField('Country__c', '');
        		drvDetail.writeStringField('State_Province__c', '');
        		drvDetail.writeStringField('Postal_Code__c', '');
        		drvDetail.writeStringField('License_Country__c', '');
        		drvDetail.writeStringField('License_State__c', '');
        		drvDetail.writeStringField('License_number__c', '');
            drvDetail.writeEndObject();
            drvDetail.writeEndArray();
        drvDetail.writeEndObject();

        
        JSONGenerator termAggr = JSON.createGenerator(true);
        termAggr.writeStartObject();
        termAggr.writeFieldName('Terms_Alert__c');
        termAggr.writeStartObject();
        	termAggr.writeBooleanField('Terms_of_Cancellation_Confirmed__c', true);
        	termAggr.writeBooleanField('Terms_of_Purchase_Confirmed__c', true);
        termAggr.writeEndObject();
        termAggr.writeEndObject();


        Test.startTest();
        Mex_ValidateFormData.validateFormData(vehDetails.getAsString(), 'vehicleDetails');
        Mex_ValidateFormData.validateFormData(termOpt.getAsString(), 'termOptions');
        Mex_ValidateFormData.validateFormData(towDetails.getAsString(), 'towDetails');
        Mex_ValidateFormData.validateFormData(quoteDetails.getAsString(), 'quoteDetails');
        Mex_ValidateFormData.validateFormData(reviewVeh.getAsString(), 'reviewVehicle');
        Mex_ValidateFormData.validateFormData(cmpDetails.getAsString(), 'companyInfo');
        Mex_ValidateFormData.validateFormData(leinDetails.getAsString(), 'lienholderDetails');
        Mex_ValidateFormData.validateFormData(drvDetail.getAsString(), 'driverDetails');
        Mex_ValidateFormData.validateFormData(termAggr.getAsString(), 'termsAndAgreement');
        Test.stopTest();
    }
}