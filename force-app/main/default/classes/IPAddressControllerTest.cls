@IsTest
public with sharing class IPAddressControllerTest {

    @IsTest
    private static void getUserIPAddress_positive() {
        IPAddressController controller = new IPAddressController();
        ApexPages.currentPage().getHeaders().put('X-Forwarded-For', '0.0.0.0');
        Test.startTest();
        controller.getUserIPAddress();
        Test.stopTest();
        System.assert(controller.ip.contains('0.0.0.0'));
    }
}