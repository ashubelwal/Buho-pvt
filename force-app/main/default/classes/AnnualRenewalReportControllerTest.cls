@isTest
public class AnnualRenewalReportControllerTest {
    
    @TestSetup
    static void setupData() {
        // Desactivar trigger
        TriggerSwitch__c ts = new TriggerSwitch__c(Name = 'PolicyTrigger', Active__c = false);
        insert ts;
        
        Integer currentYear = Date.today().year();
        Integer nextYear = currentYear + 1;
        
        // Crear políticas que expiran en el año actual (para target renewal)
        List<Policy__c> policiesCurrentYear = new List<Policy__c>();
        
        // Políticas que expiran en diferentes meses del año actual - Term Annual
        for (Integer i = 0; i < 2; i++) {
            policiesCurrentYear.add(new Policy__c(
                Name = 'Policy Jan ' + currentYear + ' ' + i,
                End_Date__c = Date.newInstance(currentYear, 1, 15 + i),
                Term__c = 'Annual'
            ));
        }
        
        policiesCurrentYear.add(new Policy__c(
            Name = 'Policy Feb ' + currentYear,
            End_Date__c = Date.newInstance(currentYear, 2, 20),
            Term__c = 'Annual'
        ));
        
        policiesCurrentYear.add(new Policy__c(
            Name = 'Policy Mar ' + currentYear,
            End_Date__c = Date.newInstance(currentYear, 3, 10),
            Term__c = 'Annual'
        ));
        
        // Política con Term diferente (no debería contar para target)
        policiesCurrentYear.add(new Policy__c(
            Name = 'Policy Monthly ' + currentYear,
            End_Date__c = Date.newInstance(currentYear, 4, 15),
            Term__c = 'Monthly'
        ));
        
        insert policiesCurrentYear;
        
        // Políticas creadas en el año actual para los renewals (Term Annual)
        List<Policy__c> renewalPolicies = new List<Policy__c>();
        
        for (Integer i = 0; i < 2; i++) {
            renewalPolicies.add(new Policy__c(
                Name = 'Renewal Policy Jan ' + currentYear + ' ' + i,
                Term__c = 'Annual'
            ));
        }
        
        renewalPolicies.add(new Policy__c(
            Name = 'Renewal Policy Feb ' + currentYear,
            Term__c = 'Annual'
        ));
        
        renewalPolicies.add(new Policy__c(
            Name = 'Renewal Policy Mar ' + currentYear,
            Term__c = 'Annual'
        ));
        
        // Política con Term Monthly (no debería contar)
        renewalPolicies.add(new Policy__c(
            Name = 'Renewal Policy Monthly ' + currentYear,
            Term__c = 'Monthly'
        ));
        
        insert renewalPolicies;
        
        // Establecer CreatedDate para las políticas de renewal
        Test.setCreatedDate(renewalPolicies[0].Id, DateTime.newInstance(currentYear, 1, 10, 10, 0, 0));
        Test.setCreatedDate(renewalPolicies[1].Id, DateTime.newInstance(currentYear, 1, 20, 16, 45, 0));
        Test.setCreatedDate(renewalPolicies[2].Id, DateTime.newInstance(currentYear, 2, 15, 14, 30, 0));
        Test.setCreatedDate(renewalPolicies[3].Id, DateTime.newInstance(currentYear, 3, 20, 9, 15, 0));
        Test.setCreatedDate(renewalPolicies[4].Id, DateTime.newInstance(currentYear, 4, 10, 12, 0, 0));
        
        // Crear vehículos para las diferentes categorías
        List<Vehicle__c> vehicles = new List<Vehicle__c>();
        
        // 1. Vehículos RENEWED - expiran en próximo año, status 'insured-renew-annual'
        vehicles.add(new Vehicle__c(
            Name = 'Vehicle Renewed 1',
            Vin__c = 'VIN_RENEWED_1',
            Policy_Expiration__c = Date.newInstance(nextYear, 6, 15),
            vehicle_coverage_status__c = 'insured-renew-annual',
            Policy__c = renewalPolicies[0].Id
        ));
        
        vehicles.add(new Vehicle__c(
            Name = 'Vehicle Renewed 2',
            Vin__c = 'VIN_RENEWED_2',
            Policy_Expiration__c = Date.newInstance(nextYear, 7, 15),
            vehicle_coverage_status__c = 'insured-renew-annual',
            Policy__c = renewalPolicies[2].Id
        ));
        
        vehicles.add(new Vehicle__c(
            Name = 'Vehicle Renewed 3',
            Vin__c = 'VIN_RENEWED_3',
            Policy_Expiration__c = Date.newInstance(nextYear, 8, 15),
            vehicle_coverage_status__c = 'insured-renew-annual',
            Policy__c = renewalPolicies[1].Id
        ));
        
        // 2. Vehículos INELIGIBLE - expiran en año actual, status 'uninsured', razones ineligibles
        vehicles.add(new Vehicle__c(
            Name = 'Vehicle Ineligible 1',
            Vin__c = 'VIN_INELIGIBLE_1',
            Policy_Expiration__c = Date.newInstance(currentYear, 1, 25),
            vehicle_coverage_status__c = 'uninsured',
            Uninsured_Reason__c = 'Transferred Ownership',
            Policy__c = policiesCurrentYear[0].Id
        ));
        
        vehicles.add(new Vehicle__c(
            Name = 'Vehicle Ineligible 2',
            Vin__c = 'VIN_INELIGIBLE_2',
            Policy_Expiration__c = Date.newInstance(currentYear, 2, 25),
            vehicle_coverage_status__c = 'uninsured',
            Uninsured_Reason__c = 'Destroyed',
            Policy__c = policiesCurrentYear[2].Id
        ));
        
        // 3. Vehículos PENDING - expiran en año actual, status 'uninsured', razones pending
        vehicles.add(new Vehicle__c(
            Name = 'Vehicle Pending 1',
            Vin__c = 'VIN_PENDING_1',
            Policy_Expiration__c = Date.newInstance(currentYear, 1, 28),
            vehicle_coverage_status__c = 'uninsured',
            Uninsured_Reason__c = 'Will Renew Later',
            Policy__c = policiesCurrentYear[1].Id
        ));
        
        vehicles.add(new Vehicle__c(
            Name = 'Vehicle Pending 2',
            Vin__c = 'VIN_PENDING_2',
            Policy_Expiration__c = Date.newInstance(currentYear, 3, 25),
            vehicle_coverage_status__c = 'uninsured',
            Uninsured_Reason__c = 'Unknown',
            Policy__c = policiesCurrentYear[3].Id
        ));
        
        // 4. Vehículos LOST - expiran en año actual, status 'uninsured', razones lost
        vehicles.add(new Vehicle__c(
            Name = 'Vehicle Lost 1',
            Vin__c = 'VIN_LOST_1',
            Policy_Expiration__c = Date.newInstance(currentYear, 2, 28),
            vehicle_coverage_status__c = 'uninsured',
            Uninsured_Reason__c = 'Insured Elsewhere',
            Policy__c = policiesCurrentYear[2].Id
        ));
        
        vehicles.add(new Vehicle__c(
            Name = 'Vehicle Lost 2',
            Vin__c = 'VIN_LOST_2',
            Policy_Expiration__c = Date.newInstance(currentYear, 3, 28),
            vehicle_coverage_status__c = 'uninsured',
            Uninsured_Reason__c = 'Lost',
            Policy__c = policiesCurrentYear[3].Id
        ));
        
        // 5. Vehículos que NO deben contar
        vehicles.add(new Vehicle__c(
            Name = 'Vehicle Wrong Status',
            Vin__c = 'VIN_WRONG_STATUS',
            Policy_Expiration__c = Date.newInstance(nextYear, 9, 15),
            vehicle_coverage_status__c = 'active',
            Policy__c = renewalPolicies[0].Id
        ));
        
        vehicles.add(new Vehicle__c(
            Name = 'Vehicle No Policy',
            Vin__c = 'VIN_NO_POLICY',
            Policy_Expiration__c = Date.newInstance(nextYear, 10, 15),
            vehicle_coverage_status__c = 'insured-renew-annual'
        ));
        
        vehicles.add(new Vehicle__c(
            Name = 'Vehicle Monthly Policy',
            Vin__c = 'VIN_MONTHLY',
            Policy_Expiration__c = Date.newInstance(nextYear, 11, 15),
            vehicle_coverage_status__c = 'insured-renew-annual',
            Policy__c = renewalPolicies[4].Id
        ));
        
        insert vehicles;
    }
    
    @isTest
    static void testGetAnnualRenewalReportPartial() {
        Test.startTest();
        List<AnnualRenewalReportController.RenewalRow> result = 
            AnnualRenewalReportController.getAnnualRenewalReportPartial();
        Test.stopTest();
        
        // Verificar que se retornan 13 filas (12 meses + 1 fila total)
        System.assertEquals(13, result.size(), 'Should return 12 months + 1 total row');
        
        // Los primeros 12 elementos deben ser los meses ordenados
        for (Integer i = 0; i < 12; i++) {
            System.assertEquals(i + 1, result[i].month, 'Months should be in order');
        }
        
        // El último elemento debe ser la fila total (month = null)
        System.assertEquals(null, result[12].month, 'Last row should be total row');
        
        // Verificar datos específicos por mes
        AnnualRenewalReportController.RenewalRow january = result[0];
        System.assertEquals(1, january.month);
        System.assertEquals(2, january.targetRenewal, 'January should have 2 target renewals');
        System.assertEquals(2, january.renewed, 'January should have 2 renewed');
        System.assertEquals(1, january.ineligible, 'January should have 1 ineligible');
        System.assertEquals(1, january.pending, 'January should have 1 pending');
        System.assertEquals(0, january.lost, 'January should have 0 lost');
        
        AnnualRenewalReportController.RenewalRow february = result[1];
        System.assertEquals(2, february.month);
        System.assertEquals(1, february.targetRenewal, 'February should have 1 target renewal');
        System.assertEquals(1, february.renewed, 'February should have 1 renewed');
        System.assertEquals(1, february.ineligible, 'February should have 1 ineligible');
        System.assertEquals(0, february.pending, 'February should have 0 pending');
        System.assertEquals(1, february.lost, 'February should have 1 lost');
        
        AnnualRenewalReportController.RenewalRow march = result[2];
        System.assertEquals(3, march.month);
        System.assertEquals(1, march.targetRenewal, 'March should have 1 target renewal');
        System.assertEquals(0, march.renewed, 'March should have 0 renewed');
        System.assertEquals(0, march.ineligible, 'March should have 0 ineligible');
        System.assertEquals(1, march.pending, 'March should have 1 pending');
        System.assertEquals(1, march.lost, 'March should have 1 lost');
        
        // Verificar fila total
        AnnualRenewalReportController.RenewalRow totalRow = result[12];
        System.assertEquals(4, totalRow.targetRenewal, 'Total target should be 4');
        System.assertEquals(3, totalRow.renewed, 'Total renewed should be 3');
        System.assertEquals(2, totalRow.ineligible, 'Total ineligible should be 2');
        System.assertEquals(2, totalRow.pending, 'Total pending should be 2');
        System.assertEquals(2, totalRow.lost, 'Total lost should be 2');
    }
    
    @isTest
    static void testRenewalRowCompareTo() {
        AnnualRenewalReportController.RenewalRow row1 = new AnnualRenewalReportController.RenewalRow();
        AnnualRenewalReportController.RenewalRow row2 = new AnnualRenewalReportController.RenewalRow();
        AnnualRenewalReportController.RenewalRow row3 = new AnnualRenewalReportController.RenewalRow();
        
        row1.month = 1;
        row2.month = 2;
        row3.month = null;
        
        // Test comparación normal
        System.assertEquals(-1, row1.compareTo(row2), 'Row1 should be less than Row2');
        System.assertEquals(1, row2.compareTo(row1), 'Row2 should be greater than Row1');
        System.assertEquals(0, row1.compareTo(row1), 'Row should be equal to itself');
        
        // Test con valores null
        System.assertEquals(1, row1.compareTo(row3), 'Non-null should be greater than null');
        System.assertEquals(-1, row3.compareTo(row1), 'Null should be less than non-null');
        
        AnnualRenewalReportController.RenewalRow row4 = new AnnualRenewalReportController.RenewalRow();
        row4.month = null;
        System.assertEquals(-1, row3.compareTo(row4), 'First null should return -1 when compared to second null');
    }
    
    @isTest
    static void testGetRenewedPct() {
        AnnualRenewalReportController.RenewalRow row = new AnnualRenewalReportController.RenewalRow();
        
        // Test with zero target
        row.targetRenewal = 0;
        row.renewed = 5;
        System.assertEquals(0, row.getRenewedPct(), 'Should return 0 when target is 0');
        
        // Test normal percentage
        row.targetRenewal = 10;
        row.renewed = 7;
        System.assertEquals(70, row.getRenewedPct(), 'Should return 70%');
        
        // Test 100% case
        row.targetRenewal = 10;
        row.renewed = 10;
        System.assertEquals(100, row.getRenewedPct(), 'Should return 100%');
        
        // Test over 100% case (should cap at 100)
        row.targetRenewal = 10;
        row.renewed = 15;
        System.assertEquals(100, row.getRenewedPct(), 'Should cap at 100%');
        
        // Test decimal result
        row.targetRenewal = 3;
        row.renewed = 1;
        Decimal expected = (Decimal.valueOf(1) / 3) * 100;
        System.assertEquals(expected, row.getRenewedPct(), 'Should handle decimal percentages');
    }
    
    @isTest
    static void testGetIneligiblePct() {
        AnnualRenewalReportController.RenewalRow row = new AnnualRenewalReportController.RenewalRow();
        
        // Test with zero target
        row.targetRenewal = 0;
        row.ineligible = 5;
        System.assertEquals(0, row.getIneligiblePct(), 'Should return 0 when target is 0');
        
        // Test normal percentage
        row.targetRenewal = 10;
        row.ineligible = 3;
        System.assertEquals(30, row.getIneligiblePct(), 'Should return 30%');
        
        // Test over 100% case (should cap at 100)
        row.targetRenewal = 10;
        row.ineligible = 15;
        System.assertEquals(100, row.getIneligiblePct(), 'Should cap at 100%');
    }
    
    @isTest
    static void testGetPendingPct() {
        AnnualRenewalReportController.RenewalRow row = new AnnualRenewalReportController.RenewalRow();
        
        // Test with zero target
        row.targetRenewal = 0;
        row.pending = 5;
        System.assertEquals(0, row.getPendingPct(), 'Should return 0 when target is 0');
        
        // Test normal percentage
        row.targetRenewal = 10;
        row.pending = 4;
        System.assertEquals(40, row.getPendingPct(), 'Should return 40%');
        
        // Test over 100% case (should cap at 100)
        row.targetRenewal = 10;
        row.pending = 12;
        System.assertEquals(100, row.getPendingPct(), 'Should cap at 100%');
    }
    
    @isTest
    static void testGetLostPct() {
        AnnualRenewalReportController.RenewalRow row = new AnnualRenewalReportController.RenewalRow();
        
        // Test with zero target
        row.targetRenewal = 0;
        row.lost = 5;
        System.assertEquals(0, row.getLostPct(), 'Should return 0 when target is 0');
        
        // Test normal percentage
        row.targetRenewal = 10;
        row.lost = 2;
        System.assertEquals(20, row.getLostPct(), 'Should return 20%');
        
        // Test over 100% case (should cap at 100)
        row.targetRenewal = 10;
        row.lost = 11;
        System.assertEquals(100, row.getLostPct(), 'Should cap at 100%');
    }
    
    @isTest
    static void testEmptyData() {
        // Test con base de datos vacía
        delete [SELECT Id FROM Policy__c];
        delete [SELECT Id FROM Vehicle__c];
        
        Test.startTest();
        List<AnnualRenewalReportController.RenewalRow> result = 
            AnnualRenewalReportController.getAnnualRenewalReportPartial();
        Test.stopTest();
        
        // Debería seguir retornando 13 filas (12 meses + 1 total)
        System.assertEquals(13, result.size(), 'Should return 12 months + 1 total even with empty data');
        
        // Verificar los 12 meses
        for (Integer i = 0; i < 12; i++) {
            AnnualRenewalReportController.RenewalRow row = result[i];
            System.assertEquals(i + 1, row.month, 'Month should be ' + (i + 1));
            System.assertEquals(0, row.targetRenewal, 'Target should be 0 with empty data');
            System.assertEquals(0, row.renewed, 'Renewed should be 0 with empty data');
            System.assertEquals(0, row.ineligible, 'Ineligible should be 0 with empty data');
            System.assertEquals(0, row.pending, 'Pending should be 0 with empty data');
            System.assertEquals(0, row.lost, 'Lost should be 0 with empty data');
            System.assertEquals(0, row.getRenewedPct(), 'Percentage should be 0 with empty data');
            System.assertEquals(0, row.getIneligiblePct(), 'Ineligible percentage should be 0 with empty data');
            System.assertEquals(0, row.getPendingPct(), 'Pending percentage should be 0 with empty data');
            System.assertEquals(0, row.getLostPct(), 'Lost percentage should be 0 with empty data');
        }
        
        // Verificar fila total
        AnnualRenewalReportController.RenewalRow totalRow = result[12];
        System.assertEquals(null, totalRow.month, 'Total row should have null month');
        System.assertEquals(0, totalRow.targetRenewal, 'Total target should be 0 with empty data');
        System.assertEquals(0, totalRow.renewed, 'Total renewed should be 0 with empty data');
        System.assertEquals(0, totalRow.ineligible, 'Total ineligible should be 0 with empty data');
        System.assertEquals(0, totalRow.pending, 'Total pending should be 0 with empty data');
        System.assertEquals(0, totalRow.lost, 'Total lost should be 0 with empty data');
    }
    
    @isTest
    static void testDynamicDates() {
        // Verificar que las fechas dinámicas funcionan correctamente
        Integer currentYear = Date.today().year();
        
        Test.startTest();
        List<AnnualRenewalReportController.RenewalRow> result = 
            AnnualRenewalReportController.getAnnualRenewalReportPartial();
        Test.stopTest();
        
        // Debe procesar datos para el año actual, no años fijos
        System.assertNotEquals(0, result.size(), 'Should process data for current year');
        
        // Los datos se basan en el año actual, así que deberían existir
        Boolean hasData = false;
        for (Integer i = 0; i < 12; i++) {
            if (result[i].targetRenewal > 0 || result[i].renewed > 0 || 
                result[i].ineligible > 0 || result[i].pending > 0 || result[i].lost > 0) {
                hasData = true;
                break;
            }
        }
        System.assertEquals(true, hasData, 'Should have data for current year based setup');
    }
    
    @isTest
    static void testUninsuredReasonFiltering() {
        // Test específico para verificar que las razones se filtran correctamente
        Integer currentYear = Date.today().year();
        
        // Crear política adicional para test
        Policy__c testPolicy = new Policy__c(
            Name = 'Test Policy',
            End_Date__c = Date.newInstance(currentYear, 5, 15),
            Term__c = 'Annual'
        );
        insert testPolicy;
        
        List<Vehicle__c> testVehicles = new List<Vehicle__c>();
        
        // Vehículo con razón que debe ir a Ineligible
        testVehicles.add(new Vehicle__c(
            Name = 'Test Stolen',
            Vin__c = 'VIN_TEST_STOLEN',
            Policy_Expiration__c = Date.newInstance(currentYear, 5, 20),
            vehicle_coverage_status__c = 'uninsured',
            Uninsured_Reason__c = 'Stolen',
            Policy__c = testPolicy.Id
        ));
        
        // Vehículo con razón que debe ir a Pending
        testVehicles.add(new Vehicle__c(
            Name = 'Test Unknown',
            Vin__c = 'VIN_TEST_UNKNOWN',
            Policy_Expiration__c = Date.newInstance(currentYear, 5, 21),
            vehicle_coverage_status__c = 'uninsured',
            Uninsured_Reason__c = 'Unknown',
            Policy__c = testPolicy.Id
        ));
        
        // Vehículo con razón que debe ir a Lost
        testVehicles.add(new Vehicle__c(
            Name = 'Test Elsewhere',
            Vin__c = 'VIN_TEST_ELSEWHERE',
            Policy_Expiration__c = Date.newInstance(currentYear, 5, 22),
            vehicle_coverage_status__c = 'uninsured',
            Uninsured_Reason__c = 'Insured Elsewhere',
            Policy__c = testPolicy.Id
        ));
        
        insert testVehicles;
        
        Test.startTest();
        List<AnnualRenewalReportController.RenewalRow> result = 
            AnnualRenewalReportController.getAnnualRenewalReportPartial();
        Test.stopTest();
        
        // Mayo (mes 5) debería tener los nuevos datos
        AnnualRenewalReportController.RenewalRow may = result[4]; // índice 4 = mayo
        System.assertEquals(5, may.month);
        System.assertEquals(1, may.targetRenewal, 'May should have 1 target renewal');
        System.assertNotEquals(0, may.ineligible, 'May should have ineligible vehicles');
        System.assertNotEquals(0, may.pending, 'May should have pending vehicles');
        System.assertNotEquals(0, may.lost, 'May should have lost vehicles');
    }
}