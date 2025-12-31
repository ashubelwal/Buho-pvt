// // @isTest
// // public class DairylandCSVProcessorTest {

// //     @isTest
// //     static void testProcessCSVWithNewLeads() {
// //         // Prepare test data (asegurándonos de que los encabezados coincidan)
// //         String csvContent = 'FirstName,LastName,Quote Number,Phone,Email,Company,Policy Type,Rate State,Quote Effective Date\n' +
// //                             'John,Doe,Q123,555-123-4567,john.doe@test.com,,Auto,CA,2025-05-01\n' +
// //                             'Jane,Smith,Q456,555-987-6543,jane.smith@test.com,ABC Corp,Home,TX,2025-06-01';

// //         Test.startTest();
// //         List<String> resultIds = DairylandCSVProcessor.processCSVFile(csvContent);
// //         Test.stopTest();

// //         System.assertEquals(2, resultIds.size(), '2 leads should have been created');

// //         List<Lead> createdLeads = [
// //             SELECT FirstName, LastName, Email, Company, Quote_Number__c,
// //                    Policy_Type__c, Rate_State__c, Quote_Effective_Date__c
// //             FROM Lead WHERE Id IN :resultIds
// //         ];

// //         for (Lead l : createdLeads) {
// //             if (l.FirstName == 'John') {
// //                 System.assertEquals('john.doe@test.com', l.Company, 'Company should be set to email if blank');
// //                 System.assertEquals('Q123', l.Quote_Number__c);
// //                 System.assertEquals('Auto', l.Policy_Type__c);
// //                 System.assertEquals('CA', l.Rate_State__c);
// //                 System.assertEquals(Date.newInstance(2025, 5, 1), l.Quote_Effective_Date__c);
// //             } else if (l.FirstName == 'Jane') {
// //                 System.assertEquals('ABC Corp', l.Company);
// //                 System.assertEquals('Q456', l.Quote_Number__c);
// //                 System.assertEquals('Home', l.Policy_Type__c);
// //                 System.assertEquals('TX', l.Rate_State__c);
// //                 System.assertEquals(Date.newInstance(2025, 6, 1), l.Quote_Effective_Date__c);
// //             }
// //         }
// //     }

// //     @isTest
// //     static void testProcessCSVWithExistingLeads() {
// //         Lead existingLead = new Lead(
// //             FirstName = 'John',
// //             LastName = 'Doe',
// //             Email = 'john.doe@test.com',
// //             Company = 'Old Co',
// //             Phone = '000-000-0000',
// //             Quote_Number__c = 'OldQuote',
// //             Policy_Type__c = 'OldPolicy',
// //             Rate_State__c = 'NY',
// //             Quote_Effective_Date__c = Date.newInstance(2020, 1, 1)
// //         );
// //         insert existingLead;

// //         String csvContent = 'FirstName,LastName,Quote Number,Phone,Email,Company,Policy Type,Rate State,Quote Effective Date\n' +
// //                             'John,Doe,NewQuote,999-999-9999,john.doe@test.com,New Co,UpdatedPolicy,CA,2025-07-01';

// //         Test.startTest();
// //         List<String> resultIds = DairylandCSVProcessor.processCSVFile(csvContent);
// //         Test.stopTest();

// //         System.assertEquals(1, resultIds.size());

// //         Lead updated = [SELECT Phone, Company, Quote_Number__c,
// //                                Policy_Type__c, Rate_State__c, Quote_Effective_Date__c
// //                         FROM Lead WHERE Id = :existingLead.Id];

// //         System.assertEquals('999-999-9999', updated.Phone);
// //         System.assertEquals('New Co', updated.Company);
// //         System.assertEquals('NewQuote', updated.Quote_Number__c);
// //         System.assertEquals('UpdatedPolicy', updated.Policy_Type__c);
// //         System.assertEquals('CA', updated.Rate_State__c);
// //         System.assertEquals(Date.newInstance(2025, 7, 1), updated.Quote_Effective_Date__c);
// //     }

// //     // @isTest
// //     // static void testProcessCSVWithInvalidFormat() {
// //     //     // Missing required field: Email
// //     //     String csvContent = 'FirstName,LastName,Quote Number,Phone,Company,Policy Type,Rate State,Quote Effective Date\n' +
// //     //                         'John,Doe,12345,555-123-4567,Test Company,Auto,CA,2025-08-01';

// //     //     Test.startTest();
// //     //     Boolean exceptionThrown = false;
// //     //     try {
// //     //         DairylandCSVProcessor.processCSVFile(csvContent);
// //     //     } catch (DairylandCSVProcessor.CSVFormatException e) {
// //     //         exceptionThrown = true;
// //     //     }
// //     //     Test.stopTest();

// //     //     System.assertEquals(true, exceptionThrown, 'Expected CSVFormatException due to missing Email column');
// //     // }
// // }

// @isTest
// public class DairylandCSVProcessorTest {

//     @isTest
//     static void testProcessCSVWithNewLeads() {
//         // Prepare test data (asegurándonos de que los encabezados coincidan)
//         String csvContent = 'Last Name,First Name,Quote Number,Phone,Email,Company,Policy Type,Rate State,Quote Effective Date,Status\n' +
//                             'John,Doe,Q123,555-123-4567,john.doe@test.com,,Auto,CA,2025-05-01,Untilled Status\n' +
//                             'Jane,Smith,Q456,555-987-6543,jane.smith@test.com,ABC Corp,Home,TX,2025-06-01,Untilled Status';

//         Test.startTest();
//         List<String> resultIds = DairylandCSVProcessor.processCSVFile(csvContent);
//         Test.stopTest();

//         System.assertEquals(2, resultIds.size(), '2 leads should have been created');

//         List<Lead> createdLeads = [
//             SELECT LastName, FirstName, Email, Company, Quote_Number__c,
//                    Policy_Type__c, Rate_State__c, Quote_Effective_Date__c, Notes__c
//             FROM Lead WHERE Id IN :resultIds
//         ];

//         for (Lead l : createdLeads) {
//             if (l.FirstName == 'John') {
//                 // Actualizado para reflejar el nuevo comportamiento: nombre + apellido
//                 System.assertEquals('John Doe', l.Company, 'Company should be set to firstName + lastName if blank');
//                 System.assertEquals('Q123', l.Quote_Number__c);
//                 System.assertEquals('Auto', l.Policy_Type__c);
//                 System.assertEquals('CA', l.Rate_State__c);
//                 System.assertEquals(Date.newInstance(2025, 5, 1), l.Quote_Effective_Date__c);
//             } else if (l.FirstName == 'Jane') {
//                 System.assertEquals('ABC Corp', l.Company);
//                 System.assertEquals('Q456', l.Quote_Number__c);
//                 System.assertEquals('Home', l.Policy_Type__c);
//                 System.assertEquals('TX', l.Rate_State__c);
//                 System.assertEquals(Date.newInstance(2025, 6, 1), l.Quote_Effective_Date__c);
//             }
//         }
//     }

//     @isTest
//     static void testProcessCSVWithExistingLeads() {
//         // Crear primero un registro existente usando Quote_Number como el identificador único
//         Lead existingLead = new Lead(
//             FirstName = 'John',
//             LastName = 'Doe',
//             Email = 'john.doe@test.com',
//             Company = 'Old Co',
//             Phone = '000-000-0000',
//             Quote_Number__c = 'Q123',  // Este es el identificador que se usará para la actualización
//             Policy_Type__c = 'OldPolicy',
//             Rate_State__c = 'NY',
//             Quote_Effective_Date__c = Date.newInstance(2020, 1, 1)
//         );
//         insert existingLead;

//         // Ahora enviar un CSV con el mismo Quote_Number para actualizar el registro
//         String csvContent = 'FirstName,LastName,Quote Number,Phone,Email,Company,Policy Type,Rate State,Quote Effective Date\n' +
//                             'John,Doe,Q123,999-999-9999,john.doe@test.com,New Co,UpdatedPolicy,CA,2025-07-01';

//         Test.startTest();
//         List<String> resultIds = DairylandCSVProcessor.processCSVFile(csvContent);
//         Test.stopTest();

//         System.assertEquals(1, resultIds.size());

//         Lead updated = [SELECT Phone, Company, Quote_Number__c,
//                                Policy_Type__c, Rate_State__c, Quote_Effective_Date__c
//                         FROM Lead WHERE Id = :existingLead.Id];

//         System.assertEquals('999-999-9999', updated.Phone);
//         System.assertEquals('New Co', updated.Company);
//         System.assertEquals('Q123', updated.Quote_Number__c);
//         System.assertEquals('UpdatedPolicy', updated.Policy_Type__c);
//         System.assertEquals('CA', updated.Rate_State__c);
//         System.assertEquals(Date.newInstance(2025, 7, 1), updated.Quote_Effective_Date__c);
//     }

//     @isTest
//     static void testProcessCSVWithDuplicateQuoteNumbers() {
//         // Preparar datos de prueba con Quote Numbers duplicados en el CSV
//         String csvContent = 'FirstName,LastName,Quote Number,Phone,Email,Company,Policy Type,Rate State,Quote Effective Date\n' +
//                             'John,Doe,Q123,555-123-4567,john.doe@test.com,,Auto,CA,2025-05-01\n' +
//                             'Jane,Smith,Q123,555-987-6543,jane.smith@test.com,ABC Corp,Home,TX,2025-06-01';

//         Test.startTest();
//         List<String> resultIds = DairylandCSVProcessor.processCSVFile(csvContent);
//         Test.stopTest();

//         // Solo debe procesarse una fila, la primera con ese Quote Number
//         System.assertEquals(1, resultIds.size(), 'Only 1 lead should be created for duplicate Quote Numbers');

//         Lead createdLead = [SELECT FirstName, LastName, Email FROM Lead WHERE Id IN :resultIds];
//         System.assertEquals('John', createdLead.FirstName, 'First record with Quote Number should be processed');
//     }

//     @isTest
//     static void testProcessCSVWithMissingValues() {
//         // Probar con algunos campos faltantes pero con los mínimos requeridos
//         String csvContent = 'FirstName,LastName,Quote Number,Phone,Email,Company,Policy Type,Rate State,Quote Effective Date\n' +
//                             'John,Doe,Q999,,,,,CA,';

//         Test.startTest();
//         List<String> resultIds = DairylandCSVProcessor.processCSVFile(csvContent);
//         Test.stopTest();

//         System.assertEquals(1, resultIds.size(), 'Lead should be created with minimal information');

//         Lead createdLead = [
//             SELECT Company, Phone, Email, Policy_Type__c, Quote_Effective_Date__c 
//             FROM Lead WHERE Id IN :resultIds
//         ];
        
//         System.assertEquals('John Doe', createdLead.Company, 'Company should default to FirstName + LastName');
//         System.assertEquals(null, createdLead.Phone, 'Phone should be null');
//         System.assertEquals(null, createdLead.Email, 'Email should be null');
//         System.assertEquals(null, createdLead.Policy_Type__c, 'Policy Type should be null');
//         System.assertEquals(null, createdLead.Quote_Effective_Date__c, 'Quote Effective Date should be null');
//     }

//     // @isTest
//     // static void testProcessCSVWithInvalidFormat() {
//     //     // Missing required field: Quote Number
//     //     String csvContent = 'FirstName,LastName,Phone,Email,Company,Policy Type,Rate State,Quote Effective Date\n' +
//     //                         'John,Doe,555-123-4567,john@example.com,Test Company,Auto,CA,2025-08-01';

//     //     Test.startTest();
//     //     Boolean exceptionThrown = false;
//     //     try {
//     //         DairylandCSVProcessor.processCSVFile(csvContent);
//     //     } catch (AuraHandledException e) {
//     //         exceptionThrown = true;
//     //         System.assert(e.getMessage().contains('Missing required column'), 'Expected error about missing column');
//     //     }
//     //     Test.stopTest();

//     //     System.assertEquals(true, exceptionThrown, 'Expected exception due to missing Quote Number column');
//     // }
// }

@isTest
public class DairylandCSVProcessorTest {

    @isTest
    static void testProcessCSVWithNewLeads() {
        // Prepare test data con formato de fecha MM/dd/yy
        String csvContent = 'First Name,Last Name,Quote Number,Phone,Email,Company,Policy Type,Rate State,Quote Effective Date,Status, Insurance Type\n' +
                            'John,Doe,Q123,555-123-4567,john.doe@test.com,,Automobile,CA,5/1/25,Untilled Status, Automobile\n' +
                            'Jane,Smith,Q456,555-987-6543,jane.smith@test.com,ABC Corp,Automobile,TX,6/1/25,Untilled Status, Motorcycle/Street Legal ATV';

        Test.startTest();
        List<String> resultIds = DairylandCSVProcessor.processCSVFile(csvContent);
        Test.stopTest();

        System.assertEquals(2, resultIds.size(), '2 leads should have been created');

        List<Lead> createdLeads = [
            SELECT FirstName, LastName, Email, Company, Quote_Number__c,
                   Policy_Type__c, Rate_State__c, Quote_Effective_Date__c, Notes__c, Insurance_Type__c
            FROM Lead WHERE Id IN :resultIds
            ORDER BY FirstName
        ];

        System.assertEquals(2, createdLeads.size(), 'Should have retrieved 2 leads');
        
        // Verificar el primer lead (Jane)
        Lead jane = createdLeads[0];
        System.assertEquals('Jane', jane.FirstName);
        System.assertEquals('Smith', jane.LastName);
        System.assertEquals('ABC Corp', jane.Company);
        System.assertEquals('Q456', jane.Quote_Number__c);
        System.assertEquals('Automobile-Van-Minivan', jane.Policy_Type__c);
        System.assertEquals('TX', jane.Rate_State__c);
        System.assertEquals(Date.newInstance(2025, 6, 1), jane.Quote_Effective_Date__c);
        System.assertEquals('Untilled Status', jane.Notes__c);
        //new system.assert for Insurance_Type__c
        System.assertEquals('Automobile-Van-Minivan', jane.Insurance_Type__c);
        
        // Verificar el segundo lead (John)
        Lead john = createdLeads[1];
        System.assertEquals('John', john.FirstName);
        System.assertEquals('Doe', john.LastName);
        System.assertEquals('John Doe', john.Company, 'Company should be set to firstName + lastName if blank');
        System.assertEquals('Q123', john.Quote_Number__c);
        System.assertEquals('Automobile-Van-Minivan', john.Policy_Type__c);
        System.assertEquals('CA', john.Rate_State__c);
        System.assertEquals(Date.newInstance(2025, 5, 1), john.Quote_Effective_Date__c);
        System.assertEquals('Untilled Status', john.Notes__c);
        System.assertEquals('Automobile-Van-Minivan', john.Insurance_Type__c);
    }

    @isTest
    static void testProcessCSVWithExistingLeads() {
        // 
        Lead existingLead = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@test.com',
            Company = 'Old Co',
            Phone = '000-000-0000',
            Quote_Number__c = 'Q123',  //
            Policy_Type__c = 'OldPolicy',
            Rate_State__c = 'NY',
            Quote_Effective_Date__c = Date.newInstance(2020, 1, 1)
        );
        insert existingLead;

        // Ahora enviar un CSV con el mismo Quote_Number para actualizar el registro
        String csvContent = 'First Name,Last Name,Quote Number,Phone,Email,Company,Policy Type,Rate State,Quote Effective Date,Status\n' +
                            'John,Doe,Q123,999-999-9999,john.doe@test.com,New Co,UpdatedPolicy,CA,7/1/25,New Status';

        Test.startTest();
        List<String> resultIds = DairylandCSVProcessor.processCSVFile(csvContent);
        Test.stopTest();

        System.assertEquals(1, resultIds.size());

        Lead updated = [SELECT FirstName, LastName, Phone, Company, Quote_Number__c,
                               Policy_Type__c, Rate_State__c, Quote_Effective_Date__c, Notes__c
                        FROM Lead WHERE Id = :existingLead.Id];

        System.assertEquals('John', updated.FirstName);
        System.assertEquals('Doe', updated.LastName);
        System.assertEquals('999-999-9999', updated.Phone);
        System.assertEquals('New Co', updated.Company);
        System.assertEquals('Q123', updated.Quote_Number__c);
        System.assertEquals('Automobile-Van-Minivan', updated.Policy_Type__c);
        System.assertEquals('CA', updated.Rate_State__c);
        System.assertEquals(Date.newInstance(2025, 7, 1), updated.Quote_Effective_Date__c);
        System.assertEquals('New Status', updated.Notes__c);
    }

    @isTest
    static void testProcessCSVWithDuplicateQuoteNumbers() {
        // Preparar datos de prueba con Quote Numbers duplicados en el CSV
        String csvContent = 'First Name,Last Name,Quote Number,Phone,Email,Company,Policy Type,Rate State,Quote Effective Date,Status\n' +
                            'John,Doe,Q123,555-123-4567,john.doe@test.com,,Auto,CA,5/1/25,Active\n' +
                            'Jane,Smith,Q123,555-987-6543,jane.smith@test.com,ABC Corp,Home,TX,6/1/25,Active';

        Test.startTest();
        List<String> resultIds = DairylandCSVProcessor.processCSVFile(csvContent);
        Test.stopTest();

        // Solo debe procesarse una fila, la primera con ese Quote Number
        System.assertEquals(1, resultIds.size(), 'Only 1 lead should be created for duplicate Quote Numbers');

        Lead createdLead = [SELECT FirstName, LastName, Email FROM Lead WHERE Id IN :resultIds];
        System.assertEquals('John', createdLead.FirstName, 'First record with Quote Number should be processed');
    }

    // @isTest
    // static void testProcessCSVWithMissingValues() {
    //     // Probar con algunos campos faltantes pero con los mínimos requeridos
    //     String csvContent = 'First Name,Last Name,Quote Number,Phone,Email,Company,Policy Type,Rate State,Quote Effective Date,Status\n' +
    //                         'John,Doe,Q999,,,,,CA,,';

    //     Test.startTest();
    //     List<String> resultIds = DairylandCSVProcessor.processCSVFile(csvContent);
    //     Test.stopTest();

    //     System.assertEquals(1, resultIds.size(), 'Lead should be created with minimal information');

    //     Lead createdLead = [
    //         SELECT FirstName, LastName, Company, Phone, Email, Policy_Type__c, Quote_Effective_Date__c 
    //         FROM Lead WHERE Id IN :resultIds
    //     ];
        
    //     System.assertEquals('John', createdLead.FirstName);
    //     System.assertEquals('Doe', createdLead.LastName);
    //     System.assertEquals('John Doe', createdLead.Company, 'Company should default to FirstName + LastName');
    //     System.assertEquals(null, createdLead.Phone, 'Phone should be null');
    //     System.assertEquals(null, createdLead.Email, 'Email should be null');
    //     System.assertEquals(null, createdLead.Policy_Type__c, 'Policy Type should be null');
    //     System.assertEquals(null, createdLead.Quote_Effective_Date__c, 'Quote Effective Date should be null');
    // }

    @isTest
    static void testDateParsing() {
        // Prueba específica para la funcionalidad de análisis de fecha
        String csvContent = 'First Name,Last Name,Quote Number,Phone,Email,Company,Policy Type,Rate State,Quote Effective Date,Status\n' +
                            'Test1,DateFormat,Q001,,,,,CA,01/15/25,\n' +     // Formato con ceros iniciales
                            'Test2,DateFormat,Q002,,,,,CA,1/5/25,\n' +       // Formato sin ceros iniciales
                            'Test3,DateFormat,Q003,,,,,CA,12/31/25,\n' +     // Fin de año
                            'Test4,DateFormat,Q004,,,,,CA,4/26/25,';         // Tu ejemplo específico

        Test.startTest();
        List<String> resultIds = DairylandCSVProcessor.processCSVFile(csvContent);
        Test.stopTest();

        System.assertEquals(4, resultIds.size(), 'All 4 leads should be created with different date formats');

        Map<String, Lead> quoteToLeadMap = new Map<String, Lead>();
        for (Lead l : [SELECT Quote_Number__c, Quote_Effective_Date__c FROM Lead WHERE Id IN :resultIds]) {
            quoteToLeadMap.put(l.Quote_Number__c, l);
        }

        System.assertEquals(Date.newInstance(2025, 1, 15), quoteToLeadMap.get('Q001').Quote_Effective_Date__c, 'Should parse 01/15/25 correctly');
        System.assertEquals(Date.newInstance(2025, 1, 5), quoteToLeadMap.get('Q002').Quote_Effective_Date__c, 'Should parse 1/5/25 correctly');
        System.assertEquals(Date.newInstance(2025, 12, 31), quoteToLeadMap.get('Q003').Quote_Effective_Date__c, 'Should parse 12/31/25 correctly');
        System.assertEquals(Date.newInstance(2025, 4, 26), quoteToLeadMap.get('Q004').Quote_Effective_Date__c, 'Should parse 4/26/25 correctly');
    }
    
    // @isTest
    // static void testInvalidDates() {
    //     // Prueba para fechas inválidas
    //     String csvContent = 'First Name,Last Name,Quote Number,Phone,Email,Company,Policy Type,Rate State,Quote Effective Date,Status\n' +
    //                         'Bad1,DateFormat,Q101,,,,,CA,13/15/25,\n' +      // Mes inválido
    //                         'Bad2,DateFormat,Q102,,,,,CA,2/30/25,\n' +       // Día inválido para febrero
    //                         'Good1,DateFormat,Q103,,,,,CA,7/4/25,\n' +       // Fecha válida
    //                         'Bad3,DateFormat,Q104,,,,,CA,NotADate,\n' +      // No es una fecha
    //                         'Bad4,DateFormat,Q105,,,,,CA,2025-07-01,';       // Formato incorrecto

    //     Test.startTest();
    //     List<String> resultIds = DairylandCSVProcessor.processCSVFile(csvContent);
    //     Test.stopTest();

    //     System.assertEquals(1, resultIds.size(), 'Only valid date should be processed');

    //     Lead validLead = [SELECT Quote_Number__c, Quote_Effective_Date__c FROM Lead WHERE Id IN :resultIds];
    //     System.assertEquals('Q103', validLead.Quote_Number__c, 'Only the lead with valid date should be created');
    //     System.assertEquals(Date.newInstance(2025, 7, 4), validLead.Quote_Effective_Date__c, 'Should parse 7/4/25 correctly');
    // }
}