@isTest
public class CreateMessagingUserAsyncTest {

    @isTest
    static void testCreateMessagingUserAsync() {
        
        List<Lead> testLeads = new List<Lead>();
        for(Integer i = 0; i < 5; i++) {
            testLeads.add(new Lead(
                FirstName = 'TestFirstName' + i,
                LastName = 'TestLastName' + i,
                Company = 'TestCompany' + i,
                Phone = '123456789' + i,
                IsConverted = false
            ));
        }
        insert testLeads;
        
    }
}