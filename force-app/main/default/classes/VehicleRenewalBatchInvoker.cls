public with sharing class VehicleRenewalBatchInvoker {

    @InvocableMethod(label='Run Vehicle Renewal Batch' description='Run the batch to update vehicle renewal data')
    public static void runBatch(List<Integer> batchSizes) {
        Integer batchSize = (batchSizes != null && !batchSizes.isEmpty()) ? batchSizes[0] : 200;
        Database.executeBatch(new VehicleRenewalBatch(), batchSize);
    }
}