/*--------------------------------------------------------------------------
* Author: Techila Global Services Pvt Ltd.
* Test Class Name: TaskTrigger_Test
* Created Date: 23-November-2017
---------------------------------------------------------------------------- */

@isTest
public class TaskTrigger_Test {

    //Method to cover tasks with lead
    public static testMethod void validateLeadTask(){
        
        Lead objLead =new Lead();
        objLead.State ='Working';
        objLead.LastName ='test';
        objLead.Company ='test';
        objLead.Email = 'test@demo.com';
        insert objLead;
        
        Task objTask =new Task();
        objTask.WhoId =objLead.Id;
        objTask.Subject = 'Call';
        objTask.Status = 'Completed';
        insert objTask;
    }

    //Method to cover tasks with contact
    public static testMethod void validateContactTask(){
        
        Contact objContact = new Contact();
        objContact.FirstName = 'test';
        objContact.LastName = 'Name';
        objContact.Email = 'test@test.com';
        insert objContact;
        
        Task objTask =new Task();
        objTask.WhoId =ObjContact.Id;
        objTask.Subject = 'Call';
        objTask.Status = 'Completed';
        insert objTask;
    }
}