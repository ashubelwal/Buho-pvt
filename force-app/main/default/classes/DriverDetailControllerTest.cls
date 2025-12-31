@isTest
public class DriverDetailControllerTest {
    public class ExampleCalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
        date myDate1 = date.newInstance(1988, 12, 17);
        lead ldObj = new lead();
        ldObj.company='abcd';
        ldObj.email='ssharmad'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastNamed';
        ldobj.Firstname ='TestfirstNamed';
        ldobj.City ='testcityd';
        ldobj.State ='teststated';
        ldobj.Phone ='1234567892';
        ldobj.Street ='teststrretd';
        ldobj.Country ='testcountryd';
        ldobj.PostalCode= '12343';
        ldobj.Date_of_Birth__c = myDate1;
        ldObj.status='New';  
        insert ldObj;
       /* Quote__c quotes = new Quote__c ();
        date myDate = date.newInstance(1988, 12, 17);
        quotes.Date_of_Birth__c = myDate;
        insert quotes; 
        test.startTest();*/
        string data = String.valueOf(ldObj);
        map<string, object> mapToSerialize = new map<string, object>();
        mapToSerialize.put('type', ldObj);
        //add you subtype like this 
        string jsonstring = JSON.serialize(mapToSerialize); 
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody(jsonstring);
            return res;
        }
    }
    
    public static testMethod void processDriverDetails(){
        
        //insert userRole
        
        Profile profId = [select Id from Profile where name='Standard User' limit 1];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        if(uniqueName.length()>51)
        {
            uniqueName=uniqueName.substring(0,51);
        }
        User tuser = new User( firstname = 'Test',
                              lastName = 'Kiran',
                              email = uniqueName + '@test' + orgId + '.org',
                              Username = uniqueName + '@test' + orgId + '.org',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias = uniqueName.substring(18, 23),
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              ProfileId = profId.Id);
        insert tuser;
        date myDate1 = date.newInstance(1988, 12, 17);
        lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldobj.Firstname ='TestfirstName';
        ldobj.City ='testcity';
        ldobj.State ='teststate';
        ldobj.Phone ='123456789';
        ldobj.Street ='teststrret';
        ldobj.Country ='testcountry';
        ldobj.PostalCode= '1234';
        ldobj.Date_of_Birth__c = myDate1;
        ldObj.status='New';  
        insert ldObj;
        Quote__c quotes = new Quote__c ();
        date myDate = date.newInstance(1988, 12, 17);
        quotes.Date_of_Birth__c = myDate;
        insert quotes; 
        test.startTest();
        //add you subtype like this    
        DriverDetailController.getCurrentUserDrivers();
        DriverDetailController.checkalreadyExistUserAction('test@gmail.com');
        DriverDetailController.createDriverAction(TestDataService.createDriver(), quotes.Id,true, quotes.Id,true);
        test.stopTest();   
    }
      public static testMethod void  testMethodTwo(){
        //insert userRole    
        date myDate1 = date.newInstance(1988, 12, 17);
        lead ldObj = new lead();
        ldObj.company='abc';
        ldObj.email='ssharma'+String.valueOf(System.today())+'@gmail.com';
        ldObj.lastname='TestlastName';
        ldobj.Firstname ='TestfirstName';
        ldobj.City ='testcity';
        ldobj.State ='teststate';
        ldobj.Phone ='123456789';
        ldobj.Street ='teststrret';
        ldobj.Country ='testcountry';
        ldobj.PostalCode= '1234';
        ldobj.Date_of_Birth__c = myDate1;
        ldObj.status='New';  
        insert ldObj;
        Quote__c quotes = new Quote__c ();
        date myDate = date.newInstance(1988, 12, 17);
        quotes.Date_of_Birth__c = myDate;
        insert quotes; 
        test.startTest();
        string data = String.valueOf(ldObj);
        map<string, object> mapToSerialize = new map<string, object>();
        mapToSerialize.put('type', ldObj);
        //add you subtype like this
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock()); 
        string jsonstring = JSON.serialize(mapToSerialize);     
        DriverDetailController.processDriverDetails( jsonstring ,quotes);
        test.stopTest();   
    }
   
}