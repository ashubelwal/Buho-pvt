@isTest
private class VehicleRenewalBatchTest {

    @testSetup
    static void setupData() {
        TriggerSwitch__c ts = new TriggerSwitch__c(Name = 'PolicyTrigger', Active__c = true);
        insert ts;

        List<Vehicle__c> vehicles = new List<Vehicle__c>();
        for (Integer i = 0; i < 2; i++) { // 2 vehículos, igual batch size
            vehicles.add(new Vehicle__c(
                Vin__c = 'VIN' + i
            ));
        }
        insert vehicles;

        List<Policy__c> policies = new List<Policy__c>();
        for (Vehicle__c v : vehicles) {
            policies.add(new Policy__c(
                Vehicle_Policy__c = v.Id,
                Start_Date__c = Date.today().addDays(-10),
                End_Date__c = Date.today().addDays(20),
                Term__c = 'Annual',
                Term_days__c = 365,
                Status_picklist__c = 'Active',
                Name = 'Policy ' + v.Vin__c
            ));
        }
        insert policies;
    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();
        VehicleRenewalBatch batch = new VehicleRenewalBatch();
        Database.executeBatch(batch, 2);  // batch size igual al número de vehículos
        Test.stopTest();

        List<Vehicle__c> updatedVehicles = [SELECT vehicle_coverage_status__c FROM Vehicle__c];
        System.assert(!updatedVehicles.isEmpty(), 'Debe haber vehículos procesados');
    }
}