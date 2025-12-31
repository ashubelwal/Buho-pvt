// // Apex Class - VehicleRenewalProcessor
// // Lógica: Un vehículo puede tener múltiples pólizas, pero solo una activa
// // Empezamos desde Vehicle y buscamos la póliza más reciente por End_Date__c
// public with sharing class VehicleRenewalProcessor {
    
//     // Invocable Method para usar en Flow
//     @InvocableMethod(label='Update Vehicle Renewal Data' description='Updates all vehicles with latest policy information')
//     public static List<ProcessResult> updateVehicleRenewalData(List<ProcessRequest> requests) {
        
//         List<ProcessResult> results = new List<ProcessResult>();
//         ProcessResult result = new ProcessResult();
        
//         try {
//             Integer updatedRecords = processVehicleUpdates();
            
//             result.isSuccess = true;
//             result.message = 'Successfully updated ' + updatedRecords + ' vehicle records.';
//             result.recordsProcessed = updatedRecords;
            
//         } catch (Exception e) {
//             result.isSuccess = false;
//             result.message = 'Error: ' + e.getMessage();
//             result.recordsProcessed = 0;
//             System.debug('VehicleRenewalProcessor Error: ' + e.getMessage());
//             System.debug('Stack Trace: ' + e.getStackTraceString());
//         }
        
//         results.add(result);
//         return results;
//     }
    
//     // Método principal: Procesa vehículos en lotes para evitar límites DML
//     public static Integer processVehicleUpdates() {
//         return processVehicleUpdatesInBatches(5000); // Procesar en lotes de 5000
//     }
    
//     // Método que procesa en lotes específicos
//     public static Integer processVehicleUpdatesInBatches(Integer batchSize) {
        
//         Integer totalProcessed = 0;
//         Integer offset = 0;
//         Boolean hasMoreRecords = true;
        
//         System.debug('Starting batch processing with batch size: ' + batchSize);
        
//         while (hasMoreRecords) {
            
//             // Paso 1: Obtener un lote de vehículos
//             List<Vehicle__c> vehicles = [
//                 SELECT Id, Vin__c, Policy__c, Policy_Expiration__c, vehicle_coverage_status__c
//                 FROM Vehicle__c
//                 ORDER BY Id
//                 LIMIT :batchSize
//                 OFFSET :offset
//             ];
            
//             if (vehicles.isEmpty()) {
//                 hasMoreRecords = false;
//                 break;
//             }
            
//             System.debug('Processing batch ' + (offset/batchSize + 1) + ' with ' + vehicles.size() + ' vehicles');
            
//             // Paso 2: Procesar este lote
//             Integer batchProcessed = processBatchOfVehicles(vehicles);
//             totalProcessed += batchProcessed;
            
//             // Paso 3: Preparar para el siguiente lote
//             if (vehicles.size() < batchSize) {
//                 hasMoreRecords = false; // Último lote
//             } else {
//                 offset += batchSize;
//             }
            
//             System.debug('Batch completed. Processed: ' + batchProcessed + ' | Total so far: ' + totalProcessed);
//         }
        
//         System.debug('=== BATCH PROCESSING COMPLETE ===');
//         System.debug('Total vehicles processed: ' + totalProcessed);
//         return totalProcessed;
//     }
    
//     // Método helper para procesar un lote específico de vehículos
//     private static Integer processBatchOfVehicles(List<Vehicle__c> vehicles) {
        
//         // Paso 1: Obtener IDs de vehículos para buscar sus pólizas
//         Set<Id> vehicleIds = new Set<Id>();
//         for (Vehicle__c vehicle : vehicles) {
//             vehicleIds.add(vehicle.Id);
//         }
        
//         // Paso 2: Buscar TODAS las pólizas de estos vehículos, ordenadas por fecha DESC
//         Map<Id, List<Policy__c>> policiesByVehicle = new Map<Id, List<Policy__c>>();
        
//         for (Policy__c policy : [
//             SELECT Id, Vehicle_Policy__c, End_Date__c, Term__c, Name
//             FROM Policy__c 
//             WHERE Vehicle_Policy__c IN :vehicleIds
//             ORDER BY Vehicle_Policy__c, End_Date__c DESC
//         ]) {
//             if (!policiesByVehicle.containsKey(policy.Vehicle_Policy__c)) {
//                 policiesByVehicle.put(policy.Vehicle_Policy__c, new List<Policy__c>());
//             }
//             policiesByVehicle.get(policy.Vehicle_Policy__c).add(policy);
//         }
        
//         // Paso 3: Procesar cada vehículo en el lote
//         List<Vehicle__c> vehiclesToUpdate = new List<Vehicle__c>();
//         Date today = Date.today();
//         // Date today = Date.today().addDays(-1);
        
//         for (Vehicle__c vehicle : vehicles) {
            
//             List<Policy__c> vehiclePolicies = policiesByVehicle.get(vehicle.Id);
            
//             // Si el vehículo tiene pólizas asociadas
//             if (vehiclePolicies != null && !vehiclePolicies.isEmpty()) {
                
//                 // Tomar la primera póliza (más reciente por End_Date__c DESC)
//                 Policy__c latestPolicy = vehiclePolicies[0];
                
//                 // Actualizar campos del vehículo con la póliza más reciente
//                 vehicle.Policy__c = latestPolicy.Id;
//                 vehicle.Policy_Expiration__c = latestPolicy.End_Date__c;
                
//                 // Determinar estado de cobertura basado en fecha y término
//                 if (latestPolicy.End_Date__c >= today) {
//                     // Póliza vigente
//                     if (latestPolicy.Term__c == 'Annual' & latestPolicy.Term__c == 'annual' & latestPolicy.Term__c == 'ANNUAL' & latestPolicy.Term__c == 'Annual(One Year)') {
//                         vehicle.vehicle_coverage_status__c = 'insured-annual';
//                     } else {
//                         vehicle.vehicle_coverage_status__c = 'insured';
//                     }
//                 } else {
//                     // Póliza expirada
//                     vehicle.vehicle_coverage_status__c = 'uninsured';
//                 }
                
//                 vehiclesToUpdate.add(vehicle);
                
//             } else {
//                 // Si no tiene pólizas, marcar como uninsured y limpiar campos
//                 vehicle.vehicle_coverage_status__c = 'uninsured';
//                 vehicle.Policy__c = null;
//                 vehicle.Policy_Expiration__c = null;
//                 vehiclesToUpdate.add(vehicle);
//             }
//         }
        
//         // Paso 4: Actualizar este lote de vehículos
//         if (!vehiclesToUpdate.isEmpty()) {
//             update vehiclesToUpdate;
//         }
        
//         return vehiclesToUpdate.size();
//     }
    
//     // Método para procesar solo un número limitado (para testing)
//     public static Integer processVehicleUpdatesLimit(Integer limitRecords) {
        
//         System.debug('Processing limited vehicles: ' + limitRecords);
        
//         // Paso 1: Obtener vehículos limitados
//         List<Vehicle__c> vehicles = [
//             SELECT Id, Vin__c, Policy__c, Policy_Expiration__c, vehicle_coverage_status__c
//             FROM Vehicle__c
//             ORDER BY Id
//             LIMIT :limitRecords
//         ];
        
//         if (vehicles.isEmpty()) {
//             System.debug('No vehicles found to process');
//             return 0;
//         }
        
//         // Paso 2: Procesar este grupo pequeño
//         return processBatchOfVehicles(vehicles);
//     }
//     public static Integer processVehicleUpdatesWithSubquery() {
        
//         // Una sola query con subquery para obtener la póliza más reciente
//         List<Vehicle__c> vehicles = [
//             SELECT Id, Vin__c, Policy__c, Policy_Expiration__c, vehicle_coverage_status__c,
//                    (SELECT Id, End_Date__c, Term__c, Name
//                     FROM Policies__r 
//                     ORDER BY End_Date__c DESC 
//                     LIMIT 1)
//             FROM Vehicle__c
//         ];
        
//         List<Vehicle__c> vehiclesToUpdate = new List<Vehicle__c>();
//         Date today = Date.today();
//         // Date today = Date.today().addDays(-1);
        
//         for (Vehicle__c vehicle : vehicles) {
            
//             // Si el vehículo tiene pólizas asociadas
//             if (!vehicle.Policies__r.isEmpty()) {
                
//                 Policy__c latestPolicy = vehicle.Policies__r[0];
                
//                 // Actualizar campos del vehículo
//                 vehicle.Policy__c = latestPolicy.Id;
//                 vehicle.Policy_Expiration__c = latestPolicy.End_Date__c;
                
//                 // Determinar estado de cobertura
//                 if (latestPolicy.End_Date__c > today) {
//                     if (latestPolicy.Term__c == 'Annual' & latestPolicy.Term__c == 'annual' & latestPolicy.Term__c == 'ANNUAL' & latestPolicy.Term__c == 'Annual(One Year)') {
//                         vehicle.vehicle_coverage_status__c = 'insured-annual';
//                     } else {
//                         vehicle.vehicle_coverage_status__c = 'insured';
//                     }
//                 } else {
//                     vehicle.vehicle_coverage_status__c = 'uninsured';
//                 }
                
//                 vehiclesToUpdate.add(vehicle);
//             }
//             // Si no tiene pólizas, marcar como uninsured
//             else {
//                 vehicle.vehicle_coverage_status__c = 'uninsured';
//                 vehicle.Policy__c = null; 
//                 vehicle.Policy_Expiration__c = null;
//                 vehiclesToUpdate.add(vehicle);
//             }
//         }
        
//         // Actualizar en lote
//         if (!vehiclesToUpdate.isEmpty()) {
//             update vehiclesToUpdate;
//         }
        
//         return vehiclesToUpdate.size();
//     }
    
//     // Método para debugging - ver qué pólizas tiene cada vehículo
//     public static void debugVehiclePolicies(Id vehicleId) {
        
//         List<Policy__c> policies = [
//             SELECT Id, Name, End_Date__c, Term__c, Vehicle_Policy__c
//             FROM Policy__c 
//             WHERE Vehicle_Policy__c = :vehicleId
//             ORDER BY End_Date__c DESC
//         ];
        
//         System.debug('=== Policies for Vehicle: ' + vehicleId + ' ===');
//         for (Policy__c policy : policies) {
//             System.debug('Policy: ' + policy.Name + ' | End Date: ' + policy.End_Date__c + ' | Term: ' + policy.Term__c);
//         }
//         System.debug('Total policies found: ' + policies.size());
//     }
    
//     // Clases para el Invocable Method
//     public class ProcessRequest {
//         @InvocableVariable(label='Use Subquery Method' description='If true, uses subquery method instead of separate queries')
//         public Boolean useSubquery = false;
//     }
    
//     public class ProcessResult {
//         @InvocableVariable(label='Success' description='Whether the process completed successfully')
//         public Boolean isSuccess;
        
//         @InvocableVariable(label='Message' description='Result message')
//         public String message;
        
//         @InvocableVariable(label='Records Processed' description='Number of records updated')
//         public Integer recordsProcessed;
//     }
// }
// ESTABLE VERSION ANTERIOR --------------------

//WORKING VERSION ONE ------------
// Apex Class - VehicleRenewalProcessor
// Lógica: Un vehículo puede tener múltiples pólizas, pero solo una activa
// Empezamos desde Vehicle y buscamos la póliza más reciente por End_Date__c
// public with sharing class VehicleRenewalProcessor {

//     // Invocable Method para usar en Flow
//     @InvocableMethod(label='Update Vehicle Renewal Data' description='Updates all vehicles with latest policy information')
//     public static List<ProcessResult> updateVehicleRenewalData(List<ProcessRequest> requests) {

//         List<ProcessResult> results = new List<ProcessResult>();
//         ProcessResult result = new ProcessResult();

//         try {
//             Integer updatedRecords = processVehicleUpdates();

//             result.isSuccess = true;
//             result.message = 'Successfully updated ' + updatedRecords + ' vehicle records.';
//             result.recordsProcessed = updatedRecords;

//         } catch (Exception e) {
//             result.isSuccess = false;
//             result.message = 'Error: ' + e.getMessage();
//             result.recordsProcessed = 0;
//             System.debug('VehicleRenewalProcessor Error: ' + e.getMessage());
//             System.debug('Stack Trace: ' + e.getStackTraceString());
//         }

//         results.add(result);
//         return results;
//     }

//     public static Integer processVehicleUpdates() {
//         return processVehicleUpdatesInBatches(5000);
//     }

//     public static Integer processVehicleUpdatesInBatches(Integer batchSize) {

//         Integer totalProcessed = 0;
//         Integer offset = 0;
//         Boolean hasMoreRecords = true;

//         while (hasMoreRecords) {

//             List<Vehicle__c> vehicles = [
//                 SELECT Id, Vin__c, Policy__c, Policy_Expiration__c, vehicle_coverage_status__c
//                 FROM Vehicle__c
//                 ORDER BY Id
//                 LIMIT :batchSize
//                 OFFSET :offset
//             ];

//             if (vehicles.isEmpty()) {
//                 hasMoreRecords = false;
//                 break;
//             }

//             Integer batchProcessed = processBatchOfVehicles(vehicles);
//             totalProcessed += batchProcessed;

//             if (vehicles.size() < batchSize) {
//                 hasMoreRecords = false;
//             } else {
//                 offset += batchSize;
//             }
//         }

//         return totalProcessed;
//     }

//     private static Integer processBatchOfVehicles(List<Vehicle__c> vehicles) {

//         Set<Id> vehicleIds = new Set<Id>();
//         for (Vehicle__c vehicle : vehicles) {
//             vehicleIds.add(vehicle.Id);
//         }

//         Map<Id, List<Policy__c>> policiesByVehicle = new Map<Id, List<Policy__c>>();

//         for (Policy__c policy : [
//             SELECT Id, Vehicle_Policy__c, End_Date__c, Term__c, Name
//             FROM Policy__c 
//             WHERE Vehicle_Policy__c IN :vehicleIds
//             ORDER BY Vehicle_Policy__c, End_Date__c DESC
//         ]) {
//             if (!policiesByVehicle.containsKey(policy.Vehicle_Policy__c)) {
//                 policiesByVehicle.put(policy.Vehicle_Policy__c, new List<Policy__c>());
//             }
//             policiesByVehicle.get(policy.Vehicle_Policy__c).add(policy);
//         }

//         List<Vehicle__c> vehiclesToUpdate = new List<Vehicle__c>();
//         Date today = Date.today();

//         for (Vehicle__c vehicle : vehicles) {

//             List<Policy__c> vehiclePolicies = policiesByVehicle.get(vehicle.Id);

//             if (vehiclePolicies != null && !vehiclePolicies.isEmpty()) {

//                 Policy__c latestPolicy = vehiclePolicies[0];

//                 vehicle.Policy__c = latestPolicy.Id;
//                 vehicle.Policy_Expiration__c = latestPolicy.End_Date__c;

//                 String termNormalized = latestPolicy.Term__c != null ? latestPolicy.Term__c.trim().toLowerCase() : '';

//                 if (latestPolicy.End_Date__c >= today) {
//                     if (termNormalized == 'annual' || termNormalized == 'annual(one year)') {
//                         vehicle.vehicle_coverage_status__c = 'insured-annual';
//                     } else {
//                         vehicle.vehicle_coverage_status__c = 'insured';
//                     }
//                 } else {
//                     vehicle.vehicle_coverage_status__c = 'uninsured';
//                 }

//                 vehiclesToUpdate.add(vehicle);

//             } else {
//                 vehicle.vehicle_coverage_status__c = 'uninsured';
//                 vehicle.Policy__c = null;
//                 vehicle.Policy_Expiration__c = null;
//                 vehiclesToUpdate.add(vehicle);
//             }
//         }

//         if (!vehiclesToUpdate.isEmpty()) {
//             update vehiclesToUpdate;
//         }

//         return vehiclesToUpdate.size();
//     }

//     public static Integer processVehicleUpdatesLimit(Integer limitRecords) {

//         List<Vehicle__c> vehicles = [
//             SELECT Id, Vin__c, Policy__c, Policy_Expiration__c, vehicle_coverage_status__c
//             FROM Vehicle__c
//             ORDER BY Id
//             LIMIT :limitRecords
//         ];

//         if (vehicles.isEmpty()) {
//             return 0;
//         }

//         return processBatchOfVehicles(vehicles);
//     }

//     public static Integer processVehicleUpdatesWithSubquery() {

//         List<Vehicle__c> vehicles = [
//             SELECT Id, Vin__c, Policy__c, Policy_Expiration__c, vehicle_coverage_status__c,
//                    (SELECT Id, End_Date__c, Term__c, Name
//                     FROM Policies__r 
//                     ORDER BY End_Date__c DESC 
//                     LIMIT 1)
//             FROM Vehicle__c
//         ];

//         List<Vehicle__c> vehiclesToUpdate = new List<Vehicle__c>();
//         Date today = Date.today();

//         for (Vehicle__c vehicle : vehicles) {

//             if (!vehicle.Policies__r.isEmpty()) {

//                 Policy__c latestPolicy = vehicle.Policies__r[0];

//                 vehicle.Policy__c = latestPolicy.Id;
//                 vehicle.Policy_Expiration__c = latestPolicy.End_Date__c;

//                 String termNormalized = latestPolicy.Term__c != null ? latestPolicy.Term__c.trim().toLowerCase() : '';

//                 if (latestPolicy.End_Date__c >= today) {
//                     if (termNormalized == 'annual' || termNormalized == 'annual(one year)') {
//                         vehicle.vehicle_coverage_status__c = 'insured-annual';
//                     } else {
//                         vehicle.vehicle_coverage_status__c = 'insured';
//                     }
//                 } else {
//                     vehicle.vehicle_coverage_status__c = 'uninsured';
//                 }

//                 vehiclesToUpdate.add(vehicle);

//             } else {
//                 vehicle.vehicle_coverage_status__c = 'uninsured';
//                 vehicle.Policy__c = null; 
//                 vehicle.Policy_Expiration__c = null;
//                 vehiclesToUpdate.add(vehicle);
//             }
//         }

//         if (!vehiclesToUpdate.isEmpty()) {
//             update vehiclesToUpdate;
//         }

//         return vehiclesToUpdate.size();
//     }

//     public static void debugVehiclePolicies(Id vehicleId) {

//         List<Policy__c> policies = [
//             SELECT Id, Name, End_Date__c, Term__c, Vehicle_Policy__c
//             FROM Policy__c 
//             WHERE Vehicle_Policy__c = :vehicleId
//             ORDER BY End_Date__c DESC
//         ];

//         System.debug('=== Policies for Vehicle: ' + vehicleId + ' ===');
//         for (Policy__c policy : policies) {
//             System.debug('Policy: ' + policy.Name + ' | End Date: ' + policy.End_Date__c + ' | Term: ' + policy.Term__c);
//         }
//         System.debug('Total policies found: ' + policies.size());
//     }

//     public class ProcessRequest {
//         @InvocableVariable(label='Use Subquery Method' description='If true, uses subquery method instead of separate queries')
//         public Boolean useSubquery = false;
//     }

//     public class ProcessResult {
//         @InvocableVariable(label='Success' description='Whether the process completed successfully')
//         public Boolean isSuccess;

//         @InvocableVariable(label='Message' description='Result message')
//         public String message;

//         @InvocableVariable(label='Records Processed' description='Number of records updated')
//         public Integer recordsProcessed;
//     }
// }

// VERSION 2 SEMIESTABLE
// public with sharing class VehicleRenewalProcessor {

//     @InvocableMethod(label='Update Vehicle Renewal Data' description='Updates all vehicles with latest policy information')
//     public static List<ProcessResult> updateVehicleRenewalData(List<ProcessRequest> requests) {
//         List<ProcessResult> results = new List<ProcessResult>();
//         ProcessResult result = new ProcessResult();

//         try {
//             Integer updatedRecords = processVehicleUpdates();
//             result.isSuccess = true;
//             result.message = 'Successfully updated ' + updatedRecords + ' vehicle records.';
//             result.recordsProcessed = updatedRecords;
//         } catch (Exception e) {
//             result.isSuccess = false;
//             result.message = 'Error: ' + e.getMessage();
//             result.recordsProcessed = 0;
//             System.debug('VehicleRenewalProcessor Error: ' + e.getMessage());
//             System.debug('Stack Trace: ' + e.getStackTraceString());
//         }

//         results.add(result);
//         return results;
//     }

//     public static Integer processVehicleUpdates() {
//         return processVehicleUpdatesInBatches(5000);
//     }

//     public static Integer processVehicleUpdatesInBatches(Integer batchSize) {
//         Integer totalProcessed = 0;
//         Integer offset = 0;
//         Boolean hasMoreRecords = true;

//         while (hasMoreRecords) {
//             List<Vehicle__c> vehicles = [
//                 SELECT Id, Vin__c, Policy__c, Policy_Expiration__c, vehicle_coverage_status__c
//                 FROM Vehicle__c
//                 ORDER BY Id
//                 LIMIT :batchSize
//                 OFFSET :offset
//             ];

//             if (vehicles.isEmpty()) {
//                 hasMoreRecords = false;
//                 break;
//             }

//             Integer batchProcessed = processBatchOfVehicles(vehicles);
//             totalProcessed += batchProcessed;

//             if (vehicles.size() < batchSize) {
//                 hasMoreRecords = false;
//             } else {
//                 offset += batchSize;
//             }
//         }

//         return totalProcessed;
//     }

//     private static Integer processBatchOfVehicles(List<Vehicle__c> vehicles) {
//         Set<Id> vehicleIds = new Set<Id>();
//         for (Vehicle__c vehicle : vehicles) {
//             vehicleIds.add(vehicle.Id);
//         }

//         Map<Id, List<Policy__c>> policiesByVehicle = new Map<Id, List<Policy__c>>();
//         for (Policy__c policy : [
//             SELECT Id, Vehicle_Policy__c, End_Date__c, Term__c, Term_days__c, Name
//             FROM Policy__c 
//             WHERE Vehicle_Policy__c IN :vehicleIds
//             ORDER BY Vehicle_Policy__c, End_Date__c DESC
//         ]) {
//             if (!policiesByVehicle.containsKey(policy.Vehicle_Policy__c)) {
//                 policiesByVehicle.put(policy.Vehicle_Policy__c, new List<Policy__c>());
//             }
//             policiesByVehicle.get(policy.Vehicle_Policy__c).add(policy);
//         }

//         List<Vehicle__c> vehiclesToUpdate = new List<Vehicle__c>();
//         Date today = Date.today();

//         for (Vehicle__c vehicle : vehicles) {
//             List<Policy__c> vehiclePolicies = policiesByVehicle.get(vehicle.Id);

//             if (vehiclePolicies != null && !vehiclePolicies.isEmpty()) {
//                 Policy__c latestPolicy = vehiclePolicies[0];
//                 vehicle.Policy__c = latestPolicy.Id;
//                 vehicle.Policy_Expiration__c = latestPolicy.End_Date__c;

//                 String termNormalized = latestPolicy.Term__c != null ? latestPolicy.Term__c.trim().toLowerCase() : '';

//                 if (latestPolicy.End_Date__c >= today) {
//                     if (
//                         termNormalized == 'annual' || 
//                         termNormalized == 'annual(one year)' || 
//                         termNormalized == 'Annual' || 
//                         latestPolicy.Term_days__c == 365
//                     ) {
//                         vehicle.vehicle_coverage_status__c = 'insured-annual';
//                     } else {
//                         vehicle.vehicle_coverage_status__c = 'insured';
//                     }
//                 } else {
//                     vehicle.vehicle_coverage_status__c = 'uninsured';
//                 }

//                 vehiclesToUpdate.add(vehicle);

//             } else {
//                 vehicle.vehicle_coverage_status__c = 'uninsured';
//                 vehicle.Policy__c = null;
//                 vehicle.Policy_Expiration__c = null;
//                 vehiclesToUpdate.add(vehicle);
//             }
//         }

//         if (!vehiclesToUpdate.isEmpty()) {
//             update vehiclesToUpdate;
//         }

//         return vehiclesToUpdate.size();
//     }

//     public static Integer processVehicleUpdatesLimit(Integer limitRecords) {
//         List<Vehicle__c> vehicles = [
//             SELECT Id, Vin__c, Policy__c, Policy_Expiration__c, vehicle_coverage_status__c
//             FROM Vehicle__c
//             ORDER BY Id
//             LIMIT :limitRecords
//         ];

//         if (vehicles.isEmpty()) {
//             return 0;
//         }

//         return processBatchOfVehicles(vehicles);
//     }

//     public static Integer processVehicleUpdatesWithSubquery() {
//         List<Vehicle__c> vehicles = [
//             SELECT Id, Vin__c, Policy__c, Policy_Expiration__c, vehicle_coverage_status__c,
//                    (SELECT Id, End_Date__c, Term__c, Term_days__c, Name
//                     FROM Policies__r 
//                     ORDER BY End_Date__c DESC 
//                     LIMIT 1)
//             FROM Vehicle__c
//         ];

//         List<Vehicle__c> vehiclesToUpdate = new List<Vehicle__c>();
//         Date today = Date.today();

//         for (Vehicle__c vehicle : vehicles) {
//             if (!vehicle.Policies__r.isEmpty()) {
//                 Policy__c latestPolicy = vehicle.Policies__r[0];
//                 vehicle.Policy__c = latestPolicy.Id;
//                 vehicle.Policy_Expiration__c = latestPolicy.End_Date__c;

//                 String termNormalized = latestPolicy.Term__c != null ? latestPolicy.Term__c.trim().toLowerCase() : '';

//                 if (latestPolicy.End_Date__c >= today) {
//                     if (
//                         termNormalized == 'annual' || 
//                         termNormalized == 'annual(one year)' || 
//                         termNormalized == 'Annual' ||
//                         latestPolicy.Term_days__c == 365
//                     ) {
//                         vehicle.vehicle_coverage_status__c = 'insured-annual';
//                     } else {
//                         vehicle.vehicle_coverage_status__c = 'insured';
//                     }
//                 } else {
//                     vehicle.vehicle_coverage_status__c = 'uninsured';
//                 }

//                 vehiclesToUpdate.add(vehicle);

//             } else {
//                 vehicle.vehicle_coverage_status__c = 'uninsured';
//                 vehicle.Policy__c = null; 
//                 vehicle.Policy_Expiration__c = null;
//                 vehiclesToUpdate.add(vehicle);
//             }
//         }

//         if (!vehiclesToUpdate.isEmpty()) {
//             update vehiclesToUpdate;
//         }

//         return vehiclesToUpdate.size();
//     }

//     public static void debugVehiclePolicies(Id vehicleId) {
//         List<Policy__c> policies = [
//             SELECT Id, Name, End_Date__c, Term__c, Term_days__c, Vehicle_Policy__c
//             FROM Policy__c 
//             WHERE Vehicle_Policy__c = :vehicleId
//             ORDER BY End_Date__c DESC
//         ];

//         System.debug('=== Policies for Vehicle: ' + vehicleId + ' ===');
//         for (Policy__c policy : policies) {
//             System.debug('Policy: ' + policy.Name + ' | End Date: ' + policy.End_Date__c + ' | Term: ' + policy.Term__c + ' | Term_Days: ' + policy.Term_days__c);
//         }
//         System.debug('Total policies found: ' + policies.size());
//     }

//     public class ProcessRequest {
//         @InvocableVariable(label='Use Subquery Method' description='If true, uses subquery method instead of separate queries')
//         public Boolean useSubquery = false;
//     }

//     public class ProcessResult {
//         @InvocableVariable(label='Success' description='Whether the process completed successfully')
//         public Boolean isSuccess;

//         @InvocableVariable(label='Message' description='Result message')
//         public String message;

//         @InvocableVariable(label='Records Processed' description='Number of records updated')
//         public Integer recordsProcessed;
//     }
// }

// VERSION 2 SEMIESTABLE

//VERSION 3 WORKING SEMIESETABLE 2.0
// public with sharing class VehicleRenewalProcessor {

//     @InvocableMethod(label='Update Vehicle Renewal Data' description='Updates all vehicles with latest policy information')
//     public static List<ProcessResult> updateVehicleRenewalData(List<ProcessRequest> requests) {
//         List<ProcessResult> results = new List<ProcessResult>();
//         ProcessResult result = new ProcessResult();

//         try {
//             Integer updatedRecords = processVehicleUpdates();
//             result.isSuccess = true;
//             result.message = 'Successfully updated ' + updatedRecords + ' vehicle records.';
//             result.recordsProcessed = updatedRecords;
//         } catch (Exception e) {
//             result.isSuccess = false;
//             result.message = 'Error: ' + e.getMessage();
//             result.recordsProcessed = 0;
//             System.debug('VehicleRenewalProcessor Error: ' + e.getMessage());
//             System.debug('Stack Trace: ' + e.getStackTraceString());
//         }

//         results.add(result);
//         return results;
//     }

//     public static Integer processVehicleUpdates() {
//         return processVehicleUpdatesInBatches(5000);
//     }

//     public static Integer processVehicleUpdatesInBatches(Integer batchSize) {
//         Integer totalProcessed = 0;
//         Integer offset = 0;
//         Boolean hasMoreRecords = true;

//         while (hasMoreRecords) {
//             List<Vehicle__c> vehicles = [
//                 SELECT Id, Vin__c, Policy__c, Policy_Expiration__c, vehicle_coverage_status__c
//                 FROM Vehicle__c
//                 WHERE CreatedDate >= 2023-01-01T00:00:00Z
//                 ORDER BY Id
//                 LIMIT :batchSize
//                 OFFSET :offset
//             ];

//             if (vehicles.isEmpty()) {
//                 hasMoreRecords = false;
//                 break;
//             }

//             Integer batchProcessed = processBatchOfVehicles(vehicles);
//             totalProcessed += batchProcessed;

//             if (vehicles.size() < batchSize) {
//                 hasMoreRecords = false;
//             } else {
//                 offset += batchSize;
//             }
//         }

//         return totalProcessed;
//     }

//     private static Integer processBatchOfVehicles(List<Vehicle__c> vehicles) {
//         Set<Id> vehicleIds = new Set<Id>();
//         for (Vehicle__c vehicle : vehicles) {
//             vehicleIds.add(vehicle.Id);
//         }

//         Map<Id, List<Policy__c>> policiesByVehicle = new Map<Id, List<Policy__c>>();
//         for (Policy__c policy : [
//             SELECT Id, Vehicle_Policy__c, End_Date__c, Term__c, Term_days__c, Name
//             FROM Policy__c 
//             WHERE Vehicle_Policy__c IN :vehicleIds
//             ORDER BY Vehicle_Policy__c, End_Date__c DESC
//         ]) {
//             if (!policiesByVehicle.containsKey(policy.Vehicle_Policy__c)) {
//                 policiesByVehicle.put(policy.Vehicle_Policy__c, new List<Policy__c>());
//             }
//             policiesByVehicle.get(policy.Vehicle_Policy__c).add(policy);
//         }

//         List<Vehicle__c> vehiclesToUpdate = new List<Vehicle__c>();
//         Date today = Date.today();

//         for (Vehicle__c vehicle : vehicles) {
//             List<Policy__c> vehiclePolicies = policiesByVehicle.get(vehicle.Id);

//             if (vehiclePolicies != null && !vehiclePolicies.isEmpty()) {
//                 Policy__c latestPolicy = vehiclePolicies[0];
//                 vehicle.Policy__c = latestPolicy.Id;
//                 vehicle.Policy_Expiration__c = latestPolicy.End_Date__c;

//                 String termNormalized = latestPolicy.Term__c != null ? latestPolicy.Term__c.trim().toLowerCase() : '';

//                 if (latestPolicy.End_Date__c >= today) {
//                     if (
//                         termNormalized == 'annual' || 
//                         termNormalized == 'annual(one year)' || 
//                         termNormalized == 'Annual' || 
//                         latestPolicy.Term_days__c == 365
//                     ) {
//                         vehicle.vehicle_coverage_status__c = 'insured-annual';
//                     } else {
//                         vehicle.vehicle_coverage_status__c = 'insured';
//                     }
//                 } else {
//                     vehicle.vehicle_coverage_status__c = 'uninsured';
//                 }

//                 vehiclesToUpdate.add(vehicle);

//             } else {
//                 vehicle.vehicle_coverage_status__c = 'uninsured';
//                 vehicle.Policy__c = null;
//                 vehicle.Policy_Expiration__c = null;
//                 vehiclesToUpdate.add(vehicle);
//             }
//         }

//         if (!vehiclesToUpdate.isEmpty()) {
//             update vehiclesToUpdate;
//         }

//         return vehiclesToUpdate.size();
//     }

//     public static Integer processVehicleUpdatesLimit(Integer limitRecords) {
//         List<Vehicle__c> vehicles = [
//             SELECT Id, Vin__c, Policy__c, Policy_Expiration__c, vehicle_coverage_status__c
//             FROM Vehicle__c
//             WHERE CreatedDate >= 2023-01-01T00:00:00Z
//             ORDER BY Id
//             LIMIT :limitRecords
//         ];

//         if (vehicles.isEmpty()) {
//             return 0;
//         }

//         return processBatchOfVehicles(vehicles);
//     }

//     public static Integer processVehicleUpdatesWithSubquery() {
//         List<Vehicle__c> vehicles = [
//             SELECT Id, Vin__c, Policy__c, Policy_Expiration__c, vehicle_coverage_status__c,
//                    (SELECT Id, End_Date__c, Term__c, Term_days__c, Name
//                     FROM Policies__r 
//                     ORDER BY End_Date__c DESC 
//                     LIMIT 1)
//             FROM Vehicle__c
//             WHERE CreatedDate >= 2023-01-01T00:00:00Z
//         ];

//         List<Vehicle__c> vehiclesToUpdate = new List<Vehicle__c>();
//         Date today = Date.today();

//         for (Vehicle__c vehicle : vehicles) {
//             if (!vehicle.Policies__r.isEmpty()) {
//                 Policy__c latestPolicy = vehicle.Policies__r[0];
//                 vehicle.Policy__c = latestPolicy.Id;
//                 vehicle.Policy_Expiration__c = latestPolicy.End_Date__c;

//                 String termNormalized = latestPolicy.Term__c != null ? latestPolicy.Term__c.trim().toLowerCase() : '';

//                 if (latestPolicy.End_Date__c >= today) {
//                     if (
//                         termNormalized == 'annual' || 
//                         termNormalized == 'annual(one year)' || 
//                         termNormalized == 'Annual' ||
//                         latestPolicy.Term_days__c == 365
//                     ) {
//                         vehicle.vehicle_coverage_status__c = 'insured-annual';
//                     } else {
//                         vehicle.vehicle_coverage_status__c = 'insured';
//                     }
//                 } else {
//                     vehicle.vehicle_coverage_status__c = 'uninsured';
//                 }

//                 vehiclesToUpdate.add(vehicle);

//             } else {
//                 vehicle.vehicle_coverage_status__c = 'uninsured';
//                 vehicle.Policy__c = null; 
//                 vehicle.Policy_Expiration__c = null;
//                 vehiclesToUpdate.add(vehicle);
//             }
//         }

//         if (!vehiclesToUpdate.isEmpty()) {
//             update vehiclesToUpdate;
//         }

//         return vehiclesToUpdate.size();
//     }

//     public static void debugVehiclePolicies(Id vehicleId) {
//         List<Policy__c> policies = [
//             SELECT Id, Name, End_Date__c, Term__c, Term_days__c, Vehicle_Policy__c
//             FROM Policy__c 
//             WHERE Vehicle_Policy__c = :vehicleId
//             ORDER BY End_Date__c DESC
//         ];

//         System.debug('=== Policies for Vehicle: ' + vehicleId + ' ===');
//         for (Policy__c policy : policies) {
//             System.debug('Policy: ' + policy.Name + ' | End Date: ' + policy.End_Date__c + ' | Term: ' + policy.Term__c + ' | Term_Days: ' + policy.Term_days__c);
//         }
//         System.debug('Total policies found: ' + policies.size());
//     }

//     public class ProcessRequest {
//         @InvocableVariable(label='Use Subquery Method' description='If true, uses subquery method instead of separate queries')
//         public Boolean useSubquery = false;
//     }

//     public class ProcessResult {
//         @InvocableVariable(label='Success' description='Whether the process completed successfully')
//         public Boolean isSuccess;

//         @InvocableVariable(label='Message' description='Result message')
//         public String message;

//         @InvocableVariable(label='Records Processed' description='Number of records updated')
//         public Integer recordsProcessed;
//     }
// }

//VERSION 3 WORKING SEMIESTABLE 2.0

// VERSION 4
//VERSION 4 UPDATED - No OFFSET, Uses ID-based Pagination + CreatedDate filter
//VERSION 4 UPDATED - No OFFSET, Uses ID-based Pagination + CreatedDate filter
// public with sharing class VehicleRenewalProcessor {

//     @InvocableMethod(label='Update Vehicle Renewal Data' description='Updates all vehicles with latest policy information')
//     public static List<ProcessResult> updateVehicleRenewalData(List<ProcessRequest> requests) {
//         List<ProcessResult> results = new List<ProcessResult>();
//         ProcessResult result = new ProcessResult();

//         try {
//             Integer updatedRecords = processVehicleUpdates();
//             result.isSuccess = true;
//             result.message = 'Successfully updated ' + updatedRecords + ' vehicle records.';
//             result.recordsProcessed = updatedRecords;
//         } catch (Exception e) {
//             result.isSuccess = false;
//             result.message = 'Error: ' + e.getMessage();
//             result.recordsProcessed = 0;
//             System.debug('VehicleRenewalProcessor Error: ' + e.getMessage());
//             System.debug('Stack Trace: ' + e.getStackTraceString());
//         }

//         results.add(result);
//         return results;
//     }

//     public static Integer processVehicleUpdates() {
//         return processVehicleUpdatesInBatches(500);
//     }

//     public static Integer processVehicleUpdatesInBatches(Integer batchSize) {
//         Integer totalProcessed = 0;
//         Id lastId = null;
//         Boolean hasMoreRecords = true;

//         Date cutoffDate = Date.newInstance(2023, 1, 1); // Desde 1/1/2023

//         while (hasMoreRecords) {
//             List<Vehicle__c> vehicles;

//             if (lastId == null) {
//                 vehicles = [
//                     SELECT Id, Vin__c, Policy__c, Policy_Expiration__c, vehicle_coverage_status__c
//                     FROM Vehicle__c
//                     WHERE CreatedDate >= :cutoffDate
//                     ORDER BY Id
//                     LIMIT :batchSize
//                 ];
//             } else {
//                 vehicles = [
//                     SELECT Id, Vin__c, Policy__c, Policy_Expiration__c, vehicle_coverage_status__c
//                     FROM Vehicle__c
//                     WHERE CreatedDate >= :cutoffDate AND Id > :lastId
//                     ORDER BY Id
//                     LIMIT :batchSize
//                 ];
//             }

//             if (vehicles.isEmpty()) {
//                 hasMoreRecords = false;
//                 break;
//             }

//             Integer batchProcessed = processBatchOfVehicles(vehicles);
//             totalProcessed += batchProcessed;

//             if (vehicles.size() < batchSize) {
//                 hasMoreRecords = false;
//             } else {
//                 lastId = vehicles[vehicles.size() - 1].Id;
//             }
//         }

//         return totalProcessed;
//     }

//     private static Integer processBatchOfVehicles(List<Vehicle__c> vehicles) {
//         Set<Id> vehicleIds = new Set<Id>();
//         for (Vehicle__c vehicle : vehicles) {
//             vehicleIds.add(vehicle.Id);
//         }

//         Map<Id, List<Policy__c>> policiesByVehicle = new Map<Id, List<Policy__c>>();
//         for (Policy__c policy : [
//             SELECT Id, Vehicle_Policy__c, End_Date__c, Term__c, Term_days__c, Name
//             FROM Policy__c 
//             WHERE Vehicle_Policy__c IN :vehicleIds
//             ORDER BY Vehicle_Policy__c, End_Date__c DESC
//         ]) {
//             if (!policiesByVehicle.containsKey(policy.Vehicle_Policy__c)) {
//                 policiesByVehicle.put(policy.Vehicle_Policy__c, new List<Policy__c>());
//             }
//             policiesByVehicle.get(policy.Vehicle_Policy__c).add(policy);
//         }

//         List<Vehicle__c> vehiclesToUpdate = new List<Vehicle__c>();
//         Date today = Date.today();

//         for (Vehicle__c vehicle : vehicles) {
//             List<Policy__c> vehiclePolicies = policiesByVehicle.get(vehicle.Id);

//             if (vehiclePolicies != null && !vehiclePolicies.isEmpty()) {
//                 Policy__c latestPolicy = vehiclePolicies[0];
//                 vehicle.Policy__c = latestPolicy.Id;
//                 vehicle.Policy_Expiration__c = latestPolicy.End_Date__c;

//                 String termNormalized = latestPolicy.Term__c != null ? latestPolicy.Term__c.trim().toLowerCase() : '';

//                 if (latestPolicy.End_Date__c >= today) {
//                     if (
//                         termNormalized == 'annual' || 
//                         termNormalized == 'annual(one year)' || 
//                         termNormalized == 'annual' || 
//                         latestPolicy.Term_days__c == 365
//                     ) {
//                         vehicle.vehicle_coverage_status__c = 'insured-annual';
//                     } else {
//                         vehicle.vehicle_coverage_status__c = 'insured';
//                     }
//                 } else {
//                     vehicle.vehicle_coverage_status__c = 'uninsured';
//                 }

//                 vehiclesToUpdate.add(vehicle);

//             } else {
//                 vehicle.vehicle_coverage_status__c = 'uninsured';
//                 vehicle.Policy__c = null;
//                 vehicle.Policy_Expiration__c = null;
//                 vehiclesToUpdate.add(vehicle);
//             }
//         }

//         if (!vehiclesToUpdate.isEmpty()) {
//             update vehiclesToUpdate;
//         }

//         return vehiclesToUpdate.size();
//     }

//     public class ProcessRequest {
//         @InvocableVariable(label='Use Subquery Method' description='If true, uses subquery method instead of separate queries')
//         public Boolean useSubquery = false;
//     }

//     public class ProcessResult {
//         @InvocableVariable(label='Success' description='Whether the process completed successfully')
//         public Boolean isSuccess;

//         @InvocableVariable(label='Message' description='Result message')
//         public String message;

//         @InvocableVariable(label='Records Processed' description='Number of records updated')
//         public Integer recordsProcessed;
//     }
// }

// VERSION 4

// VERSION 5 FUNCIONAL VERSION 3
// public with sharing class VehicleRenewalProcessor {

//     @InvocableMethod(label='Update Vehicle Renewal Data' description='Updates all vehicles with latest policy information')
//     public static List<ProcessResult> updateVehicleRenewalData(List<ProcessRequest> requests) {
//         List<ProcessResult> results = new List<ProcessResult>();
//         ProcessResult result = new ProcessResult();

//         try {
//             Integer updatedRecords = processVehicleUpdates();
//             result.isSuccess = true;
//             result.message = 'Successfully updated ' + updatedRecords + ' vehicle records.';
//             result.recordsProcessed = updatedRecords;
//         } catch (Exception e) {
//             result.isSuccess = false;
//             result.message = 'Error: ' + e.getMessage();
//             result.recordsProcessed = 0;
//             System.debug('VehicleRenewalProcessor Error: ' + e.getMessage());
//             System.debug('Stack Trace: ' + e.getStackTraceString());
//         }

//         results.add(result);
//         return results;
//     }

//     public static Integer processVehicleUpdates() {
//         return processVehicleUpdatesInBatches(500);
//     }

//     public static Integer processVehicleUpdatesInBatches(Integer batchSize) {
//         Integer totalProcessed = 0;
//         Id lastId = null;
//         Boolean hasMoreRecords = true;

//         Date cutoffDate = Date.newInstance(2023, 1, 1); // Desde 1/1/2023

//         while (hasMoreRecords) {
//             List<Vehicle__c> vehicles;

//             if (lastId == null) {
//                 vehicles = [
//                     SELECT Id, Vin__c, Policy__c, Policy_Expiration__c, vehicle_coverage_status__c, Uninsured_Reason__c
//                     FROM Vehicle__c
//                     WHERE CreatedDate >= :cutoffDate
//                     ORDER BY Id
//                     LIMIT :batchSize
//                 ];
//             } else {
//                 vehicles = [
//                     SELECT Id, Vin__c, Policy__c, Policy_Expiration__c, vehicle_coverage_status__c, Uninsured_Reason__c
//                     FROM Vehicle__c
//                     WHERE CreatedDate >= :cutoffDate AND Id > :lastId
//                     ORDER BY Id
//                     LIMIT :batchSize
//                 ];
//             }

//             if (vehicles.isEmpty()) {
//                 hasMoreRecords = false;
//                 break;
//             }

//             Integer batchProcessed = processBatchOfVehicles(vehicles);
//             totalProcessed += batchProcessed;

//             if (vehicles.size() < batchSize) {
//                 hasMoreRecords = false;
//             } else {
//                 lastId = vehicles[vehicles.size() - 1].Id;
//             }
//         }

//         return totalProcessed;
//     }

//     private static Integer processBatchOfVehicles(List<Vehicle__c> vehicles) {
//         Set<Id> vehicleIds = new Set<Id>();
//         for (Vehicle__c vehicle : vehicles) {
//             vehicleIds.add(vehicle.Id);
//         }

//         Map<Id, List<Policy__c>> policiesByVehicle = new Map<Id, List<Policy__c>>();
//         for (Policy__c policy : [
//             SELECT Id, Vehicle_Policy__c, End_Date__c, Term__c, Term_days__c, Name, Status_picklist__c
//             FROM Policy__c 
//             WHERE Vehicle_Policy__c IN :vehicleIds
//             ORDER BY Vehicle_Policy__c, End_Date__c DESC
//         ]) {
//             if (!policiesByVehicle.containsKey(policy.Vehicle_Policy__c)) {
//                 policiesByVehicle.put(policy.Vehicle_Policy__c, new List<Policy__c>());
//             }
//             policiesByVehicle.get(policy.Vehicle_Policy__c).add(policy);
//         }

//         List<Vehicle__c> vehiclesToUpdate = new List<Vehicle__c>();
//         Date today = Date.today();

//         for (Vehicle__c vehicle : vehicles) {
//             List<Policy__c> vehiclePolicies = policiesByVehicle.get(vehicle.Id);

//             if (vehiclePolicies != null && !vehiclePolicies.isEmpty()) {
//                 Policy__c latestPolicy = vehiclePolicies[0];
//                 vehicle.Policy__c = latestPolicy.Id;
//                 vehicle.Policy_Expiration__c = latestPolicy.End_Date__c;

//                 String termNormalized = latestPolicy.Term__c != null ? latestPolicy.Term__c.trim().toLowerCase() : '';
//                 String statusNormalized = latestPolicy.Status_picklist__c != null ? latestPolicy.Status_picklist__c.trim().toLowerCase() : '';

//                 if (latestPolicy.End_Date__c >= today) {
//                     if (
//                         termNormalized == 'annual' || 
//                         termNormalized == 'annual(one year)' ||
//                         termNormalized == 'Annual(one year)' ||
//                         termNormalized == 'Annual' ||
//                         latestPolicy.Term_days__c == 365
//                     ) {
//                         vehicle.vehicle_coverage_status__c = 'insured-annual';
//                     } else {
//                         vehicle.vehicle_coverage_status__c = 'insured';
//                     }
//                 } else {
//                     // Póliza expirada
//                     // Agregamos condición: si era annual y está "Terminated", lo dejamos como uninsured
//                     if (
//                         (termNormalized == 'annual' || termNormalized == 'annual(one year)' || termNormalized == 'Annual(one year)' || termNormalized == 'Annual' || latestPolicy.Term_days__c == 365) &&
//                         statusNormalized == 'Terminated'
//                     ) {
//                         vehicle.vehicle_coverage_status__c = 'uninsured';
//                         vehicle.Uninsured_Reason__c = 'Unknown';
//                     } else {
//                         vehicle.vehicle_coverage_status__c = 'uninsured';
//                         vehicle.Uninsured_Reason__c = 'Unknown';
//                     }
//                 }

//                 vehiclesToUpdate.add(vehicle);

//             } else {
//                 vehicle.vehicle_coverage_status__c = 'uninsured';
//                 vehicle.Uninsured_Reason__c = 'Unknown'; // ✅ nuevo
//                 vehicle.Policy__c = null;
//                 vehicle.Policy_Expiration__c = null;
//                 vehiclesToUpdate.add(vehicle);
//             }
//         }

//         if (!vehiclesToUpdate.isEmpty()) {
//             update vehiclesToUpdate;
//         }

//         return vehiclesToUpdate.size();
//     }

//     public class ProcessRequest {
//         @InvocableVariable(label='Use Subquery Method' description='If true, uses subquery method instead of separate queries')
//         public Boolean useSubquery = false;
//     }

//     public class ProcessResult {
//         @InvocableVariable(label='Success' description='Whether the process completed successfully')
//         public Boolean isSuccess;

//         @InvocableVariable(label='Message' description='Result message')
//         public String message;

//         @InvocableVariable(label='Records Processed' description='Number of records updated')
//         public Integer recordsProcessed;
//     }
// }

// //VERSION 5 UPDATED FUNCIONAL VERSION 3

// VERSION 6
// public with sharing class VehicleRenewalProcessor {

//     @InvocableMethod(label='Update Vehicle Renewal Data' description='Updates all vehicles with latest policy information')
//     public static List<ProcessResult> updateVehicleRenewalData(List<ProcessRequest> requests) {
//         List<ProcessResult> results = new List<ProcessResult>();
//         ProcessResult result = new ProcessResult();

//         try {
//             Integer updatedRecords = processVehicleUpdates();
//             result.isSuccess = true;
//             result.message = 'Successfully updated ' + updatedRecords + ' vehicle records.';
//             result.recordsProcessed = updatedRecords;
//         } catch (Exception e) {
//             result.isSuccess = false;
//             result.message = 'Error: ' + e.getMessage();
//             result.recordsProcessed = 0;
//             System.debug('VehicleRenewalProcessor Error: ' + e.getMessage());
//             System.debug('Stack Trace: ' + e.getStackTraceString());
//         }

//         results.add(result);
//         return results;
//     }

//     public static Integer processVehicleUpdates() {
//         return processVehicleUpdatesInBatches(500);
//     }

//     public static Integer processVehicleUpdatesInBatches(Integer batchSize) {
//         Integer totalProcessed = 0;
//         Id lastId = null;
//         Boolean hasMoreRecords = true;

//         Date cutoffDate = Date.newInstance(2023, 1, 1); // Desde 1/1/2023

//         while (hasMoreRecords) {
//             List<Vehicle__c> vehicles;

//             if (lastId == null) {
//                 vehicles = [
//                     SELECT Id, Vin__c, Policy__c, Policy_Expiration__c, vehicle_coverage_status__c, Uninsured_Reason__c
//                     FROM Vehicle__c
//                     WHERE CreatedDate >= :cutoffDate
//                     ORDER BY Id
//                     LIMIT :batchSize
//                 ];
//             } else {
//                 vehicles = [
//                     SELECT Id, Vin__c, Policy__c, Policy_Expiration__c, vehicle_coverage_status__c, Uninsured_Reason__c
//                     FROM Vehicle__c
//                     WHERE CreatedDate >= :cutoffDate AND Id > :lastId
//                     ORDER BY Id
//                     LIMIT :batchSize
//                 ];
//             }

//             if (vehicles.isEmpty()) {
//                 hasMoreRecords = false;
//                 break;
//             }

//             Integer batchProcessed = processBatchOfVehicles(vehicles);
//             totalProcessed += batchProcessed;

//             if (vehicles.size() < batchSize) {
//                 hasMoreRecords = false;
//             } else {
//                 lastId = vehicles[vehicles.size() - 1].Id;
//             }
//         }

//         return totalProcessed;
//     }

//     private static Integer processBatchOfVehicles(List<Vehicle__c> vehicles) {
//         Set<Id> vehicleIds = new Set<Id>();
//         for (Vehicle__c vehicle : vehicles) {
//             vehicleIds.add(vehicle.Id);
//         }

//         Map<Id, List<Policy__c>> policiesByVehicle = new Map<Id, List<Policy__c>>();
//         for (Policy__c policy : [
//             SELECT Id, Vehicle_Policy__c, End_Date__c, Term__c, Term_days__c, Name, Status_picklist__c
//             FROM Policy__c 
//             WHERE Vehicle_Policy__c IN :vehicleIds
//             ORDER BY Vehicle_Policy__c, End_Date__c DESC
//         ]) {
//             if (!policiesByVehicle.containsKey(policy.Vehicle_Policy__c)) {
//                 policiesByVehicle.put(policy.Vehicle_Policy__c, new List<Policy__c>());
//             }
//             policiesByVehicle.get(policy.Vehicle_Policy__c).add(policy);
//         }

//         List<Vehicle__c> vehiclesToUpdate = new List<Vehicle__c>();
//         Date today = Date.today();

//         for (Vehicle__c vehicle : vehicles) {
//             List<Policy__c> vehiclePolicies = policiesByVehicle.get(vehicle.Id);

//             if (vehiclePolicies != null && !vehiclePolicies.isEmpty()) {
//                 Policy__c latestPolicy = vehiclePolicies[0];
//                 vehicle.Policy__c = latestPolicy.Id;
//                 vehicle.Policy_Expiration__c = latestPolicy.End_Date__c;

//                 String termNormalized = latestPolicy.Term__c != null ? latestPolicy.Term__c.trim().toLowerCase() : '';
//                 String statusNormalized = latestPolicy.Status_picklist__c != null ? latestPolicy.Status_picklist__c.trim().toLowerCase() : '';

//                 if (statusNormalized == 'terminated') {
//                 vehicle.vehicle_coverage_status__c = 'uninsured';
//                 vehicle.Uninsured_Reason__c = 'Unknown';
//                 } else if (latestPolicy.End_Date__c >= today) {
//                     if (
//                         termNormalized == 'annual' || 
//                         termNormalized == 'annual(one year)' ||
//                         termNormalized == 'Annual' || 
//                         termNormalized == 'Annual(one year)' ||
//                         latestPolicy.Term_days__c == 365
//                     ) {
//                         vehicle.vehicle_coverage_status__c = 'insured-annual';
//                     } else {
//                         vehicle.vehicle_coverage_status__c = 'insured';
//                     }
//                     vehicle.Uninsured_Reason__c = null;
//                 } else {
//                     vehicle.vehicle_coverage_status__c = 'uninsured';
//                     vehicle.Uninsured_Reason__c = 'Unknown';
//                 }

//                 vehiclesToUpdate.add(vehicle);
//             } else {
//                 vehicle.vehicle_coverage_status__c = 'uninsured';
//                 vehicle.Uninsured_Reason__c = 'Unknown';
//                 vehicle.Policy__c = null;
//                 vehicle.Policy_Expiration__c = null;
//                 vehiclesToUpdate.add(vehicle);
//             }
//         }

//         if (!vehiclesToUpdate.isEmpty()) {
//             update vehiclesToUpdate;
//         }

//         return vehiclesToUpdate.size();
//     }

//     public class ProcessRequest {
//         @InvocableVariable(label='Use Subquery Method' description='If true, uses subquery method instead of separate queries')
//         public Boolean useSubquery = false;
//     }

//     public class ProcessResult {
//         @InvocableVariable(label='Success' description='Whether the process completed successfully')
//         public Boolean isSuccess;

//         @InvocableVariable(label='Message' description='Result message')
//         public String message;

//         @InvocableVariable(label='Records Processed' description='Number of records updated')
//         public Integer recordsProcessed;
//     }
// }

// VERSION 6 ESTABLE

// VERSION 7 SEMI-FINAL ESTABLE VERSION
//     public with sharing class VehicleRenewalProcessor {

//     @InvocableMethod(label='Update Vehicle Renewal Data' description='Updates all vehicles with latest policy information')
//     public static List<ProcessResult> updateVehicleRenewalData(List<ProcessRequest> requests) {
//         List<ProcessResult> results = new List<ProcessResult>();
//         ProcessResult result = new ProcessResult();

//         try {
//             // Process vehicle updates and get the count of updated records
//             Integer updatedRecords = processVehicleUpdates();
//             result.isSuccess = true;
//             result.message = 'Successfully updated ' + updatedRecords + ' vehicle records.';
//             result.recordsProcessed = updatedRecords;
//         } catch (Exception e) {
//             // Handle errors and log exception details
//             result.isSuccess = false;
//             result.message = 'Error: ' + e.getMessage();
//             result.recordsProcessed = 0;
//             System.debug('VehicleRenewalProcessor Error: ' + e.getMessage());
//             System.debug('Stack Trace: ' + e.getStackTraceString());
//         }

//         results.add(result);
//         return results;
//     }

//     public static Integer processVehicleUpdates() {
//         // Start batch processing with a default batch size of 500 records
//         return processVehicleUpdatesInBatches(500);
//     }

//     public static Integer processVehicleUpdatesInBatches(Integer batchSize) {
//         Integer totalProcessed = 0;
//         Id lastId = null;
//         Boolean hasMoreRecords = true;

//         // Process vehicles created since this cutoff date
//         Date cutoffDate = Date.newInstance(2023, 1, 1);

//         while (hasMoreRecords) {
//             List<Vehicle__c> vehicles;

//             if (lastId == null) {
//                 // Query first batch of vehicles ordered by Id
//                 vehicles = [
//                     SELECT Id, Vin__c, Policy__c, Policy_Expiration__c, vehicle_coverage_status__c, Uninsured_Reason__c
//                     FROM Vehicle__c
//                     WHERE CreatedDate >= :cutoffDate
//                     ORDER BY Id
//                     LIMIT :batchSize
//                 ];
//             } else {
//                 // Query next batch of vehicles with Id greater than last processed Id
//                 vehicles = [
//                     SELECT Id, Vin__c, Policy__c, Policy_Expiration__c, vehicle_coverage_status__c, Uninsured_Reason__c
//                     FROM Vehicle__c
//                     WHERE CreatedDate >= :cutoffDate AND Id > :lastId
//                     ORDER BY Id
//                     LIMIT :batchSize
//                 ];
//             }

//             if (vehicles.isEmpty()) {
//                 // No more records to process, exit loop
//                 hasMoreRecords = false;
//                 break;
//             }

//             // Process current batch and count how many vehicles were updated
//             Integer batchProcessed = processBatchOfVehicles(vehicles);
//             totalProcessed += batchProcessed;

//             if (vehicles.size() < batchSize) {
//                 // Last batch processed, exit loop
//                 hasMoreRecords = false;
//             } else {
//                 // Prepare for next batch by setting lastId to the last record's Id
//                 lastId = vehicles[vehicles.size() - 1].Id;
//             }
//         }

//         return totalProcessed;
//     }

//     private static Integer processBatchOfVehicles(List<Vehicle__c> vehicles) {
//         Set<Id> vehicleIds = new Set<Id>();
//         for (Vehicle__c vehicle : vehicles) {
//             vehicleIds.add(vehicle.Id);
//         }

//         // Query policies related to the vehicles, ordered by vehicle and policy end date descending
//         Map<Id, List<Policy__c>> policiesByVehicle = new Map<Id, List<Policy__c>>();
//         for (Policy__c policy : [
//             SELECT Id, Vehicle_Policy__c, End_Date__c, Term__c, Term_days__c, Name, Status_picklist__c
//             FROM Policy__c 
//             WHERE Vehicle_Policy__c IN :vehicleIds
//             ORDER BY Vehicle_Policy__c, End_Date__c DESC
//         ]) {
//             if (!policiesByVehicle.containsKey(policy.Vehicle_Policy__c)) {
//                 policiesByVehicle.put(policy.Vehicle_Policy__c, new List<Policy__c>());
//             }
//             policiesByVehicle.get(policy.Vehicle_Policy__c).add(policy);
//         }

//         List<Vehicle__c> vehiclesToUpdate = new List<Vehicle__c>();
//         Date today = Date.today();

//         for (Vehicle__c vehicle : vehicles) {
//             // Store current vehicle values for comparison later
//             Id currentPolicyId = vehicle.Policy__c;
//             Date currentExpiration = vehicle.Policy_Expiration__c;
//             String currentStatus = vehicle.vehicle_coverage_status__c;
//             String currentReason = vehicle.Uninsured_Reason__c;

//             List<Policy__c> vehiclePolicies = policiesByVehicle.get(vehicle.Id);

//             // Variables to hold the newly calculated values
//             Id newPolicyId;
//             Date newExpiration;
//             String newStatus;
//             String newReason;

//             if (vehiclePolicies != null && !vehiclePolicies.isEmpty()) {
//                 Policy__c latestPolicy = vehiclePolicies[0];
//                 newPolicyId = latestPolicy.Id;
//                 newExpiration = latestPolicy.End_Date__c;

//                 // Normalize term and status values to lowercase for comparison
//                 String termNormalized = latestPolicy.Term__c != null ? latestPolicy.Term__c.trim().toLowerCase() : '';
//                 String statusNormalized = latestPolicy.Status_picklist__c != null ? latestPolicy.Status_picklist__c.trim().toLowerCase() : '';

//                 // Determine coverage status based on policy status and dates
//                 if (statusNormalized == 'terminated') {
//                     newStatus = 'uninsured';
//                     newReason = 'Unknown';
//                 } else if (newExpiration >= today) {
//                     if (
//                         termNormalized == 'annual' || 
//                         termNormalized == 'annual(one year)' ||
//                         latestPolicy.Term_days__c == 365
//                     ) {
//                         newStatus = 'insured-annual';
//                     } else {
//                         newStatus = 'insured';
//                     }
//                     newReason = null;
//                 } else {
//                     newStatus = 'uninsured';
//                     newReason = 'Unknown';
//                 }
//             } else {
//                 // No policies found for the vehicle; mark as uninsured
//                 newPolicyId = null;
//                 newExpiration = null;
//                 newStatus = 'uninsured';
//                 newReason = 'Unknown';
//             }

//             // Compare current and new values, update only if there's a change to avoid unnecessary DML
//             if (currentPolicyId != newPolicyId ||
//                 currentExpiration != newExpiration ||
//                 currentStatus != newStatus ||
//                 currentReason != newReason) {
                
//                 vehicle.Policy__c = newPolicyId;
//                 vehicle.Policy_Expiration__c = newExpiration;
//                 vehicle.vehicle_coverage_status__c = newStatus;
//                 vehicle.Uninsured_Reason__c = newReason;

//                 vehiclesToUpdate.add(vehicle);
//             }
//         }

//         // Perform update only if there are changes to save
//         if (!vehiclesToUpdate.isEmpty()) {
//             update vehiclesToUpdate;
//         }

//         // Return the count of vehicles updated in this batch
//         return vehiclesToUpdate.size();
//     }

//     // Invocable method parameter class (not currently used in logic)
//     public class ProcessRequest {
//         @InvocableVariable(label='Use Subquery Method' description='If true, uses subquery method instead of separate queries')
//         public Boolean useSubquery = false;
//     }

//     // Invocable method return result class
//     public class ProcessResult {
//         @InvocableVariable(label='Success' description='Whether the process completed successfully')
//         public Boolean isSuccess;

//         @InvocableVariable(label='Message' description='Result message')
//         public String message;

//         @InvocableVariable(label='Records Processed' description='Number of records updated')
//         public Integer recordsProcessed;
//     }
// }

// VERSION 7

// VERSION 9
public with sharing class VehicleRenewalProcessor {

    @InvocableMethod(label='Update Vehicle Renewal Data' description='Updates all vehicles with latest policy information')
    public static List<ProcessResult> updateVehicleRenewalData(List<ProcessRequest> requests) {
        List<ProcessResult> results = new List<ProcessResult>();
        ProcessResult result = new ProcessResult();

        try {
            Integer updatedRecords = processVehicleUpdates();
            result.isSuccess = true;
            result.message = 'Successfully updated ' + updatedRecords + ' vehicle records.';
            result.recordsProcessed = updatedRecords;
        } catch (Exception e) {
            result.isSuccess = false;
            result.message = 'Error: ' + e.getMessage();
            result.recordsProcessed = 0;
            System.debug('VehicleRenewalProcessor Error: ' + e.getMessage());
            System.debug('Stack Trace: ' + e.getStackTraceString());
        }

        results.add(result);
        return results;
    }

    public static Integer processVehicleUpdates() {
        return processVehicleUpdatesInBatches(500);
    }

    public static Integer processVehicleUpdatesInBatches(Integer batchSize) {
        Integer totalProcessed = 0;
        Id lastId = null;
        Boolean hasMoreRecords = true;

        Date cutoffDate = Date.newInstance(2015, 1, 1);

        while (hasMoreRecords) {
            List<Vehicle__c> vehicles;

            if (lastId == null) {
                vehicles = [
                    SELECT Id, Vin__c, Policy__c, Policy_Expiration__c, vehicle_coverage_status__c, Uninsured_Reason__c
                    FROM Vehicle__c
                    WHERE CreatedDate >= :cutoffDate
                    ORDER BY Id
                    LIMIT :batchSize
                ];
            } else {
                vehicles = [
                    SELECT Id, Vin__c, Policy__c, Policy_Expiration__c, vehicle_coverage_status__c, Uninsured_Reason__c
                    FROM Vehicle__c
                    WHERE CreatedDate >= :cutoffDate AND Id > :lastId
                    ORDER BY Id
                    LIMIT :batchSize
                ];
            }

            if (vehicles.isEmpty()) {
                hasMoreRecords = false;
                break;
            }

            Integer batchProcessed = processBatchOfVehicles(vehicles);
            totalProcessed += batchProcessed;

            if (vehicles.size() < batchSize) {
                hasMoreRecords = false;
            } else {
                lastId = vehicles[vehicles.size() - 1].Id;
            }
        }

        return totalProcessed;
    }

    public static Integer processBatchOfVehicles(List<Vehicle__c> vehicles) {
        Set<Id> vehicleIds = new Set<Id>();
        for (Vehicle__c vehicle : vehicles) {
            vehicleIds.add(vehicle.Id);
        }

        // Query policies related to the vehicles, ordered by vehicle and policy end date descending
        Map<Id, List<Policy__c>> policiesByVehicle = new Map<Id, List<Policy__c>>();
        for (Policy__c policy : [
            SELECT Id, Vehicle_Policy__c, Start_Date__c, End_Date__c, Term__c, Term_days__c, Name, Status_picklist__c
            FROM Policy__c 
            WHERE Vehicle_Policy__c IN :vehicleIds
            ORDER BY Vehicle_Policy__c, End_Date__c DESC
        ]) {
            if (!policiesByVehicle.containsKey(policy.Vehicle_Policy__c)) {
                policiesByVehicle.put(policy.Vehicle_Policy__c, new List<Policy__c>());
            }
            policiesByVehicle.get(policy.Vehicle_Policy__c).add(policy);
        }

    List<Vehicle__c> vehiclesToUpdate = new List<Vehicle__c>();
        Date today = Date.today();

        for (Vehicle__c vehicle : vehicles) {
            Id currentPolicyId = vehicle.Policy__c;
            Date currentExpiration = vehicle.Policy_Expiration__c;
            String currentStatus = vehicle.vehicle_coverage_status__c;
            String currentReason = vehicle.Uninsured_Reason__c;

            List<Policy__c> vehiclePolicies = policiesByVehicle.get(vehicle.Id);

            Id newPolicyId;
            Date newExpiration;
            String newStatus;
            String newReason;

            if (vehiclePolicies != null && !vehiclePolicies.isEmpty()) {
                Policy__c latestPolicy = vehiclePolicies[0];
                newPolicyId = latestPolicy.Id;
                newExpiration = latestPolicy.End_Date__c;

                String termNormalized = latestPolicy.Term__c != null ? latestPolicy.Term__c.trim().toLowerCase() : '';
                String statusNormalized = latestPolicy.Status_picklist__c != null ? latestPolicy.Status_picklist__c.trim().toLowerCase() : '';

                if (statusNormalized == 'terminated' || statusNormalized == 'expired') {
                    newStatus = 'uninsured';
                    newReason = currentReason != null ? currentReason : null; // respeta el valor anterior
                } else if (newExpiration >= today) {
                    Boolean isRenewal = false;

                    // Validación original
                    if (vehiclePolicies.size() > 1) {
                        Policy__c previousPolicy = vehiclePolicies[1];
                        if (previousPolicy.End_Date__c != null && latestPolicy.Start_Date__c != null &&
                            previousPolicy.End_Date__c <= latestPolicy.Start_Date__c) {
                            isRenewal = true;
                        }
                    }

                    // Nueva validación adicional
                    if (vehiclePolicies.size() > 1) {
                        Policy__c previousPolicy = vehiclePolicies[1];
                        if (previousPolicy.End_Date__c != null && latestPolicy.Start_Date__c != null) {
                            isRenewal = true;
                        }
                    }

                    if (isRenewal) {
                        if (termNormalized == 'annual' || 
                            termNormalized == 'annual(one year)' || 
                            latestPolicy.Term_days__c == 365) {
                            newStatus = 'insured-renew-annual';
                        } else {
                            newStatus = 'insured-renew';
                        }
                    } else if (
                        termNormalized == 'annual' || 
                        termNormalized == 'annual(one year)' ||
                        latestPolicy.Term_days__c == 365
                    ) {
                        newStatus = 'insured-annual';
                    } else {
                        newStatus = 'insured';
                    }
                    newReason = currentReason != null ? currentReason : null; // no sobreescribir si ya hay valor
                } else {
                    newStatus = 'uninsured';
                    newReason = currentReason != null ? currentReason : 'Unknown';
                }
            } else {
                newPolicyId = null;
                newExpiration = null;
                newStatus = 'uninsured';
                newReason = currentReason != null ? currentReason : 'Unknown';
            }

            if (currentPolicyId != newPolicyId ||
                currentExpiration != newExpiration ||
                currentStatus != newStatus ||
                currentReason != newReason) {
                
                vehicle.Policy__c = newPolicyId;
                vehicle.Policy_Expiration__c = newExpiration;
                vehicle.vehicle_coverage_status__c = newStatus;
                vehicle.Uninsured_Reason__c = newReason;

                vehiclesToUpdate.add(vehicle);
            }
        }

        if (!vehiclesToUpdate.isEmpty()) {
            update vehiclesToUpdate;
        }

        return vehiclesToUpdate.size();
    }

    public class ProcessRequest {
        @InvocableVariable(label='Use Subquery Method' description='If true, uses subquery method instead of separate queries')
        public Boolean useSubquery = false;
    }

    public class ProcessResult {
        @InvocableVariable(label='Success' description='Whether the process completed successfully')
        public Boolean isSuccess;
        @InvocableVariable(label='Message' description='Result message')
        public String message;
        @InvocableVariable(label='Records Processed' description='Number of records updated')
        public Integer recordsProcessed;
    }
}


//WORKING VERSION ------------


// public with sharing class VehicleRenewalProcessor {
    
//     @InvocableMethod(label='Update Vehicle Renewal Data' description='Updates all vehicles with latest policy information')
//     public static List<ProcessResult> updateVehicleRenewalData(List<ProcessRequest> requests) {
        
//         List<ProcessResult> results = new List<ProcessResult>();
//         ProcessResult result = new ProcessResult();
        
//         try {
//             Integer batchSize = 200; // default
//             Boolean enableDebug = false; // default

//             if (!requests.isEmpty()) {
//                 ProcessRequest req = requests[0];
//                 if (req.batchSize != null && req.batchSize > 0) {
//                     batchSize = req.batchSize;
//                 }
//                 if (req.debugMode != null) {
//                     enableDebug = req.debugMode;
//                 }
//             }

//             Integer updatedRecords = processVehicleUpdatesInBatches(batchSize, enableDebug);
//             result.isSuccess = true;
//             result.message = 'Successfully updated ' + updatedRecords + ' vehicle records.';
//             result.recordsProcessed = updatedRecords;
            
//         } catch (Exception e) {
//             result.isSuccess = false;
//             result.message = 'Error: ' + e.getMessage();
//             result.recordsProcessed = 0;
//             System.debug('VehicleRenewalProcessor Error: ' + e.getMessage());
//             System.debug('Stack Trace: ' + e.getStackTraceString());
//         }
        
//         results.add(result);
//         return results;
//     }
    
//     public static Integer processVehicleUpdatesInBatches(Integer batchSize, Boolean enableDebug) {
//         Integer totalProcessed = 0;
//         Id lastId = null;
//         Boolean hasMoreRecords = true;
        
//         while (hasMoreRecords) {
//             List<Vehicle__c> vehicles;
            
//             if (lastId == null) {
//                 vehicles = [
//                     SELECT Id, Vin__c, Policy__c, Policy_Expiration__c, vehicle_coverage_status__c
//                     FROM Vehicle__c
//                     ORDER BY Id
//                     LIMIT :batchSize
//                 ];
//             } else {
//                 vehicles = [
//                     SELECT Id, Vin__c, Policy__c, Policy_Expiration__c, vehicle_coverage_status__c
//                     FROM Vehicle__c
//                     WHERE Id > :lastId
//                     ORDER BY Id
//                     LIMIT :batchSize
//                 ];
//             }
            
//             if (vehicles.isEmpty()) {
//                 hasMoreRecords = false;
//                 break;
//             }
            
//             if (enableDebug) {
//                 Set<Id> vehicleIds = new Set<Id>();
//                 for (Vehicle__c v : vehicles) vehicleIds.add(v.Id);
//                 debugPoliciesForVehicles(vehicleIds);
//             }
            
//             Integer batchProcessed = processBatchOfVehicles(vehicles);
//             totalProcessed += batchProcessed;
//             lastId = vehicles[vehicles.size()-1].Id;
            
//             if (vehicles.size() < batchSize) {
//                 hasMoreRecords = false;
//             }
//         }
        
//         return totalProcessed;
//     }
    
//     private static Integer processBatchOfVehicles(List<Vehicle__c> vehicles) {
//         Set<Id> vehicleIds = new Set<Id>();
//         for (Vehicle__c vehicle : vehicles) {
//             vehicleIds.add(vehicle.Id);
//         }
        
//         Map<Id, List<Policy__c>> policiesByVehicle = new Map<Id, List<Policy__c>>();
        
//         for (Policy__c policy : [
//             SELECT Id, Vehicle_Policy__c, End_Date__c, Term__c, Name
//             FROM Policy__c 
//             WHERE Vehicle_Policy__c IN :vehicleIds
//             ORDER BY Vehicle_Policy__c, End_Date__c DESC
//         ]) {
//             if (!policiesByVehicle.containsKey(policy.Vehicle_Policy__c)) {
//                 policiesByVehicle.put(policy.Vehicle_Policy__c, new List<Policy__c>());
//             }
//             policiesByVehicle.get(policy.Vehicle_Policy__c).add(policy);
//         }
        
//         List<Vehicle__c> vehiclesToUpdate = new List<Vehicle__c>();
//         Date today = Date.today();
        
//         for (Vehicle__c vehicle : vehicles) {
//             List<Policy__c> vehiclePolicies = policiesByVehicle.get(vehicle.Id);
            
//             if (vehiclePolicies != null && !vehiclePolicies.isEmpty()) {
//                 Policy__c latestPolicy = vehiclePolicies[0];
                
//                 vehicle.Policy__c = latestPolicy.Id;
//                 vehicle.Policy_Expiration__c = latestPolicy.End_Date__c;
                
//                 if (latestPolicy.End_Date__c >= today) {
//                     vehicle.vehicle_coverage_status__c = (latestPolicy.Term__c == 'insured-annual') ? 'insured-annual' : 'insured-annual';
//                 } else {
//                     vehicle.vehicle_coverage_status__c = 'insured-annual';
//                 }
//             } else {
//                 vehicle.Policy__c = null;
//                 vehicle.Policy_Expiration__c = null;
//                 vehicle.vehicle_coverage_status__c = 'insured-annual';
//             }
//             vehiclesToUpdate.add(vehicle);
//         }
        
//         if (!vehiclesToUpdate.isEmpty()) {
//             update vehiclesToUpdate;
//         }
        
//         return vehiclesToUpdate.size();
//     }
    
//     // DEBUG SEGURO
//     public static void debugPoliciesForVehicles(Set<Id> vehicleIds) {
//         List<Policy__c> policies = [
//             SELECT Id, Name, End_Date__c, Term__c, Vehicle_Policy__c
//             FROM Policy__c 
//             WHERE Vehicle_Policy__c IN :vehicleIds
//             ORDER BY Vehicle_Policy__c, End_Date__c DESC
//         ];
        
//         System.debug('=== DEBUG POLICIES FOR VEHICLES ===');
//         for (Policy__c p : policies) {
//             System.debug('Vehicle Id: ' + p.Vehicle_Policy__c + ', Policy: ' + p.Name + ', End Date: ' + p.End_Date__c + ', Term: ' + p.Term__c);
//         }
//         System.debug('Total policies found: ' + policies.size());
//     }
    
//     // Clases para el Invocable Method
//     public class ProcessRequest {
//         @InvocableVariable(label='Batch Size' description='Number of records per batch')
//         public Integer batchSize;
        
//         @InvocableVariable(label='Enable Debug Mode' description='If true, prints debug output')
//         public Boolean debugMode;
//     }
    
//     public class ProcessResult {
//         @InvocableVariable(label='Success' description='Whether the process completed successfully')
//         public Boolean isSuccess;
        
//         @InvocableVariable(label='Message' description='Result message')
//         public String message;
        
//         @InvocableVariable(label='Records Processed' description='Number of records updated')
//         public Integer recordsProcessed;
//     }
// }