public with sharing class VehicleRenewalBatch implements Database.Batchable<SObject>, Database.Stateful {

    private Date cutoffDate = Date.newInstance(2015, 1, 1);

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Vin__c, Policy__c, Policy_Expiration__c, vehicle_coverage_status__c, Uninsured_Reason__c ' +
                       'FROM Vehicle__c WHERE CreatedDate >= :cutoffDate ORDER BY Id';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        // Convertir la lista de SObject a Vehicle__c
        List<Vehicle__c> vehicles = (List<Vehicle__c>)scope;
        VehicleRenewalProcessor.processBatchOfVehicles(vehicles);
    }

    public void finish(Database.BatchableContext bc) {
        // Opcional: enviar correo, logs, etc.
    }
}