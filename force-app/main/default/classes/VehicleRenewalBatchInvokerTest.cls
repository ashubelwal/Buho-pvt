@isTest
private class VehicleRenewalBatchInvokerTest {
    @isTest static void testRunBatch() {
        Test.startTest();
        VehicleRenewalBatchInvoker.runBatch(new List<Integer>{2});
        Test.stopTest();
        // Aquí puedes hacer asserts si quieres, por ejemplo:
        // Validar que no hubo errores o que el batch fue lanzado.
    }
}