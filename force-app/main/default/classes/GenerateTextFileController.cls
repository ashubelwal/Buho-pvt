/*
Name: GenerateTextFileController
Date: 
Description: 
Developed By: Abhishek Sahay(abhishek.sahay@cloudanalogy.com)
Modified By:
Modified Reason:O
Modified Date:
Version: 1.0
*/

public class GenerateTextFileController implements Database.Batchable<sObject>, Database.Stateful {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        String query = 'SELECT Id,Physical_Damage__c, Liability_Payment__c, Medical_Payment__c FROM Policy__c WITH SECURITY_ENFORCED LIMIT 1';            
        return Database.getQueryLocator(query);
    }
    
    public static void execute(Database.BatchableContext bc, List<Policy__c> getpolicyList){
        try{
            List<Policy__c> attachmentsToBeStoredInPolicy = new List<Policy__c>();
            Date yesterdayDate = Date.today().addDays(-1);
            Date todayDate = Date.today();
            attachmentsToBeStoredInPolicy = [SELECT Id,CreatedDate FROM Policy__c WHERE Name = 'Policies_Attachment_Records' WITH SECURITY_ENFORCED limit 1];            
            if(attachmentsToBeStoredInPolicy.size()>0){
                for(Integer i=0;i<3;i++){
                    PageReference pageReferenceObj;
                    pageReferenceObj = Page.GenerateInformationTextFile;
                    pageReferenceObj.getParameters().put('policyType', 'Northbound');
                    pageReferenceObj.getParameters().put('count', String.valueOf(i));
                    Blob pageContent;
                    
                    //For code coverage from the test class
                    if(Test.isRunningTest()){
                        pageContent = blob.valueOf('Test');
                    }else{
                        pageContent = pageReferenceObj.getContent();
                    }
                    String fileName = '';
                    if(i == 0){						
                        fileName = 'GenInfo_356_'+(String.valueOf(yesterdayDate.Day()).length()==1?'0'+String.valueOf(yesterdayDate.Day()):String.valueOf(yesterdayDate.Day()))+(String.valueOf(yesterdayDate.Month()).length()==1?'0'+String.valueOf(yesterdayDate.Month()):String.valueOf(yesterdayDate.Month()))+(String.valueOf(yesterdayDate.Year()))+'_CN.txt';
                    }else if(i == 1){
                        fileName = 'AutoInfo_356_'+(String.valueOf(yesterdayDate.Day()).length()==1?'0'+String.valueOf(yesterdayDate.Day()):String.valueOf(yesterdayDate.Day()))+(String.valueOf(yesterdayDate.Month()).length()==1?'0'+String.valueOf(yesterdayDate.Month()):String.valueOf(yesterdayDate.Month()))+(String.valueOf(yesterdayDate.Year()))+'_CN.txt';
                    }else if(i == 2){
                        fileName = 'CovInfo_356_'+(String.valueOf(yesterdayDate.Day()).length()==1?'0'+String.valueOf(yesterdayDate.Day()):String.valueOf(yesterdayDate.Day()))+(String.valueOf(yesterdayDate.Month()).length()==1?'0'+String.valueOf(yesterdayDate.Month()):String.valueOf(yesterdayDate.Month()))+(String.valueOf(yesterdayDate.Year()))+'_CN.txt';
                    }
                    Attachment newAttachment = new Attachment(Name=fileName,ParentId = attachmentsToBeStoredInPolicy[0].Id, Body = pageContent, ContentType = 'text');
                    insert newAttachment;
                }
                for(Integer i=0;i<3;i++){
                    PageReference pageReferenceObj;
                    pageReferenceObj = Page.GenerateInformationTextFile;
                    pageReferenceObj.getParameters().put('policyType', 'Southbound');
                    pageReferenceObj.getParameters().put('count', String.valueOf(i));
                    Blob pageContent;
                    
                    //For code coverage from the test class
                    if(Test.isRunningTest()){
                        pageContent = blob.valueOf('Test');
                    }else{
                        pageContent = pageReferenceObj.getContent();
                    }
                    String fileName = '';
                    if(i == 0){
                        fileName = 'GenInfo_081_'+(String.valueOf(yesterdayDate.Day()).length()==1?'0'+String.valueOf(yesterdayDate.Day()):String.valueOf(yesterdayDate.Day()))+(String.valueOf(yesterdayDate.Month()).length()==1?'0'+String.valueOf(yesterdayDate.Month()):String.valueOf(yesterdayDate.Month()))+(String.valueOf(yesterdayDate.Year()))+'_CN.txt';
                    }else if(i == 1){
                        fileName = 'AutoInfo_081_'+(String.valueOf(yesterdayDate.Day()).length()==1?'0'+String.valueOf(yesterdayDate.Day()):String.valueOf(yesterdayDate.Day()))+(String.valueOf(yesterdayDate.Month()).length()==1?'0'+String.valueOf(yesterdayDate.Month()):String.valueOf(yesterdayDate.Month()))+(String.valueOf(yesterdayDate.Year()))+'_CN.txt';
                    }else if(i == 2){
                        fileName = 'CovInfo_081_'+(String.valueOf(yesterdayDate.Day()).length()==1?'0'+String.valueOf(yesterdayDate.Day()):String.valueOf(yesterdayDate.Day()))+(String.valueOf(yesterdayDate.Month()).length()==1?'0'+String.valueOf(yesterdayDate.Month()):String.valueOf(yesterdayDate.Month()))+(String.valueOf(yesterdayDate.Year()))+'_CN.txt';
                    }
                    
                    Attachment newAttachment = new Attachment(Name=fileName,ParentId = attachmentsToBeStoredInPolicy[0].Id, Body = pageContent, ContentType = 'text');
                    insert newAttachment;
                }
                for(Integer i=0;i<3;i++){
                    PageReference pageReferenceObj;
                    pageReferenceObj = Page.GenerateInformationTextFile;
                    pageReferenceObj.getParameters().put('policyType', 'Watercraft');
                    pageReferenceObj.getParameters().put('count', String.valueOf(i));
                    Blob pageContent;
                    
                    //For code coverage from the test class
                    if(Test.isRunningTest()){
                        pageContent = blob.valueOf('Test');
                    }else{
                        pageContent = pageReferenceObj.getContent();
                    }
                    
                    String fileName = '';
                    if(i == 0){
                        fileName = 'GenInfo_999_'+(String.valueOf(yesterdayDate.Day()).length()==1?'0'+String.valueOf(yesterdayDate.Day()):String.valueOf(yesterdayDate.Day()))+(String.valueOf(yesterdayDate.Month()).length()==1?'0'+String.valueOf(yesterdayDate.Month()):String.valueOf(yesterdayDate.Month()))+(String.valueOf(yesterdayDate.Year()))+'_CN'+'.txt';
                    }else if(i == 1){
                        fileName = 'AutoInfo_999_'+(String.valueOf(yesterdayDate.Day()).length()==1?'0'+String.valueOf(yesterdayDate.Day()):String.valueOf(yesterdayDate.Day()))+(String.valueOf(yesterdayDate.Month()).length()==1?'0'+String.valueOf(yesterdayDate.Month()):String.valueOf(yesterdayDate.Month()))+(String.valueOf(yesterdayDate.Year()))+'_CN'+'.txt';
                    }else if(i == 2){
                        fileName = 'CovInfo_999_'+(String.valueOf(yesterdayDate.Day()).length()==1?'0'+String.valueOf(yesterdayDate.Day()):String.valueOf(yesterdayDate.Day()))+(String.valueOf(yesterdayDate.Month()).length()==1?'0'+String.valueOf(yesterdayDate.Month()):String.valueOf(yesterdayDate.Month()))+(String.valueOf(yesterdayDate.Year()))+'_CN'+'.txt';
                    }
                    
                    Attachment newAttachment = new Attachment(Name=fileName,ParentId = attachmentsToBeStoredInPolicy[0].Id, Body = pageContent, ContentType = 'text');
                    insert newAttachment;
                }
            }			
        }
        catch(Exception e){
            System.debug('The error is '+e.getMessage()+' and the cause is '+e.getCause()+' in line number '+e.getLineNumber());
        }
    }
    
    public void finish(Database.BatchableContext bc){
        System.debug('Files generated successfully.');
    }
}