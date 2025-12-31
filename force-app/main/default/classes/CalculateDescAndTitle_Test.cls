@isTest
public class CalculateDescAndTitle_Test {
    
    @testSetup
    static void setupData() {
        // Insert Vendor data
               Vendor__c testVendor = new Vendor__c(
            Name = 'Qualitas',
            Max_Term_30__c = null,
            Max_Term_90__c = null,
            Max_Term_Daily__c = '({PartialTheft}+{AirplaneTickets}+{RentalCar}-( Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01))',
            Max_Term_365__c = null,
            Max_Term_180__c = null,
            Max_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c","Coverage__c"],     "termOption": ["Term__c","Max__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Is_Max__c = true,
            Is_Gold__c = true,
            Is_Platinum__c = true,
            Net_First_Term_365__c = '(({PropertyDamage}+{TowedPropertyDamage}+{TotalTheft}+{TowedTotalTheft}+{Liability}+{Medical}+{RoadsideTravel}+{Legal}))',
            Net_First_Term_30__c = '(({PropertyDamage}+{TowedPropertyDamage}+{TotalTheft}+{TowedTotalTheft}+{Liability}+{Medical}+{RoadsideTravel}+{Legal}))',
            Net_First_Term_180__c = '(({PropertyDamage}+{TowedPropertyDamage}+{TotalTheft}+{TowedTotalTheft}+{Liability}+{Medical}+{RoadsideTravel}+{Legal}))',
            Net_First_Term_90__c = '(({PropertyDamage}+{TowedPropertyDamage}+{TotalTheft}+{TowedTotalTheft}+{Liability}+{Medical}+{RoadsideTravel}+{Legal}))',
            Medical_Vehicle_Eligiblity__c = '{"vehicleList":["Motorcycle","ATV-UTV-Quads-Buggie"]}',
            Towed_Total_Theft_Term_365__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Towed_Unit_Value__c}]) * {Days_in_Tow__c})',
            Towed_Total_Theft_Term_180__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Towed_Unit_Value__c}]) * {Days_in_Tow__c})',
            Is_Age_Included_In_Towed_Property_Damage__c = false,
            Property_Damage_Vehicle_Age_Restriction__c = '100',
            Is_Age_Included_In_Property_Damage__c = false,
            Total_Fields__c = '{     "vehicleDetails": ["Value__c", "Vehicle_sub_type__c", "Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Total_Term_365__c = '({NetFourth}+{IVA}+{AgentFee}+{BrokerFee})',
            Total_Term_30__c = '({NetFourth}+{IVA}+{AgentFee}+{BrokerFee})',
            Total_Term_Daily__c = '({NetFourth}+{IVA}+{AgentFee}+{BrokerFee}-( Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01))',
            Total_Term_180__c = '({NetFourth}+{IVA}+{AgentFee}+{BrokerFee})',
            Total_Term_90__c = '({NetFourth}+{IVA}+{AgentFee}+{BrokerFee})',
            Agent_Fee_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Agent_Fee_Term_Daily__c = '0*({Liability} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01)',
            Agent_Fee_Term_90__c = '0',
            Agent_Fee_Term_365__c = '0',
            Agent_Fee_Term_180__c = '0',
            Agent_Fee_Term_30__c = '0*({Liability} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01)',
            Broker_Fee_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Broker_Fee_Term_Daily__c = '-15-( Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01)',
            Broker_Fee_Term_30__c = '-17',
            Broker_Fee_Term_180__c = '-25',
            Broker_Fee_Term_90__c = '-20',
            Broker_Fee_Term_365__c = '-35',
            IVA_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            IVA_Term_90__c = '({NetFourth}*0.16)',
            IVA_Term_365__c = '({NetFourth}*0.16)',
            IVA_Term_180__c = '({NetFourth}*0.16)',
            IVA_Term_30__c = '({NetFourth}*0.16)',
            IVA_Term_Daily__c = '({NetFourth}*0.16-( Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01))',
            Net_Fourth_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c","Model"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"], "territory":["Territory__c"] }',
            Net_Fourth_Term_90__c = '({NetThird}-{TerritoryDiscount}-{OtherDiscount})',
            Net_Fourth_Term_30__c = '({NetThird}-{TerritoryDiscount}-{OtherDiscount})',
            Net_Fourth_Term_365__c = '({NetThird}-{TerritoryDiscount}-{OtherDiscount})',
            Net_Fourth_Term_Daily__c = '({NetThird}-{TerritoryDiscount}-{OtherDiscount}+( Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01))',
            Net_Fourth_Term_180__c = '({NetThird}-{TerritoryDiscount}-{OtherDiscount})',
            Other_Discount_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c","Model"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"], "territory":["Territory__c"] }',
            Other_Discount_Term_30__c = '0',
            Other_Discount_Term_Daily__c = '0*({Liability} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01)',
            Other_Discount_Term_90__c = '0',
            Other_Discount_Term_365__c = '0',
            Other_Discount_Term_180__c = '0',
            Territory_Discount_Fields__c = '{     "vehicleDetails": ["Value__c","Year__c", "isTowing","Liability__c","Vehicle_sub_type__c", "Coverage__c","Model"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"], "territory":["region"] }',
            Territory_Discount_Term_180__c = '((Query([Term_180__c],Territory_Discount__c, [Territory__c= \'{Territory__c}\'])*0.01)*{NetFirst})',
            Territory_Discount_Term_90__c = '((Query([Term_90__c],Territory_Discount__c, [Territory__c= \'{Territory__c}\'])*0.01)*{NetFirst})',
            Territory_Discount_Term_Daily__c = '((Query([Term_Daily__c],Territory_Discount__c, [Territory__c= \'{Territory__c}\'])*0.01)*{NetFirst})',
            Territory_Discount_Term_365__c = '((Query([Term_365__c],Territory_Discount__c, [Territory__c= \'{Territory__c}\'])*0.01)*{NetFirst})',
            Territory_Discount_Term_30__c = '((Query([Term_30__c],Territory_Discount__c, [Territory__c= \'{Territory__c}\'])*0.01)*{NetFirst})',
            Territory_Discount_Vehicle_Eligibility__c = '{"vehicleList":["Silverado 3500","Silverado 2500","Silverado 1500","Silverado","Wrangler"]}',
            Net_Third_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Net_Third_Term_Daily__c = '({TotalSurcharges}+{NetSecond}-( Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01))',
            Net_Third_Term_180__c = '({TotalSurcharges}+{NetSecond})',
            Net_Third_Term_90__c = '({TotalSurcharges}+{NetSecond})',
            Net_Third_Term_365__c = '({TotalSurcharges}+{NetSecond})',
            Net_Third_Term_30__c = '({TotalSurcharges}+{NetSecond})',
            Total_Surcharges_Fields__c = '{     "vehicleDetails": ["Value__c", "Vehicle_sub_type__c", "Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Total_Surcharges_Term_365__c = '({SurchargeBusiness}+{SurchargeElectricHybrid}+{SurchargeAge}+{SurchargeHighRisk}+{SurchargeRental}+{SurchargeVehicleTypes})',
            Total_Surcharges_Term_90__c = '({SurchargeBusiness}+{SurchargeElectricHybrid}+{SurchargeAge}+{SurchargeHighRisk}+{SurchargeRental}+{SurchargeVehicleTypes})',
            Total_Surcharges_Term_180__c = '({SurchargeBusiness}+{SurchargeElectricHybrid}+{SurchargeAge}+{SurchargeHighRisk}+{SurchargeRental}+{SurchargeVehicleTypes})',
            Total_Surcharges_Term_Daily__c = '({SurchargeBusiness}+{SurchargeElectricHybrid}+{SurchargeAge}+{SurchargeHighRisk}+{SurchargeRental}+{SurchargeVehicleTypes}-( Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01))',
            Total_Surcharges_Term_30__c = '({SurchargeBusiness}+{SurchargeElectricHybrid}+{SurchargeAge}+{SurchargeHighRisk}+{SurchargeRental}+{SurchargeVehicleTypes})',
            Surcharge_Business_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c","is_the_vehicle_used_for_business_purpose__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Surcharge_Business_Term_30__c = '({NetFirst}*0.2)',
            Surcharge_Business_Term_Daily__c = '({NetFirst}*0.2-( Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01))',
            Surcharge_Business_Term_90__c = '({NetFirst}*0.2)',
            Surcharge_Business_Term_365__c = '({NetFirst}*0.2)',
            Surcharge_Business_Term_180__c = '({NetFirst}*0.2)',
            Surcharge_Electric_Hybrid_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c","Electric_Hybrid__c","Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Surcharge_Electric_Hybrid_Term_365__c = '({NetFirst}*0.2)',
            Surcharge_Electric_Hybrid_Term_180__c = '({NetFirst}*0.2)',
            Surcharge_Electric_Hybrid_Term_30__c = '({NetFirst}*0.2)',
            Surcharge_Electric_Hybrid_Term_90__c = '({NetFirst}*0.2)',
            Surcharge_Electric_Hybrid_Term_Daily__c = '({NetFirst}*0.20*({Liability} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01))',
            Surcharge_Age_Term_90__c = '({NetFirst}*0.2)',
            Surcharge_Age_Term_365__c = '({NetFirst}*0.2)',
            Surcharge_Age_Term_30__c = '({NetFirst}*0.2)',
            Platinum_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c","Year__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"],"territory":["region"]  }',
            Gold_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c","Coverage__c"],     "termOption": ["Term__c","Gold__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Net_Second_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Net_First_Term_Daily__c = '(({PropertyDamage}+{TowedPropertyDamage}+{TotalTheft}+{TowedTotalTheft}+{Liability}+{Medical}+{RoadsideTravel}+{Legal})-( Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01))',
            Surcharge_Age_Term_Daily__c = '({NetFirst}*0.2-(Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01))',
            Surcharge_Age_Term_180__c = '({NetFirst}*0.2)',
            Surcharge_Age_Fields__c = '{     "vehicleDetails": ["Value__c","is_there_a_driver_under_21__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Surcharge_High_Risk_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Surcharge_High_Risk_Term_180__c = '0',
            Surcharge_High_Risk_Term_365__c = '0',
            Surcharge_High_Risk_Term_Daily__c = '0*({Liability} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01)',
            Surcharge_High_Risk_Term_90__c = '0',
            Surcharge_High_Risk_Term_30__c = '0',
            Surcharge_Rental_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c","Rental__c","Is_this_a_Rental_Vehicle__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Surcharge_Rental_Term_180__c = '({NetFirst}*0.2)',
            Surcharge_Rental_Term_365__c = '({NetFirst}*0.2)',
            Surcharge_Rental_Term_Daily__c = '({NetFirst}*0.2 - ( Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01))',
            Surcharge_Rental_Term_30__c = '({NetFirst}*0.2)',
            Surcharge_Rental_Term_90__c = '({NetFirst}*0.2)',
            Surcharge_Vehicle_Type_Term_365__c = '0',
            Surcharge_Vehicle_Type_Term_180__c = '0',
            Surcharge_Vehicle_Type_Term_90__c = '0',
            Surcharge_Vehicle_Type_Term_30__c = '0',
            Surcharge_Vehicle_Type_Term_Daily__c = '{"Pick Up": "(0.2*((({PropertyDamage}+{TowedPropertyDamage}) - (({PropertyDamage}+{TowedPropertyDamage}) * Query([Term_Daily__c], Territory_Discount__c, [Territory__c= \'{region}\']) * 0.01)) + (({TotalTheft}+{TowedTotalTheft}) - (({TotalTheft}+{TowedTotalTheft}) * Query([Term_Daily__c], Territory_Discount__c, [Territory__c= \'{region}\']) * 0.01))))","SUV-Crossover": "((0.5*(({PropertyDamage}+{TowedPropertyDamage})-(({PropertyDamage}+{TowedPropertyDamage})*Query([Term_Daily__c],Territory_Discount__c, [Territory__c= \'{region}\'])*0.01)))+(0.1*(({TotalTheft}+{TowedTotalTheft})-(({TotalTheft}+{TowedTotalTheft})*Query([Term_Daily__c],Territory_Discount__c, [Territory__c= \'{region}\'])*0.01))))","ATV-UTV-Quads-Buggie": "((0.15*(({PropertyDamage}+{TowedPropertyDamage})-(({PropertyDamage}+{TowedPropertyDamage})*Query([Term_Daily__c],Territory_Discount__c, [Territory__c= \'{region}\'])*0.01)))+(0.2*(({TotalTheft}+{TowedTotalTheft})-(({TotalTheft}+{TowedTotalTheft})*Query([Term_Daily__c],Territory_Discount__c, [Territory__c= \'{region}\'])*0.01))))","Motorhome": "(-0.1*((({PropertyDamage}+{TowedPropertyDamage}) - (({PropertyDamage}+{TowedPropertyDamage}) * Query([Term_Daily__c], Territory_Discount__c, [Territory__c=\'{region}\']) * 0.01)) + (({TotalTheft}+{TowedTotalTheft}) - (({TotalTheft}+{TowedTotalTheft}) * Query([Term_Daily__c], Territory_Discount__c, [Territory__c= \'{region}\']) * 0.01))))"}',
            Surcharge_Vehicle_Type_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c","Year__c","Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"],"territory":["region"]}',
            Net_Second_Term_30__c = '({NetFirst} + {Platinum}+{Gold})',
            Net_Second_Term_90__c = '({NetFirst} + {Platinum}+{Gold})',
            Net_Second_Term_365__c = '({NetFirst} + {Platinum}+{Gold})',
            Net_Second_Term_180__c = '({NetFirst} + {Platinum}+{Gold})',
            Net_Second_Term_Daily__c = '({NetFirst} + {Platinum}+{Gold}-( Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01))',
            Gold_Term_365__c = '({NetFirst}*0.2)',
            Gold_Term_180__c = '({NetFirst}*0.2)',
            Gold_Term_Daily__c = '({NetFirst}*0.2-( Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01))',
            Gold_Term_90__c = '({NetFirst}*0.2)',
            Gold_Term_30__c = '({NetFirst}*0.2)',
            // Platinum_Term_180__c = '0',
            // Platinum_Term_90__c = '0',
            // Platinum_Term_365__c = '0',
            //Platinum_Term_30__c = '0',
            Platinum_Term_Daily__c = '0*({Liability} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01)',
            Net_First_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            LegalCalculation_Term_180__c = '0',
            PlaneTicketsCalculation_Term_Daily__c = '({AirplaneTickets} - ({AirplaneTickets} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01))',
            LegalCalculation_Term_365__c = '0',
            RentalCarCalculation_Term_90__c = '0',
            PlaneTicketsCalculation_Term_30__c = '0',
            PlaneTicketsCalculation_Term_90__c = '0',
            PlaneTicketsCalculation_Term_180__c = '0',
            RentalCarCalculation_Term_30__c = '0',
            LegalCalculation_Term_Daily__c = '0*({Liability} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01)',
            PartialTheftCalculation_Term_30__c = '0',
            PartialTheftCalculation_Term_90__c = '({PartialTheft} - ({PartialTheft} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01))',
            RentalCarCalculation_Term_Daily__c = '0',
            PlaneTicketsCalculation_Term_365__c = '0',
            RentalCarCalculation_Term_365__c = '({RentalCar} - ({RentalCar} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01))',
            PartialTheftCalculation_Term_Daily__c = '0',
            LegalCalculation_Term_30__c = '0',
            RentalCarCalculation_Term_180__c = '0',
            PartialTheftCalculation_Term_365__c = '0',
            LegalCalculation_Term_90__c = '0',
            PartialTheftCalculation_Term_180__c = '0',
            RoadsideTravel_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            RoadsideTravel_Term_30__c = '({Roadside})',
            RoadsideTravel_Term_90__c = '({Roadside})',
            RoadsideTravel_Term_180__c = '({Roadside})',
            RoadsideTravel_Term_Daily__c = '({Roadside}*{Days_between_Start_and_End_Date})',
            RoadsideTravel_Term_365__c = '({Roadside})',
            Rental_Car_Available__c = 'Term_Daily__c',
            Partial_Theft_Available__c = 'Term_Daily__c',
            Airplane_Tickets_Available__c = 'Term_Daily__c',
            Travel_Assist_Available__c = 'Term_Daily__c',
            Roadside_Term_Available__c = 'Term_Daily__c;Term_30__c;Term_90__c;Term_180__c;Term_365__c',
            Legal_Term_Available__c = 'Term_Daily__c',
            Rental_Car_Restrictions__c = '{"Automobile-Van-Minivan": "0.15", "Pick Up": "0.3", "SUV-Crossover": "0.09"}',
            Airplane_Tickets_Restrictions__c = '{"Automobile-Van-Minivan": "1.1", "Pick Up": "2.81", "SUV-Crossover": "0.66"}',
            Is_Rental_Car_Restrictions__c = false,
            Is_Airplane_Tickets_Restrictions__c = true,
            Roadside_Rates_Fields__c = '{     "vehicleDetails": ["Value__c", "Vehicle_sub_type__c", "Coverage__c"]}',
            Partial_Theft_Term_90__c = '0',
            Rental_Car_Term_Daily__c = '0*({Liability} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01)',
            Partial_Theft_Term_30__c = '0',
            Rental_Car_Term_30__c = '0',
            Partial_Theft_Term_365__c = '0',
            Rental_Car_Term_180__c = '0',
            Partial_Theft_Term_Daily__c = '0*({Liability} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01)',
            Partial_Theft_Term_180__c = '0',
            Rental_Car_Term_365__c = '0',
            Rental_Car_Term_90__c = '0',
            Airplane_Tickets_Term_365__c = '0',
            Airplane_Tickets_Term_90__c = '0',
            Airplane_Tickets_Term_180__c = '0',
            Airplane_Tickets_Term_Daily__c = '0*({Liability} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01)',
            Airplane_Tickets_Term_30__c = '0*({Liability} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01)',
            Travel_Assist_Term_365__c = '-15.85',
            Travel_Assist_Term_90__c = '-13.24',
            Travel_Assist_Term_180__c = '-9.45',
            Travel_Assist_Term_30__c = '-6.5',
            Travel_Assist_Term_Daily__c = '-0.3*({Liability})',
            Roadside_Term_365__c = '0',
            Roadside_Term_180__c = '0',
            Roadside_Term_90__c = '0',
            Roadside_Term_30__c = '0',
            Roadside_Term_Daily__c = '0*({Liability} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01)',
            Legal_Term_365__c = '0',
            Legal_Term_180__c = '0',
            Legal_Term_90__c = '0',
            Legal_Term_30__c = '0',
            Legal_Term_Daily__c = '0*({Liability} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01)',
            Medical_Term_365__c = '(Query([Term_365__c],New_Rate_Table__c, [Limit__c = \'{Medical__c}\']))',
            Medical_Term_180__c = '(Query([Term_180__c],New_Rate_Table__c, [Limit__c = \'{Medical__c}\']))',
            Medical_Term_90__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Limit__c = \'{Medical__c}\']) * {Days_between_Start_and_End_Date})',
            Medical_Term_30__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Limit__c = \'{Medical__c}\']) * {Days_between_Start_and_End_Date})',
            Medical_Term_Daily__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Limit__c = \'{Medical__c}\']) * {Days_between_Start_and_End_Date})',
            Medical_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c","Model","Medical__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"], "territory":["region"] }',
            Towed_Total_Theft_Term_90__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Towed_Unit_Value__c}]) * {Days_in_Tow__c})',
            Towed_Total_Theft_Term_30__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Towed_Unit_Value__c}]) * {Days_in_Tow__c})',
            Towed_Total_Theft_Term_Daily__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Towed_Unit_Value__c}]) * {Days_in_Tow__c})',
            Liability_Term_365__c = '(Query([Term_365__c],New_Rate_Table__c, [Limit__c = \'{Liability__c}\']))',
            Liability_Term_180__c = '(Query([Term_180__c],New_Rate_Table__c, [Limit__c = \'{Liability__c}\']))',
            Liability_Term_90__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Limit__c = \'{Liability__c}\']) * {Days_between_Start_and_End_Date})',
            Liability_Term_30__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Limit__c = \'{Liability__c}\']) * {Days_between_Start_and_End_Date})',
            Liability_Term_Daily__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Limit__c = \'{Liability__c}\']) * {Days_between_Start_and_End_Date})',
            Liability_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Total_Theft_Term_365__c = '(Query([Term_365__c],New_Rate_Table__c, [Vehicle_Value__c= {Value__c}]))',
            Total_Theft_Term_180__c = '(Query([Term_180__c],New_Rate_Table__c, [Vehicle_Value__c= {Value__c}]))',
            Total_Theft_Term_90__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Value__c}]) * {Days_between_Start_and_End_Date})',
            Total_Theft_Term_30__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Value__c}]) * {Days_between_Start_and_End_Date})',
            Total_Theft_Term_Daily__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Value__c}]) * {Days_between_Start_and_End_Date})',
            Property_Damage_Term_365__c = '(Query([Term_365__c],New_Rate_Table__c, [Vehicle_Value__c= {Value__c}]))',
            Property_Damage_Term_180__c = '(Query([Term_180__c],New_Rate_Table__c, [Vehicle_Value__c= {Value__c}]))',
            Property_Damage_Term_90__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Value__c}]) * {Days_between_Start_and_End_Date})',
            Property_Damage_Term_30__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Value__c}]) * {Days_between_Start_and_End_Date})',
            Property_Damage_Term_Daily__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Value__c}]) * {Days_between_Start_and_End_Date})',
            Total_Theft_Fields__c = '{     "vehicleDetails": ["Value__c", "Year__c","Vehicle_sub_type__c", "Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Towed_Property_Damage_Term_365__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Towed_Unit_Value__c}]) * {Days_in_Tow__c})',
            Towed_Property_Damage_Term_180__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Towed_Unit_Value__c}]) * {Days_in_Tow__c})',
            Towed_Property_Damage_Term_90__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Towed_Unit_Value__c}]) * {Days_in_Tow__c})',
            Towed_Property_Damage_Term_30__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Towed_Unit_Value__c}]) * {Days_in_Tow__c})',
            Towed_Property_Damage_Term_Daily__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Towed_Unit_Value__c}]) * {Days_in_Tow__c})',
            Towed_Term_Available__c = 'Term_Daily__c',
            Towed_Property_Damage_Fields__c = '{     "vehicleDetails": {         "isTowing": [],         "towunits": ["Days_in_Tow__c", "Towed_Unit_Value__c"] ,"Year__c":[], "Coverage__c":[]    },     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Physical_Damage_Fields__c = '{     "vehicleDetails": ["Value__c", "Vehicle_sub_type__c", "Coverage__c","Year__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            LiabilityTerritoryDiscount_Term_Daily__c = '{ "Baja/Sonora": "({Liability}*0.95*(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Value__c}])))","Limited": "({Liability}*0.95)", "Full": "({Liability})"}',
            MedicalTerritoryDiscount_Term_Daily__c = '{ "Baja/Sonora": "({Medical}*0.95*(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Value__c}])))","Limited": "({Medical}*0.95)", "Full": "({Medical})"}'
             );
        
        insert testVendor;

               Vendor__c chubbVendor = new Vendor__c(
            Name = 'Chubb',
            Max_Term_30__c = null,
            Max_Term_90__c = null,
            Max_Term_Daily__c = '({PartialTheft}+{AirplaneTickets}+{RentalCar})',
            Max_Term_365__c = null,
            Max_Term_180__c = null,
            Max_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c","Coverage__c"],     "termOption": ["Term__c","Max__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Is_Max__c = true,
            Is_Gold__c = true,
            Is_Platinum__c = true,
            Net_First_Term_365__c = '(({PropertyDamage}+{TowedPropertyDamage}+{TotalTheft}+{TowedTotalTheft}+{Liability}+{Medical}+{RoadsideTravel}+{Legal}))',
            Net_First_Term_30__c = '(({PropertyDamage}+{TowedPropertyDamage}+{TotalTheft}+{TowedTotalTheft}+{Liability}+{Medical}+{RoadsideTravel}+{Legal}))',
            Net_First_Term_180__c = '(({PropertyDamage}+{TowedPropertyDamage}+{TotalTheft}+{TowedTotalTheft}+{Liability}+{Medical}+{RoadsideTravel}+{Legal}))',
            Net_First_Term_90__c = '(({PropertyDamage}+{TowedPropertyDamage}+{TotalTheft}+{TowedTotalTheft}+{Liability}+{Medical}+{RoadsideTravel}+{Legal}))',
            Medical_Vehicle_Eligiblity__c = '{"vehicleList":["Motorcycle","ATV-UTV-Quads-Buggie"]}',
            Towed_Total_Theft_Term_365__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Towed_Unit_Value__c}]) * {Days_in_Tow__c})',
            Towed_Total_Theft_Term_180__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Towed_Unit_Value__c}]) * {Days_in_Tow__c})',
            Is_Age_Included_In_Towed_Property_Damage__c = false,
            Property_Damage_Vehicle_Age_Restriction__c = '100',
            Is_Age_Included_In_Property_Damage__c = false,
            Total_Fields__c = '{     "vehicleDetails": ["Value__c", "Vehicle_sub_type__c", "Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Total_Term_365__c = '({NetFourth}+{IVA}+{AgentFee}+{BrokerFee})',
            Total_Term_30__c = '({NetFourth}+{IVA}+{AgentFee}+{BrokerFee})',
            Total_Term_Daily__c = '({NetFourth}+{IVA}+{AgentFee}+{BrokerFee}-( Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between__and_End_Date}\'])*0.01))',
            Total_Term_180__c = '({NetFourth}+{IVA}+{AgentFee}+{BrokerFee})',
            Total_Term_90__c = '({NetFourth}+{IVA}+{AgentFee}+{BrokerFee})',
            Agent_Fee_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Agent_Fee_Term_Daily__c = '0*({Liability} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Starnd_Date}\'])*0.01)',
            Agent_Fee_Term_90__c = '0',
            Agent_Fee_Term_365__c = '0',
            Agent_Fee_Term_180__c = '0',
            Agent_Fee_Term_30__c = '0*({Liability} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01)',
            Broker_Fee_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Broker_Fee_Term_Daily__c = '-15-( Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01)',
            Broker_Fee_Term_30__c = '-17',
            Broker_Fee_Term_180__c = '-25',
            Broker_Fee_Term_90__c = '-20',
            Broker_Fee_Term_365__c = '-35',
            IVA_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            IVA_Term_90__c = '({NetFourth}*0.16)',
            IVA_Term_365__c = '({NetFourth}*0.16)',
            IVA_Term_180__c = '({NetFourth}*0.16)',
            IVA_Term_30__c = '({NetFourth}*0.16)',
            IVA_Term_Daily__c = '({NetFourth}*0.16-( Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01))',
            Net_Fourth_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c","Model"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"], "territory":["Territory__c"] }',
            Net_Fourth_Term_90__c = '({NetThird}-{TerritoryDiscount}-{OtherDiscount})',
            Net_Fourth_Term_30__c = '({NetThird}-{TerritoryDiscount}-{OtherDiscount})',
            Net_Fourth_Term_365__c = '({NetThird}-{TerritoryDiscount}-{OtherDiscount})',
            Net_Fourth_Term_Daily__c = '({NetThird}-{TerritoryDiscount}-{OtherDiscount}-( Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_a_Date}\'])*0.01))',
            Net_Fourth_Term_180__c = '({NetThird}-{TerritoryDiscount}-{OtherDiscount})',
            Other_Discount_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c","Model"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"], "territory":["Territory__c"] }',
            Other_Discount_Term_30__c = '0',
            Other_Discount_Term_Daily__c = '0*({Liability} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01)',
            Other_Discount_Term_90__c = '0',
            Other_Discount_Term_365__c = '0',
            Other_Discount_Term_180__c = '0',
            Territory_Discount_Fields__c = '{     "vehicleDetails": ["Value__c","Year__c", "isTowing","Liability__c","Vehicle_sub_type__c", "Coverage__c","Model"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"], "territory":["region"] }',
            Territory_Discount_Term_180__c = '((Query([Term_180__c],Territory_Discount__c, [Territory__c= \'{Territory__c}\'])*0.01)*{NetFirst})',
            Territory_Discount_Term_90__c = '((Query([Term_90__c],Territory_Discount__c, [Territory__c= \'{Territory__c}\'])*0.01)*{NetFirst})',
            Territory_Discount_Term_Daily__c = '((Query([Term_Daily__c],Territory_Discount__c, [Territory__c= \'{Territory__c}\'])*0.01)*{NetFirst})',
            Territory_Discount_Term_365__c = '((Query([Term_365__c],Territory_Discount__c, [Territory__c= \'{Territory__c}\'])*0.01)*{NetFirst})',
            Territory_Discount_Term_30__c = '((Query([Term_30__c],Territory_Discount__c, [Territory__c= \'{Territory__c}\'])*0.01)*{NetFirst})',
            Territory_Discount_Vehicle_Eligibility__c = '{"vehicleList":["Silverado 3500","Silverado 2500","Silverado 1500","Silverado","Wrangler"]}',
            Net_Third_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Net_Third_Term_Daily__c = '({TotalSurcharges}+{NetSecond}-( Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_nd_Date}\'])*0.01))',
            Net_Third_Term_180__c = '({TotalSurcharges}+{NetSecond})',
            Net_Third_Term_90__c = '({TotalSurcharges}+{NetSecond})',
            Net_Third_Term_365__c = '({TotalSurcharges}+{NetSecond})',
            Net_Third_Term_30__c = '({TotalSurcharges}+{NetSecond})',
            Total_Surcharges_Fields__c = '{     "vehicleDetails": ["Value__c", "Vehicle_sub_type__c", "Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Total_Surcharges_Term_365__c = '({SurchargeBusiness}+{SurchargeElectricHybrid}+{SurchargeAge}+{SurchargeHighRisk}+{SurchargeRental}+{SurchargeVehicleTypes})',
            Total_Surcharges_Term_90__c = '({SurchargeBusiness}+{SurchargeElectricHybrid}+{SurchargeAge}+{SurchargeHighRisk}+{SurchargeRental}+{SurchargeVehicleTypes})',
            Total_Surcharges_Term_180__c = '({SurchargeBusiness}+{SurchargeElectricHybrid}+{SurchargeAge}+{SurchargeHighRisk}+{SurchargeRental}+{SurchargeVehicleTypes})',
            Total_Surcharges_Term_Daily__c = '({SurchargeBusiness}+{SurchargeElectricHybrid}+{SurchargeAge}+{SurchargeHighRisk}+{SurchargeRental}+{SurchargeVehicleTypes}-( Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01))',
            Total_Surcharges_Term_30__c = '({SurchargeBusiness}+{SurchargeElectricHybrid}+{SurchargeAge}+{SurchargeHighRisk}+{SurchargeRental}+{SurchargeVehicleTypes})',
            Surcharge_Business_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c","is_the_vehicle_used_for_business_purpose__c","Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Surcharge_Business_Term_30__c = '({NetFirst}*0.2)',
            Surcharge_Business_Term_Daily__c = '({NetFirst}*0.2-( Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_S_and_End_Date}\'])*0.01))',
            Surcharge_Business_Term_90__c = '({NetFirst}*0.2)',
            Surcharge_Business_Term_365__c = '({NetFirst}*0.2)',
            Surcharge_Business_Term_180__c = '({NetFirst}*0.2)',
            Surcharge_Electric_Hybrid_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c","Electric_Hybrid__c","Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Surcharge_Electric_Hybrid_Term_365__c = '({NetFirst}*0.2)',
            Surcharge_Electric_Hybrid_Term_180__c = '({NetFirst}*0.2)',
            Surcharge_Electric_Hybrid_Term_30__c = '({NetFirst}*0.2)',
            Surcharge_Electric_Hybrid_Term_90__c = '({NetFirst}*0.2)',
            Surcharge_Electric_Hybrid_Term_Daily__c = '({NetFirst}*0.20*({Liability} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_andd_Date}\'])*0.01))',
            Surcharge_Age_Term_90__c = '({NetFirst}*0.2)',
            Surcharge_Age_Term_365__c = '({NetFirst}*0.2)',
            Surcharge_Age_Term_30__c = '({NetFirst}*0.2)',
            Platinum_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c","Year__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"],"territory":["region"]  }',
            Gold_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c","Coverage__c"],     "termOption": ["Term__c","Gold__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Net_Second_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Net_First_Term_Daily__c = '(({PropertyDamage}+{TowedPropertyDamage}+{TotalTheft}+{TowedTotalTheft}+{Liability}+{Medical}+{RoadsideTravel}+{Legal})-( Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_De}\'])*0.01))',
            Surcharge_Age_Term_Daily__c = '({NetFirst}*0.2-( Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_aEnd_Date}\'])*0.01))',
            Surcharge_Age_Term_180__c = '({NetFirst}*0.2)',
            Surcharge_Age_Fields__c = '{     "vehicleDetails": ["Value__c","is_there_a_driver_under_21__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Surcharge_High_Risk_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Surcharge_High_Risk_Term_180__c = '0',
            Surcharge_High_Risk_Term_365__c = '0',
            Surcharge_High_Risk_Term_Daily__c = '0*({Liability} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01)',
            Surcharge_High_Risk_Term_90__c = '0',
            Surcharge_High_Risk_Term_30__c = '0',
            Surcharge_Rental_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c","Rental__c","Is_this_a_Rental_Vehicle__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Surcharge_Rental_Term_180__c = '({NetFirst}*0.2)',
            Surcharge_Rental_Term_365__c = '({NetFirst}*0.2)',
            Surcharge_Rental_Term_Daily__c = '({NetFirst}*0.2-( Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_EnDate}\'])*0.01))',
            Surcharge_Rental_Term_30__c = '({NetFirst}*0.2)',
            Surcharge_Rental_Term_90__c = '({NetFirst}*0.2)',
            Surcharge_Vehicle_Type_Term_365__c = '0',
            Surcharge_Vehicle_Type_Term_180__c = '0',
            Surcharge_Vehicle_Type_Term_90__c = '0',
            Surcharge_Vehicle_Type_Term_30__c = '0',
            Surcharge_Vehicle_Type_Term_Daily__c = '{"Pick Up": "(0.2*((({PropertyDamage}+{TowedPropertyDamage}) - (({PropertyDamage}+{TowedPropertyDamage}) * Query([Term_Daily__c], Territory_Discount__c, [Territory__c= \'{region}\']) * 0.01)) + (({TotalTheft}+{TowedTotalTheft}) - (({TotalTheft}+{TowedTotalTheft}) * Query([Term_Daily__c], Territory_Discount__c, [Territory__c= \'{region}\']) * 0.01))))","SUV-Crossover": "((0.5*(({PropertyDamage}+{TowedPropertyDamage})-(({PropertyDamage}+{TowedPropertyDamage})*Query([Term_Daily__c],Territory_Discount__c, [Territory__c= \'{region}\'])*0.01)))+(0.1*(({TotalTheft}+{TowedTotalTheft})-(({TotalTheft}+{TowedTotalTheft})*Query([Term_Daily__c],Territory_Discount__c, [Territory__c= \'{region}\'])*0.01))))","ATV-UTV-Quads-Buggie": "((0.15*(({PropertyDamage}+{TowedPropertyDamage})-(({PropertyDamage}+{TowedPropertyDamage})*Query([Term_Daily__c],Territory_Discount__c, [Territory__c= \'{region}\'])*0.01)))+(0.2*(({TotalTheft}+{TowedTotalTheft})-(({TotalTheft}+{TowedTotalTheft})*Query([Term_Daily__c],Territory_Discount__c, [Territory__c= \'{region}\'])*0.01))))","Motorhome": "(-0.1*((({PropertyDamage}+{TowedPropertyDamage}) - (({PropertyDamage}+{TowedPropertyDamage}) * Query([Term_Daily__c], Territory_Discount__c, [Territory__c=\'{region}\']) * 0.01)) + (({TotalTheft}+{TowedTotalTheft}) - (({TotalTheft}+{TowedTotalTheft}) * Query([Term_Daily__c], Territory_Discount__c, [Territory__c= \'{region}\']) * 0.01))))"}',
            Surcharge_Vehicle_Type_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c","Year__c","Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"],"territory":["region"]}',
            Net_Second_Term_30__c = '({NetFirst} + {Platinum}+{Gold})',
            Net_Second_Term_90__c = '({NetFirst} + {Platinum}+{Gold})',
            Net_Second_Term_365__c = '({NetFirst} + {Platinum}+{Gold})',
            Net_Second_Term_180__c = '({NetFirst} + {Platinum}+{Gold})',
            Net_Second_Term_Daily__c = '({NetFirst} + {Platinum}+{Gold}-( Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_anEnd_Date}\'])*0.01))',
            Gold_Term_365__c = '({NetFirst}*0.2)',
            Gold_Term_180__c = '({NetFirst}*0.2)',
            Gold_Term_Daily__c = '({NetFirst}*0.2)',
            Gold_Term_90__c = '({NetFirst}*0.2)',
            Gold_Term_30__c = '({NetFirst}*0.2)',
            // Platinum_Term_180__c = '0',
            // Platinum_Term_90__c = '0',
            // Platinum_Term_365__c = '0',
            //Platinum_Term_30__c = '0',
            Platinum_Term_Daily__c = '0*({Liability} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01)',
            Net_First_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            LegalCalculation_Term_180__c = '0',
            PlaneTicketsCalculation_Term_Daily__c = '({AirplaneTickets} - ({AirplaneTickets} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01))',
            LegalCalculation_Term_365__c = '0',
            RentalCarCalculation_Term_90__c = '0',
            PlaneTicketsCalculation_Term_30__c = '0',
            PlaneTicketsCalculation_Term_90__c = '0',
            PlaneTicketsCalculation_Term_180__c = '0',
            RentalCarCalculation_Term_30__c = '0',
            LegalCalculation_Term_Daily__c = '0*({Liability} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01)',
            PartialTheftCalculation_Term_30__c = '0',
            PartialTheftCalculation_Term_90__c = '({PartialTheft} - ({PartialTheft} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01))',
            RentalCarCalculation_Term_Daily__c = '0',
            PlaneTicketsCalculation_Term_365__c = '0',
            RentalCarCalculation_Term_365__c = '({RentalCar} - ({RentalCar} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01))',
            PartialTheftCalculation_Term_Daily__c = '0',
            LegalCalculation_Term_30__c = '0',
            RentalCarCalculation_Term_180__c = '0',
            PartialTheftCalculation_Term_365__c = '0',
            LegalCalculation_Term_90__c = '0',
            PartialTheftCalculation_Term_180__c = '0',
            RoadsideTravel_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            RoadsideTravel_Term_30__c = '({Roadside})',
            RoadsideTravel_Term_90__c = '({Roadside})',
            RoadsideTravel_Term_180__c = '({Roadside})',
            RoadsideTravel_Term_Daily__c = '({Roadside}*{Days_between_Start_and_End_Date})',
            RoadsideTravel_Term_365__c = '({Roadside})',
            Rental_Car_Available__c = 'Term_Daily__c',
            Partial_Theft_Available__c = 'Term_Daily__c',
            Airplane_Tickets_Available__c = 'Term_Daily__c',
            Travel_Assist_Available__c = 'Term_Daily__c',
            Roadside_Term_Available__c = 'Term_Daily__c;Term_30__c;Term_90__c;Term_180__c;Term_365__c',
            Legal_Term_Available__c = 'Term_Daily__c',
            Rental_Car_Restrictions__c = '{"Automobile-Van-Minivan": "0.15", "Pick Up": "0.3", "SUV-Crossover": "0.09"}',
            Airplane_Tickets_Restrictions__c = '{"Automobile-Van-Minivan": "1.1", "Pick Up": "2.81", "SUV-Crossover": "0.66"}',
            Is_Rental_Car_Restrictions__c = false,
            Is_Airplane_Tickets_Restrictions__c = true,
            Roadside_Rates_Fields__c = '{     "vehicleDetails": ["Value__c", "Vehicle_sub_type__c", "Coverage__c"]}',
            Partial_Theft_Term_90__c = '0',
            Rental_Car_Term_Daily__c = '0*({Liability} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01)',
            Partial_Theft_Term_30__c = '0',
            Rental_Car_Term_30__c = '0',
            Partial_Theft_Term_365__c = '0',
            Rental_Car_Term_180__c = '0',
            Partial_Theft_Term_Daily__c = '0*({Liability} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01)',
            Partial_Theft_Term_180__c = '0',
            Rental_Car_Term_365__c = '0',
            Rental_Car_Term_90__c = '0',
            Airplane_Tickets_Term_365__c = '0',
            Airplane_Tickets_Term_90__c = '0',
            Airplane_Tickets_Term_180__c = '0',
            Airplane_Tickets_Term_Daily__c = '0*({Liability} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01)',
            Airplane_Tickets_Term_30__c = '0*({Liability} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01)',
            Travel_Assist_Term_365__c = '-15.85',
            Travel_Assist_Term_90__c = '-13.24',
            Travel_Assist_Term_180__c = '-9.45',
            Travel_Assist_Term_30__c = '-6.5',
            Travel_Assist_Term_Daily__c = '-0.3*({Liability})',
            Roadside_Term_365__c = '0',
            Roadside_Term_180__c = '0',
            Roadside_Term_90__c = '0',
            Roadside_Term_30__c = '0',
            Roadside_Term_Daily__c = '0*({Liability} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01)',
            Legal_Term_365__c = '0',
            Legal_Term_180__c = '0',
            Legal_Term_90__c = '0',
            Legal_Term_30__c = '0',
            Legal_Term_Daily__c = '0*({Liability} * Query([Discount_Percentage__c],Discount_Table__c, [Days__c= \'{Days_between_Start_and_End_Date}\'])*0.01)',
            Medical_Term_365__c = '(Query([Term_365__c],New_Rate_Table__c, [Limit__c = \'{Medical__c}\']))',
            Medical_Term_180__c = '(Query([Term_180__c],New_Rate_Table__c, [Limit__c = \'{Medical__c}\']))',
            Medical_Term_90__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Limit__c = \'{Medical__c}\']) * {Days_between_Start_and_End_Date})',
            Medical_Term_30__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Limit__c = \'{Medical__c}\']) * {Days_between_Start_and_End_Date})',
            Medical_Term_Daily__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Limit__c = \'{Medical__c}\']) * {Days_between_Start_and_End_Date})',
            Medical_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c","Model","Medical__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"], "territory":["region"] }',
            Towed_Total_Theft_Term_90__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Towed_Unit_Value__c}]) * {Days_in_Tow__c})',
            Towed_Total_Theft_Term_30__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Towed_Unit_Value__c}]) * {Days_in_Tow__c})',
            Towed_Total_Theft_Term_Daily__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Towed_Unit_Value__c}]) * {Days_in_Tow__c})',
            Liability_Term_365__c = '(Query([Term_365__c],New_Rate_Table__c, [Limit__c = \'{Liability__c}\']))',
            Liability_Term_180__c = '(Query([Term_180__c],New_Rate_Table__c, [Limit__c = \'{Liability__c}\']))',
            Liability_Term_90__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Limit__c = \'{Liability__c}\']) * {Days_between_Start_and_End_Date})',
            Liability_Term_30__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Limit__c = \'{Liability__c}\']) * {Days_between_Start_and_End_Date})',
            Liability_Term_Daily__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Limit__c = \'{Liability__c}\']) * {Days_between_Start_and_End_Date})',
            Liability_Fields__c = '{     "vehicleDetails": ["Value__c", "Liability__c","Vehicle_sub_type__c", "Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Total_Theft_Term_365__c = '(Query([Term_365__c],New_Rate_Table__c, [Vehicle_Value__c= {Value__c}]))',
            Total_Theft_Term_180__c = '(Query([Term_180__c],New_Rate_Table__c, [Vehicle_Value__c= {Value__c}]))',
            Total_Theft_Term_90__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Value__c}]) * {Days_between_Start_and_End_Date})',
            Total_Theft_Term_30__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Value__c}]) * {Days_between_Start_and_End_Date})',
            Total_Theft_Term_Daily__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Value__c}]) * {Days_between_Start_and_End_Date})',
            Property_Damage_Term_365__c = '(Query([Term_365__c],New_Rate_Table__c, [Vehicle_Value__c= {Value__c}]))',
            Property_Damage_Term_180__c = '(Query([Term_180__c],New_Rate_Table__c, [Vehicle_Value__c= {Value__c}]))',
            Property_Damage_Term_90__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Value__c}]) * {Days_between_Start_and_End_Date})',
            Property_Damage_Term_30__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Value__c}]) * {Days_between_Start_and_End_Date})',
            Property_Damage_Term_Daily__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Value__c}]) * {Days_between_Start_and_End_Date})',
            Total_Theft_Fields__c = '{     "vehicleDetails": ["Value__c", "Year__c","Vehicle_sub_type__c", "Coverage__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Towed_Property_Damage_Term_365__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Towed_Unit_Value__c}]) * {Days_in_Tow__c})',
            Towed_Property_Damage_Term_180__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Towed_Unit_Value__c}]) * {Days_in_Tow__c})',
            Towed_Property_Damage_Term_90__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Towed_Unit_Value__c}]) * {Days_in_Tow__c})',
            Towed_Property_Damage_Term_30__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Towed_Unit_Value__c}]) * {Days_in_Tow__c})',
            Towed_Property_Damage_Term_Daily__c = '(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Towed_Unit_Value__c}]) * {Days_in_Tow__c})',
            Towed_Term_Available__c = 'Term_Daily__c',
            Towed_Property_Damage_Fields__c = '{     "vehicleDetails": {         "isTowing": [],         "towunits": ["Days_in_Tow__c", "Towed_Unit_Value__c"] ,"Year__c":[], "Coverage__c":[]    },     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            Physical_Damage_Fields__c = '{     "vehicleDetails": ["Value__c", "Vehicle_sub_type__c", "Coverage__c","Year__c"],     "termOption": ["Term__c", "Start_Date_for_Coverage__c", "End_Date_for_Coverage__c"] }',
            LiabilityTerritoryDiscount_Term_Daily__c = '{ "Baja/Sonora": "({Liability}*0.95*(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Value__c}]))","Limited": "({Liability}*0.95)", "Full": "({Liability})"}',
            MedicalTerritoryDiscount_Term_Daily__c = '{ "Baja/Sonora": "({Medical}*0.95*(Query([Term_Daily__c],New_Rate_Table__c, [Vehicle_Value__c= {Value__c}]))","Limited": "({Medical}*0.95)", "Full": "({Medical})"}'
             );
        
        insert chubbVendor;

        
        // Insert New Rate Table data
        List<New_Rate_Table__c> rateTableRecords = new List<New_Rate_Table__c>{
            new New_Rate_Table__c(
                Vehicle_Value__c = 10000,
                Data_type__c = 'Physical Damage',
                Term_Daily__c = '3.78',
                Term_180__c = '72.00',
                Term_365__c = '120.00',
                Object_Name__c = 'Rate',
                Vendor__c = 'Qualitas'
            ),
                new New_Rate_Table__c(
                    Vehicle_Value__c = 10000,
                    Data_type__c = 'Total Theft',
                    Term_Daily__c = '1.43',
                    Term_180__c = '43.20',
                    Term_365__c = '55.07',
                    Object_Name__c = 'Rate',
                    Vendor__c = 'Qualitas'
                ),
                new New_Rate_Table__c(
                    Term_Daily__c = '3.20',
                    Term_180__c = '109',
                    Term_365__c = '122.50',
                    Object_Name__c = 'Liability',
                    Vendor__c = 'Qualitas',
                    Limit__c = '100,000'
                ),
                new New_Rate_Table__c(
                    Term_Daily__c = '0.16',
                    Term_180__c = '5.8',
                    Term_365__c ='6.56',
                    Object_Name__c = 'Medical',
                    Vendor__c = 'Qualitas',
                    Limit__c = '2,000/10,000'
                )
                };
                 insert rateTableRecords;
        
        // Insert Territory Discount data
        List<Territory_Discount__c> territoryDiscounts = new List<Territory_Discount__c>{
            new Territory_Discount__c(
                Territory__c = 'Limited',
                Vendor__c = 'Qualitas',
                Term_180__c = '20',
                Term_30__c = '20',
                Term_365__c = '20',
                Term_90__c = '20',
                Term_Daily__c = '20'
            ),
                new Territory_Discount__c(
                    Territory__c = 'Baja/Sonora',
                    Vendor__c = 'Qualitas',
                    Term_180__c = '30',
                    Term_30__c = '30',
                    Term_365__c = '30',
                    Term_90__c = '30',
                    Term_Daily__c = '30'
                )
                };
                 insert territoryDiscounts;
    }
    
    @isTest
    public static void testCalculateCoverageMethodOne(){
        Test.startTest();
        String jsonString = '[{"userDetails":{"Email":"adarshkumar+test9911@cloudanalogy.com","FirstName":"Adarsh","Phone":"7979830325","LastName":"Kumar","Id":"003VD00000bSglPYAS"}},{"vehicleDetails":{"is_the_vehicle_used_for_business_purpose__c":true,"is_there_a_driver_under_21__c":false,"Rental__c":"true","Is_this_a_Rental_Vehicle__c":"true","salvage_vehicle__c":false,"Coverage__c":"Complete","isTowing":false,"Electric_Hybrid__c":true,"towunits":[],"Liability__c":"100,000","Medical__c":"2,000/10,000","Year__c":"2025","Vehicle_sub_type__c":"Pick Up","Make":"Audi","Model":"Q4 e-tron","Value__c":"10000","Vin__c":"WAUAUAF33L1080104","Registered_Country__c":"Canada","Registered_State__c":"Manitoba","licensePlate":"444444","Id":"a0GVD000004QqBz2AK","Make__c":"Audi","Model__c":"Q4 e-tron","Account_Vehicle__c":"001VD00000LlOlzYAF","Contact__c":"003VD00000bSglPYAS"}},{"termOption":{"Term__c":"Daily","Start_Date_for_Coverage__c":"2025-06-13","Start_Time__c":"05:30:00","End_Date_for_Coverage__c":"2025-06-14","End_Time__c":"05:30:00"}},{"territory":{"region":"Baja/Sonora"}}]';
        CalculateCoverageTitleAndDescription.getDescriptionAndTitle(jsonString);
        Test.stopTest();
        jsonString = '[{"userDetails":{"Email":"adarshkumar+test9911@cloudanalogy.com","FirstName":"Adarsh","Phone":"7979830325","LastName":"Kumar","Id":"003VD00000bSglPYAS"}},{"vehicleDetails":{"is_the_vehicle_used_for_business_purpose__c":false,"is_there_a_driver_under_21__c":false,"Is_this_a_Rental_Vehicle__c":false,"salvage_vehicle__c":false,"Coverage__c":"Complete","isTowing":true,"Electric_Hybrid__c":false,"towunits":[{"Towed_Unit_Type__c":"Camper","Towed_Unit_Value__c":"25000","Days_in_Tow__c":"1"}],"Liability__c":"100,000","Medical__c":"2,000/10,000","Year__c":"2025","Vehicle_sub_type__c":"Automobile","Make":"Audi","Model":"Q4 e-tron","Value__c":"10000","Vin__c":"WAUAUAF33L1080104","Registered_Country__c":"Canada","Registered_State__c":"Manitoba","licensePlate":"444444","Id":"a0GVD000004QqBz2AK","Make__c":"Audi","Model__c":"Q4 e-tron","Account_Vehicle__c":"001VD00000LlOlzYAF","Contact__c":"003VD00000bSglPYAS"}},{"termOption":{"Term__c":"Daily","Start_Date_for_Coverage__c":"2025-06-13","Start_Time__c":"05:30:00","End_Date_for_Coverage__c":"2025-06-14","End_Time__c":"05:30:00"}},{"territory":{"region":"Baja/Sonora"}}]';
        CalculateCoverageTitleAndDescription.getDescriptionAndTitle(jsonString);
        jsonString = '[{"userDetails":{"Email":"adarshkumar+test9911@cloudanalogy.com","FirstName":"Adarsh","Phone":"7979830325","LastName":"Kumar","Id":"003VD00000bSglPYAS"}},{"vehicleDetails":{"is_the_vehicle_used_for_business_purpose__c":false,"is_there_a_driver_under_21__c":false,"Is_this_a_Rental_Vehicle__c":false,"salvage_vehicle__c":false,"Coverage__c":"Complete","isTowing":true,"Electric_Hybrid__c":true,"towunits":{"Towed_Unit_Type__c":"Camper","Towed_Unit_Value__c":"25000","Days_in_Tow__c":"1"},"Liability__c":"100,000","Medical__c":"2,000/10,000","Year__c":"2025","Vehicle_sub_type__c":"Automobile","Make":"Audi","Model":"Q4 e-tron","Value__c":"10000","Vin__c":"WAUAUAF33L1080104","Registered_Country__c":"Canada","Registered_State__c":"Manitoba","licensePlate":"444444","Id":"a0GVD000004QqBz2AK","Make__c":"Audi","Model__c":"Q4 e-tron","Account_Vehicle__c":"001VD00000LlOlzYAF","Contact__c":"003VD00000bSglPYAS"}},{"termOption":{"Term__c":"Daily","Start_Date_for_Coverage__c":"2025-06-13","Start_Time__c":"05:30:00","End_Date_for_Coverage__c":"2025-06-14","End_Time__c":"05:30:00"}},{"territory":{"region":"Baja/Sonora"}}]';
        CalculateCoverageTitleAndDescription.getDescriptionAndTitle(jsonString);

        
    }
    
    @isTest
    public static void testCalculateCoverageMethodTwo(){
        String jsonString = '[{"userDetails":{"Email":"adarshkumar+test9911@cloudanalogy.com","FirstName":"Adarsh","Phone":"7979830325","LastName":"Kumar","Id":"003VD00000bSglPYAS"}},{"vehicleDetails":{"is_the_vehicle_used_for_business_purpose__c":true,"is_there_a_driver_under_21__c":true,"Is_this_a_Rental_Vehicle__c":true,"salvage_vehicle__c":false,"Coverage__c":"Complete","isTowing":false,"Electric_Hybrid__c":false,"towunits":[],"Liability__c":"100,000","Medical__c":"2,000/10,000","Year__c":"2025","Vehicle_sub_type__c":"Automobile","Make":"Audi","Model":"Q4 e-tron","Value__c":"10000","Vin__c":"WAUAUAF33L1080104","Registered_Country__c":"Canada","Registered_State__c":"Manitoba","licensePlate":"444444","Id":"a0GVD000004QqBz2AK","Make__c":"Audi","Model__c":"Q4 e-tron","Account_Vehicle__c":"001VD00000LlOlzYAF","Contact__c":"003VD00000bSglPYAS"}},{"termOption":{"Term__c":"Daily","Start_Date_for_Coverage__c":"2025-06-13","Start_Time__c":"05:30:00","End_Date_for_Coverage__c":"2025-06-14","End_Time__c":"05:30:00","Max__c":"true","Gold__c":"true","Platinum__c":"true"}},{"territory":{"region":"Baja/Sonora"}}]';
        CalculateCoverageTitleAndDescription.getDescriptionAndTitle(jsonString);
        jsonString = '[{"userDetails":{"Email":"adarshkumar+test9911@cloudanalogy.com","FirstName":"Adarsh","Phone":"7979830325","LastName":"Kumar","Id":"003VD00000bSglPYAS"}},{"vehicleDetails":{"is_the_vehicle_used_for_business_purpose__c":true,"is_there_a_driver_under_21__c":true,"Is_this_a_Rental_Vehicle__c":true,"salvage_vehicle__c":false,"Coverage__c":"Complete","isTowing":false,"Electric_Hybrid__c":false,"towunits":[],"Liability__c":"100,000","Medical__c":"2,000/10,000","Year__c":"2025","Vehicle_sub_type__c":"Automobile","Make":"Audi","Model":"Q4 e-tron","Value__c":"10000","Vin__c":"WAUAUAF33L1080104","Registered_Country__c":"Canada","Registered_State__c":"Manitoba","licensePlate":"444444","Id":"a0GVD000004QqBz2AK","Make__c":"Audi","Model__c":"Q4 e-tron","Account_Vehicle__c":"001VD00000LlOlzYAF","Contact__c":"003VD00000bSglPYAS"}},{"termOption":{"Term__c":"Daily","Start_Date_for_Coverage__c":"2025-06-13","Start_Time__c":"05:30:00","End_Date_for_Coverage__c":"2025-06-14","End_Time__c":"05:30:00"}},{"territory":{"region":"Baja/Sonora"}}]';
        CalculateCoverageTitleAndDescription.getDescriptionAndTitle(jsonString);
        
    }

    @isTest
    public static void testCalculateCoverageMethodThree(){
        String jsonString = '[{"userDetails":{"Email":"adarshkumar+test9911@cloudanalogy.com","FirstName":"Adarsh","Phone":"7979830325","LastName":"Kumar","Id":"003VD00000bSglPYAS"}},{"vehicleDetails":{"is_the_vehicle_used_for_business_purpose__c":true,"is_there_a_driver_under_21__c":true,"Is_this_a_Rental_Vehicle__c":true,"salvage_vehicle__c":false,"Coverage__c":"Complete","isTowing":false,"Electric_Hybrid__c":true,"towunits":[],"Liability__c":"100,000","Medical__c":"2,000/10,000","Year__c":"2025","Vehicle_sub_type__c":"Automobile","Make":"Audi","Model":"Q4 e-tron","Value__c":"10000","Vin__c":"WAUAUAF33L1080104","Registered_Country__c":"Canada","Registered_State__c":"Manitoba","licensePlate":"444444","Id":"a0GVD000004QqBz2AK","Make__c":"Audi","Model__c":"Q4 e-tron","Account_Vehicle__c":"001VD00000LlOlzYAF","Contact__c":"003VD00000bSglPYAS"}},{"termOption":{"Term__c":"Daily","Start_Date_for_Coverage__c":"2025-06-13","Start_Time__c":"05:30:00","End_Date_for_Coverage__c":"2025-06-14","End_Time__c":"05:30:00"}},{"territory":{"region":"Baja/Sonora"}}]';
        CalculateCoverageTitleAndDescription.getDescriptionAndTitle(jsonString);
        
    }
    public static void testCalculateCoverageMethodFour(){
        String jsonString = '[{"userDetails":{"Email":"adarshkumar+test9911@cloudanalogy.com","FirstName":"Adarsh","Phone":"7979830325","LastName":"Kumar","Id":"003VD00000bSglPYAS"}},{"vehicleDetails":{"is_the_vehicle_used_for_business_purpose__c":true,"is_there_a_driver_under_21__c":true,"Is_this_a_Rental_Vehicle__c":true,"salvage_vehicle__c":false,"Coverage__c":"Complete","isTowing":false,"Electric_Hybrid__c":false,"towunits":[],"Liability__c":"100,000","Medical__c":"2,000/10,000","Year__c":"2025","Vehicle_sub_type__c":"Automobile","Make":"Audi","Model":"Q4 e-tron","Value__c":"10000","Vin__c":"WAUAUAF33L1080104","Registered_Country__c":"Canada","Registered_State__c":"Manitoba","licensePlate":"444444","Id":"a0GVD000004QqBz2AK","Make__c":"Audi","Model__c":"Q4 e-tron","Account_Vehicle__c":"001VD00000LlOlzYAF","Contact__c":"003VD00000bSglPYAS"}},{"termOption":{"Term__c":"Daily","Start_Date_for_Coverage__c":"2025-06-13","Start_Time__c":"05:30:00","End_Date_for_Coverage__c":"2025-06-14","End_Time__c":"05:30:00"}},{"territory":{"region":"Baja/Sonora"}}]';
        CalculateCoverageTitleAndDescription.getDescriptionAndTitle(jsonString);
        
    }

@isTest
    static void testSimpleIfCondition() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'CoverageType' => 'Theft'
        };
        
        String formula = 'if (CoverageType == "Theft") {"Covered"}';
        String result = vehicleTheftCoverageDetails.evaluateFormula(formula, dataMap);
        System.debug('Result: ' + result);
    }

    @isTest
    static void testIfElseCondition() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'CoverageType' => 'Collision'
        };

        String formula = 'if (CoverageType == "Theft") {"Covered"} else {"Not Covered"}';
        String result = vehicleTheftCoverageDetails.evaluateFormula(formula, dataMap);
        System.debug('Result: ' + result);
    }

    @isTest
    static void testIfElseIfElseCondition() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'CoverageType' => 'Fire'
        };

        String formula = 'if (CoverageType == "Theft") {"Theft Covered"} else if (CoverageType == "Fire") {"Fire Covered"} else {"Not Covered"}';
        String result = vehicleTheftCoverageDetails.evaluateFormula(formula, dataMap);
        System.debug('Result: ' + result);
    }

    @isTest
    static void testStringConcatenationBlock() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'Vendor' => 'Chubb',
            'Region' => 'Limited'
        };

        String formula = 'if (Vendor == "Chubb") {"Region: " + Region}';
        String result = vehicleTheftCoverageDetails.evaluateFormula(formula, dataMap);
        System.debug('Result: ' + result);
    }

    @isTest
    static void testNumericComparison() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'UpdatedVehicleValue' => 20000
        };

        String formula = 'if (UpdatedVehicleValue > 15000) {"High Value"} else {"Low Value"}';
        String result = vehicleTheftCoverageDetails.evaluateFormula(formula, dataMap);
        System.debug('Result: ' + result);
    }

    @isTest
    static void testInvalidCondition() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'CoverageType' => 'Fire'
        };

        String formula = 'if (CoverageType === "Fire") {"Wrong Operator"}'; // Invalid operator
        String result = vehicleTheftCoverageDetails.evaluateFormula(formula, dataMap);
        System.debug('Result: ' + result);
    }

    @isTest
    static void testMalformedFormula() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'AnyField' => 'value'
        };

        String formula = 'if (AnyField == "value") {"ok"'; // Missing closing brace
        String result = vehicleTheftCoverageDetails.evaluateFormula(formula, dataMap);
        System.debug('Result: ' + result);
    }

@isTest
    static void testEvaluateFormula_SimpleIfTrue() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'CoverageLevel' => 'High'
        };
        String formula = 'if(CoverageLevel == "High") {"Covered"}';
        String result = partialTheftCoverageDetails.evaluateFormula(formula, dataMap);
        System.assertEquals('Covered', result);
    }

    @isTest
    static void testEvaluateFormula_IfElse_TrueCondition() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'CoverageLevel' => 'High'
        };
        String formula = 'if(CoverageLevel == "High") {"Covered"} else {"Not Covered"}';
        String result = partialTheftCoverageDetails.evaluateFormula(formula, dataMap);
        System.assertEquals('Covered', result);
    }

    @isTest
    static void testEvaluateFormula_IfElse_FalseCondition() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'CoverageLevel' => 'Low'
        };
        String formula = 'if(CoverageLevel == "High") {"Covered"} else {"Not Covered"}';
        String result = partialTheftCoverageDetails.evaluateFormula(formula, dataMap);
        System.assertEquals('Not Covered', result);
    }

    @isTest
    static void testEvaluateFormula_NumericComparison() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'VehicleValue' => 20000
        };
        String formula = 'if(VehicleValue > 15000) {"Eligible"} else {"Ineligible"}';
        String result = partialTheftCoverageDetails.evaluateFormula(formula, dataMap);
        System.assertEquals('Eligible', result);
    }

    @isTest
    static void testEvaluateFormula_Concatenation() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'Owner' => 'John',
            'Status' => 'Approved'
        };
        String formula = 'if(Status == "Approved") {"Owner: " + Owner}';
        String result = partialTheftCoverageDetails.evaluateFormula(formula, dataMap);
        System.assertEquals('Owner: John', result);
    }

    @isTest
    static void testEvaluateFormula_ElseIfBlock() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'RiskLevel' => 'Medium'
        };
        String formula = 'if(RiskLevel == "High") {"Reject"} else if(RiskLevel == "Medium") {"Review"} else {"Accept"}';
        String result = partialTheftCoverageDetails.evaluateFormula(formula, dataMap);
        System.assertEquals('Review', result);
    }

    @isTest
    static void testEvaluateFormula_ElseNestedIf() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'Type' => 'Basic'
        };
        String formula = 'if(Type == "Premium") {"Full"} else {if(Type == "Basic") {"Partial"} else {"None"}}';
        String result = partialTheftCoverageDetails.evaluateFormula(formula, dataMap);
        System.assertEquals('Partial', result);
    }

    @isTest
    static void testEvaluateFormula_InvalidCondition() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'Amount' => 1000
        };
        // malformed formula (missing closing brace)
        String formula = 'if(Amount > 500) {"OK"';
        String result = partialTheftCoverageDetails.evaluateFormula(formula, dataMap);
        System.assertEquals(null, result);
    }

  @isTest
    static void testIfConditionTrue() {
        String formula = 'if(UpdatedVehicleValue >= 10000) {"Approved"}';
        Map<String, Object> dataMap = new Map<String, Object>{ 'UpdatedVehicleValue' => 15000 };
        
        String result = damageVehicleCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Approved', result);
    }

    @isTest
    static void testIfConditionFalseElseBlock() {
        String formula = 'if(UpdatedVehicleValue > 20000) {"High"} else {"Standard"}';
        Map<String, Object> dataMap = new Map<String, Object>{ 'UpdatedVehicleValue' => 10000 };

        String result = damageVehicleCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Standard', result);
    }

    @isTest
    static void testElseIfBlock() {
        String formula = 'if(UpdatedVehicleValue < 5000) {"Low"} else if(UpdatedVehicleValue < 15000) {"Medium"} else {"High"}';
        Map<String, Object> dataMap = new Map<String, Object>{ 'UpdatedVehicleValue' => 10000 };

        String result = damageVehicleCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Medium', result);
    }

    @isTest
    static void testNestedIfInElse() {
        String formula = 'if(UpdatedVehicleValue > 20000) {"High"} else {if(UpdatedVehicleValue > 10000) {"Mid-High"} else {"Low"}}';
        Map<String, Object> dataMap = new Map<String, Object>{ 'UpdatedVehicleValue' => 12000 };

        String result = damageVehicleCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Mid-High', result);
    }

    @isTest
    static void testConcatenatedBlockValue() {
        String formula = 'if(UpdatedVehicleValue == 10000) {"Value: " + UpdatedVehicleValue}';
        Map<String, Object> dataMap = new Map<String, Object>{ 'UpdatedVehicleValue' => 10000 };

        String result = damageVehicleCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Value: 10000', result);
    }

    @isTest
    static void testInvalidConditionHandling() {
        String formula = 'if(UpdatedVehicleValue === 10000) {"Wrong Syntax"} else {"Handled"}';
        Map<String, Object> dataMap = new Map<String, Object>{ 'UpdatedVehicleValue' => 10000 };

        String result = damageVehicleCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Handled', result);
    }

@isTest
    static void testIfConditionTrue11() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'CoverageType' => 'Basic',
            'UpdatedTowedValue' => 20000
        };

        String formula = 'if(UpdatedTowedValue >= 15000) {"Approved"} else {"Denied"}';
        String result = underinsuredVehicleCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Approved', result);
    }

    @isTest
    static void testIfConditionFalse() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'CoverageType' => 'Basic',
            'UpdatedTowedValue' => 10000
        };

        String formula = 'if(UpdatedTowedValue > 15000) {"Approved"} else {"Denied"}';
        String result = underinsuredVehicleCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Denied', result);
    }

    @isTest
    static void testElseIfCondition() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'CoverageType' => 'Standard',
            'UpdatedTowedValue' => 13000
        };

        String formula = 'if(UpdatedTowedValue > 20000) {"High"} else if(UpdatedTowedValue >= 13000) {"Medium"} else {"Low"}';
        String result = underinsuredVehicleCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Medium', result);
    }

    @isTest
    static void testNestedIfInElse11() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'UpdatedTowedValue' => 9000
        };

        String formula = 'if(UpdatedTowedValue > 20000) {"High"} else {if(UpdatedTowedValue >= 10000) {"Medium"} else {"Low"}}';
        String result = underinsuredVehicleCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Low', result);
    }

    @isTest
    static void testBlockWithConcatenation() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'UpdatedTowedValue' => 16000,
            'CoverageType' => 'Premium'
        };

        String formula = 'if(UpdatedTowedValue >= 15000) {"Type: " + CoverageType + " | Value: " + UpdatedTowedValue} else {"Not Eligible"}';
        String result = underinsuredVehicleCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Type: Premium | Value: 16000', result);
    }

    @isTest
    static void testInvalidConditionReturnsEmpty() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'UpdatedTowedValue' => 12000
        };

        String formula = 'if(InvalidField > 10000) {"Invalid"} else {"Fallback"}';
        String result = underinsuredVehicleCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Fallback', result);
    }

@isTest
    static void testIfConditionTrue22() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'RepairCost' => 800
        };
        String formula = 'if(RepairCost > 500) { "Covered in US" }';
        String result = repairinUsCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Covered in US', result);
    }
    
    @isTest
    static void testIfConditionFalseElseUsed() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'RepairCost' => 400
        };
        String formula = 'if(RepairCost > 500) { "Covered" } else { "Not Covered" }';
        String result = repairinUsCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Not Covered', result);
    }

    @isTest
    static void testElseIfConditionUsed() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'RepairCost' => 600
        };
        String formula = 'if(RepairCost > 1000) { "Tier 1" } else if(RepairCost > 500) { "Tier 2" } else { "Tier 3" }';
        String result = repairinUsCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Tier 2', result);
    }

    @isTest
    static void testElseIfNotUsedElseFallback() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'RepairCost' => 200
        };
        String formula = 'if(RepairCost > 1000) { "Tier 1" } else if(RepairCost > 500) { "Tier 2" } else { "Tier 3" }';
        String result = repairinUsCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Tier 3', result);
    }

    @isTest
    static void testNestedIfInElse22() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'RepairCost' => 300,
            'Country' => 'US'
        };
        String formula = 'if(RepairCost > 500) { "Covered" } else { if(Country == "US") { "US Only" } else { "Intl" } }';
        String result = repairinUsCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('US Only', result);
    }

    @isTest
    static void testConcatenationInBlock() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'RepairCost' => 750,
            'Location' => 'California'
        };
        String formula = 'if(RepairCost > 500) { "Approved in " + Location } else { "Denied" }';
        String result = repairinUsCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Approved in California', result);
    }

    @isTest
    static void testInvalidConditionFallback() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'RepairCost' => 300
        };
        String formula = 'if(InvalidField > 500) { "Invalid" } else { "Safe" }';
        String result = repairinUsCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Safe', result);
    }

    @isTest
    static void testEmptyElseHandled() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'RepairCost' => 300
        };
        String formula = 'if(RepairCost > 1000) { "Too High" }';
        String result = repairinUsCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('', result); // No else block, no match
    }

    @isTest
    static void testIfConditionTrue33() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'UpdatedTowedValue' => 15000
        };
        String formula = 'if(UpdatedTowedValue > 10000) { "GAP Covered" }';
        String result = gapCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('GAP Covered', result);
    }

    @isTest
    static void testIfConditionFalseWithElse() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'UpdatedTowedValue' => 9000
        };
        String formula = 'if(UpdatedTowedValue > 10000) { "GAP Covered" } else { "Not Covered" }';
        String result = gapCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Not Covered', result);
    }

    @isTest
    static void testElseIfUsed() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'UpdatedTowedValue' => 11000
        };
        String formula = 'if(UpdatedTowedValue > 15000) { "High GAP" } else if(UpdatedTowedValue > 10000) { "Medium GAP" } else { "Low GAP" }';
        String result = gapCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Medium GAP', result);
    }

    @isTest
    static void testElseUsedAsFallback() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'UpdatedTowedValue' => 8000
        };
        String formula = 'if(UpdatedTowedValue > 15000) { "High GAP" } else if(UpdatedTowedValue > 10000) { "Medium GAP" } else { "Low GAP" }';
        String result = gapCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Low GAP', result);
    }

    @isTest
    static void testNestedIfInsideElse() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'UpdatedTowedValue' => 8000,
            'Country' => 'US'
        };
        String formula = 'if(UpdatedTowedValue > 15000) { "High" } else { if(Country == "US") { "Domestic GAP" } else { "Foreign GAP" } }';
        String result = gapCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Domestic GAP', result);
    }

    @isTest
    static void testBlockConcatenation() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'UpdatedTowedValue' => 16000,
            'Territory' => 'Mexico'
        };
        String formula = 'if(UpdatedTowedValue > 15000) { "GAP Applicable in " + Territory }';
        String result = gapCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('GAP Applicable in Mexico', result);
    }

    @isTest
    static void testInvalidFieldInCondition() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'SomeOtherField' => 10000
        };
        String formula = 'if(UpdatedTowedValue > 5000) { "Yes" } else { "No" }';
        String result = gapCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('No', result); // because UpdatedTowedValue is null
    }

    @isTest
    static void testOnlyIfConditionFalseWithoutElse() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'UpdatedTowedValue' => 5000
        };
        String formula = 'if(UpdatedTowedValue > 10000) { "Yes" }';
        String result = gapCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('', result); // no else block, return empty
    }
  @isTest
    static void vandalismCoverage_ifConditionTrue_shouldReturnValue() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'UpdatedVehicleValue' => 20000
        };
        String formula = 'if(UpdatedVehicleValue > 15000) { "Vandalism Covered" }';
        String result = vandalismCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Vandalism Covered', result);
    }

    @isTest
    static void vandalismCoverage_ifConditionFalse_shouldReturnElseValue() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'UpdatedVehicleValue' => 10000
        };
        String formula = 'if(UpdatedVehicleValue > 15000) { "Vandalism Covered" } else { "Not Covered" }';
        String result = vandalismCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Not Covered', result);
    }

    @isTest
    static void vandalismCoverage_elseIfConditionShouldMatch() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'UpdatedVehicleValue' => 14000
        };
        String formula = 'if(UpdatedVehicleValue > 20000) { "Premium" } else if(UpdatedVehicleValue > 13000) { "Standard" } else { "Basic" }';
        String result = vandalismCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Standard', result);
    }

    @isTest
    static void vandalismCoverage_elseConditionShouldMatch() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'UpdatedVehicleValue' => 12000
        };
        String formula = 'if(UpdatedVehicleValue > 20000) { "Premium" } else if(UpdatedVehicleValue > 15000) { "Standard" } else { "Basic" }';
        String result = vandalismCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Basic', result);
    }

    @isTest
    static void vandalismCoverage_nestedIfElseBlockShouldEvaluateCorrectly() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'UpdatedVehicleValue' => 8000,
            'Region' => 'Urban'
        };
        String formula = 'if(UpdatedVehicleValue > 10000) { "High" } else { if(Region == "Urban") { "Covered in Urban" } else { "Not Covered" } }';
        String result = vandalismCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Covered in Urban', result);
    }

    @isTest
    static void vandalismCoverage_concatenatedStringShouldEvaluateCorrectly() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'UpdatedVehicleValue' => 30000,
            'Country' => 'Mexico'
        };
        String formula = 'if(UpdatedVehicleValue > 20000) { "Vandalism protection for " + Country }';
        String result = vandalismCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Vandalism protection for Mexico', result);
    }

    @isTest
    static void vandalismCoverage_conditionFailsDueToMissingField() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'SomeOtherField' => 5000
        };
        String formula = 'if(UpdatedVehicleValue > 5000) { "Yes" } else { "No" }';
        String result = vandalismCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('No', result); // field missing = null = false
    }

    @isTest
    static void vandalismCoverage_ifConditionOnlyWithoutElseReturnsEmpty() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'UpdatedVehicleValue' => 4000
        };
        String formula = 'if(UpdatedVehicleValue > 10000) { "High" }';
        String result = vandalismCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('', result); // No else and condition false
    }

 @isTest
    static void glassCoverage_ifConditionTrue_shouldReturnExpectedValue() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'Days' => 10
        };
        String formula = 'if(Days > 5) { "Glass Covered" }';
        String result = glassCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Glass Covered', result);
    }

    @isTest
    static void glassCoverage_ifElse_shouldReturnElseValue() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'Days' => 3
        };
        String formula = 'if(Days > 5) { "Glass Covered" } else { "Glass Not Covered" }';
        String result = glassCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Glass Not Covered', result);
    }


    @isTest
    static void glassCoverage_elseIf_shouldReturnCorrectValue() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'Days' => 6
        };
        String formula = 'if(Days > 10) { "Full" } else if(Days > 5) { "Partial" } else { "None" }';
        String result = glassCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Partial', result);
    }

    @isTest
    static void glassCoverage_elseBlockOnly_shouldReturnBasic() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'Days' => 2
        };
        String formula = 'if(Days > 10) { "Full" } else if(Days > 5) { "Partial" } else { "Basic" }';
        String result = glassCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Basic', result);
    }

    @isTest
    static void glassCoverage_nestedIfElse_shouldReturnNestedValue() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'Days' => 4,
            'Region' => 'Urban'
        };
        String formula = 'if(Days > 10) { "Full" } else { if(Region == "Urban") { "Urban Basic" } else { "Rural Basic" } }';
        String result = glassCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Urban Basic', result);
    }

    @isTest
    static void glassCoverage_concatenationInBlock_shouldEvaluate() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'Days' => 20,
            'Country' => 'Mexico'
        };
        String formula = 'if(Days > 10) { "Covered in " + Country }';
        String result = glassCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Covered in Mexico', result);
    }

    @isTest
    static void glassCoverage_missingField_shouldReturnElse() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'AnotherField' => 10
        };
        String formula = 'if(Days > 10) { "Yes" } else { "No" }';
        String result = glassCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('No', result); // Days is missing, condition will be false
    }

    @isTest
    static void glassCoverage_noElseProvided_shouldReturnEmptyString() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'Days' => 2
        };
        String formula = 'if(Days > 10) { "High" }';
        String result = glassCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('', result); // No match and no else, return empty
    }

    @isTest
    static void glassCoverage_multipleConditionsAndBlocks() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'Days' => 15,
            'Policy' => 'Standard'
        };
        String formula = 'if(Days > 30) { "Full Glass" } else if(Policy == "Standard") { "Standard Glass" } else { "No Glass" }';
        String result = glassCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Standard Glass', result);
    }

 @isTest
    static void roadsideAssistanceCoverage_ifConditionTrue_shouldReturnExpectedValue() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'VehicleAge' => 3
        };
        String formula = 'if(VehicleAge < 5) { "Roadside Included" }';
        String result = roadsideAssistanceCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Roadside Included', result);
    }

    @isTest
    static void roadsideAssistanceCoverage_ifElse_shouldReturnElseValue() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'VehicleAge' => 7
        };
        String formula = 'if(VehicleAge < 5) { "Included" } else { "Not Included" }';
        String result = roadsideAssistanceCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Not Included', result);
    }

    @isTest
    static void roadsideAssistanceCoverage_elseIf_shouldEvaluateCorrectBlock() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'VehicleAge' => 6
        };
        String formula = 'if(VehicleAge < 3) { "Full" } else if(VehicleAge < 7) { "Partial" } else { "None" }';
        String result = roadsideAssistanceCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Partial', result);
    }

    @isTest
    static void roadsideAssistanceCoverage_elseOnly_shouldBeReturnedWhenAllConditionsFalse() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'VehicleAge' => 9
        };
        String formula = 'if(VehicleAge < 3) { "Full" } else if(VehicleAge < 5) { "Partial" } else { "None" }';
        String result = roadsideAssistanceCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('None', result);
    }

    @isTest
    static void roadsideAssistanceCoverage_nestedIfElse_shouldReturnNestedMatch() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'VehicleAge' => 8,
            'Region' => 'Urban'
        };
        String formula = 'if(VehicleAge < 5) { "Full" } else { if(Region == "Urban") { "Urban Coverage" } else { "Rural Coverage" } }';
        String result = roadsideAssistanceCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Urban Coverage', result);
    }

    @isTest
    static void roadsideAssistanceCoverage_concatenationInBlock_shouldEvaluateCorrectly() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'VehicleAge' => 3,
            'Plan' => 'Gold'
        };
        String formula = 'if(VehicleAge < 5) { "Roadside Plan: " + Plan }';
        String result = roadsideAssistanceCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Roadside Plan: Gold', result);
    }

    @isTest
    static void roadsideAssistanceCoverage_fieldMissing_shouldReturnElseBlock() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'Year' => 2020
        };
        String formula = 'if(VehicleAge < 5) { "Eligible" } else { "Ineligible" }';
        String result = roadsideAssistanceCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Ineligible', result); // VehicleAge missing, condition false
    }

    @isTest
    static void roadsideAssistanceCoverage_ifOnlyWithoutElse_shouldReturnEmptyWhenFalse() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'VehicleAge' => 9
        };
        String formula = 'if(VehicleAge < 5) { "Roadside" }';
        String result = roadsideAssistanceCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('', result);
    }

    @isTest
    static void roadsideAssistanceCoverage_multipleConditions_shouldEvaluateProperBranch() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'VehicleAge' => 10,
            'Country' => 'Mexico'
        };
        String formula = 'if(VehicleAge < 5) { "Young Vehicle" } else if(Country == "Mexico") { "Older Vehicle in Mexico" } else { "Default" }';
        String result = roadsideAssistanceCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Older Vehicle in Mexico', result);
    }

 @isTest
    static void towingBenefitCoverage_ifConditionTrue_shouldReturnExpectedValue() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'VehicleAge' => 2
        };
        String formula = 'if(VehicleAge < 5) { "Towing Eligible" }';
        String result = towingBenefitCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Towing Eligible', result);
    }

    @isTest
    static void towingBenefitCoverage_ifElse_shouldReturnElseValue() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'VehicleAge' => 8
        };
        String formula = 'if(VehicleAge < 5) { "Eligible" } else { "Not Eligible" }';
        String result = towingBenefitCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Not Eligible', result);
    }

    @isTest
    static void towingBenefitCoverage_elseIf_shouldEvaluateCorrectBlock() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'VehicleAge' => 6
        };
        String formula = 'if(VehicleAge < 3) { "Full Towing" } else if(VehicleAge < 7) { "Limited Towing" } else { "No Towing" }';
        String result = towingBenefitCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Limited Towing', result);
    }

    @isTest
    static void towingBenefitCoverage_elseBlock_shouldBeEvaluatedWhenNoConditionsMatch() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'VehicleAge' => 10
        };
        String formula = 'if(VehicleAge < 3) { "Full" } else if(VehicleAge < 6) { "Partial" } else { "None" }';
        String result = towingBenefitCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('None', result);
    }

    @isTest
    static void towingBenefitCoverage_nestedIfElse_shouldEvaluateNestedLogic() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'VehicleAge' => 8,
            'Region' => 'Highway'
        };
        String formula = 'if(VehicleAge < 5) { "Covered" } else { if(Region == "Highway") { "Highway Towing" } else { "City Towing" } }';
        String result = towingBenefitCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Highway Towing', result);
    }

    @isTest
    static void towingBenefitCoverage_concatenatedBlock_shouldCombineStringAndVariable() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'VehicleAge' => 4,
            'Plan' => 'Silver'
        };
        String formula = 'if(VehicleAge < 5) { "Plan Type: " + Plan }';
        String result = towingBenefitCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Plan Type: Silver', result);
    }

    @isTest
    static void towingBenefitCoverage_missingField_shouldReturnElseBlock() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'Make' => 'Toyota'
        };
        String formula = 'if(VehicleAge < 5) { "Eligible" } else { "Not Eligible" }';
        String result = towingBenefitCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Not Eligible', result); // VehicleAge is missing, condition evaluates as false
    }

    @isTest
    static void towingBenefitCoverage_ifWithoutElseAndFalseCondition_shouldReturnEmptyString() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'VehicleAge' => 12
        };
        String formula = 'if(VehicleAge < 5) { "Eligible" }';
        String result = towingBenefitCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('', result);
    }

    @isTest
    static void towingBenefitCoverage_multipleConditions_shouldMatchCorrectBranch() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'VehicleAge' => 10,
            'Country' => 'USA'
        };
        String formula = 'if(VehicleAge < 5) { "Low Age" } else if(Country == "USA") { "Towing USA Plan" } else { "Default" }';
        String result = towingBenefitCoverage.evaluateFormula(formula, dataMap);
        System.assertEquals('Towing USA Plan', result);
    }


    @isTest
    static void LiabilityCoverageDetails_evaluateFormula_ifConditionTrue() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'Liability' => 100000
        };
        String formula = 'IF(Liability == 100000) { return "Covered" } ELSE { return "Not Covered" }';
        String result = LiabilityCoverageDetails.evaluateFormula(formula, dataMap);
        System.assertEquals('Covered', result);
    }

    @isTest
    static void LiabilityCoverageDetails_evaluateFormula_ifConditionFalse() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'Liability' => 50000
        };
        String formula = 'IF(Liability == 100000) { return "Covered" } ELSE { return "Not Covered" }';
        String result = LiabilityCoverageDetails.evaluateFormula(formula, dataMap);
    }

    @isTest
    static void LiabilityCoverageDetails_evaluateFormula_directReturnStatement() {
        Map<String, Object> dataMap = new Map<String, Object>();
        String formula = 'return "Standard Coverage"';
        String result = LiabilityCoverageDetails.evaluateFormula(formula, dataMap);
        System.assertEquals('Standard Coverage', result);
    }

    @isTest
    static void LiabilityCoverageDetails_evaluateFormula_plainString() {
        Map<String, Object> dataMap = new Map<String, Object>();
        String formula = 'Manual Coverage';
        String result = LiabilityCoverageDetails.evaluateFormula(formula, dataMap);
        System.assertEquals('Manual Coverage', result);
    }

    @isTest
    static void LiabilityCoverageDetails_evaluateSimpleFormula_variableReplacement() {
        Map<String, Object> dataMap = new Map<String, Object>{
            'Liability' => 200000,
            'Days' => 180
        };
        String formula = '"Coverage: " + Liability + " for " + Days + " days"';
        String result = LiabilityCoverageDetails.evaluateSimpleFormula(formula, dataMap);
        System.assertEquals('Coverage: 200000 for 180 days', result);
    }

    @isTest
    static void LiabilityCoverageDetails_evaluateStringConcatenation_validJoin() {
        String formula = '"Level: " + "High" + " Priority"';
        String result = LiabilityCoverageDetails.evaluateStringConcatenation(formula);
        System.assertEquals('Level: High Priority', result);
    }

    @isTest
    static void LiabilityCoverageDetails_extractReturnValue_valid() {
        String formula = 'return "Full Coverage Benefit"';
        String result = LiabilityCoverageDetails.extractReturnValue(formula);
        System.assertEquals('Full Coverage Benefit', result);
    }

    
}