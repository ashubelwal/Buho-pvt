public class BatchTosendQuoteEmail implements Database.Batchable<sObject>, Database.AllowsCallouts{
    set<String> policyIdset = new set<String>();
    public boolean add_attachment;
    public BatchTosendQuoteEmail( set<String> policyIdset, Boolean add_attachment ) {
        this.policyIdset = policyIdset;
        this.add_attachment = add_attachment;
    }
    public BatchTosendQuoteEmail( set<String> policyIdset) {
        this.policyIdset = policyIdset;
        this.add_attachment = false;
    }


    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Name, Contact__c, Yellow_Card__c, Underwriter_picklist__c, Contact__r.Email, Policy_Type_picklist__c 
                                        FROM Policy__c 
                                        WHERE (Id IN: policyIdset OR Test_Policy_Id__c IN: policyIdset) 
                                        AND  Contact__r.Email != null ]);
    } 
   
    public void execute(Database.BatchableContext BC, List<Policy__c> scope){
        String attachmentName = scope[0].Name;
        String attachmentName2;
        if( attachmentName != null && attachmentName.contains('-')){
            attachmentName = attachmentName.replaceAll('-', '_');
        }
        attachmentName2 = attachmentName;
        attachmentName = attachmentName+'.Pdf';
		System.debug('in Execute');
        System.debug( !add_attachment);
        if( !add_attachment ){
            if (scope[0].Yellow_Card__c != 'Yes') {
                QuickQuotationCtrl.sendQuoteEmail( scope[0].Id, attachmentName, scope[0].Contact__c, scope[0].Contact__r.Email, scope[0].Policy_Type_picklist__c, scope[0].Underwriter_picklist__c);
            } else {
                QuickQuotationCtrl.sendQuoteEmailWithYellowCard(scope[0].Id, attachmentName, scope[0].Contact__c, scope[0].Contact__r.Email, scope[0].Policy_Type_picklist__c, scope[0].Underwriter_picklist__c, attachmentName2);
            }
        }else if( add_attachment ){
            try{
                PageReference pref;
                if( scope[0].Policy_Type_picklist__c == 'Northbound'){
                    pref = page.Declaration_Page_Insurance_2;
                    if (scope[0].Yellow_Card__c == 'Yes') {
                        Mex_NewLeadProcess.generatePDF(scope[0].Id, attachmentName2+'_Yellow_Card');
                    }
                }else if( scope[0].Policy_Type_picklist__c == 'Driver License' ){
                    pref = page.policy_declaration_driver_license;
                }else if( scope[0].Policy_Type_picklist__c == 'Watercraft' ){
                    pref = page.watercraft_policy_declaration_Page;
                }else if( scope[0].Policy_Type_picklist__c == 'Automobile' && scope[0].Underwriter_picklist__c != null && scope[0].Underwriter_picklist__c == 'Chubb' ){
                    pref = page.Southbound_PolicyDec_Chubb;
                }else if( scope[0].Policy_Type_picklist__c == 'Automobile' && scope[0].Underwriter_picklist__c != null && scope[0].Underwriter_picklist__c == 'Mapfre' ){
                    pref = page.Southbound_PolicyDeclarationPage_Mapfre;
                }else if( scope[0].Policy_Type_picklist__c == 'Automobile' && scope[0].Underwriter_picklist__c != null && scope[0].Underwriter_picklist__c == 'Qualitas' ){
                    pref = page.Southbound_PolicyDecPage_Qualitas;
                }else if( scope[0].Policy_Type_picklist__c == 'RV' && scope[0].Underwriter_picklist__c != null && scope[0].Underwriter_picklist__c == 'Chubb' ){
                    pref = page.Southbound_Chubb_RV;
                }else if( scope[0].Policy_Type_picklist__c == 'RV' && scope[0].Underwriter_picklist__c != null && scope[0].Underwriter_picklist__c == 'Mapfre' ){
                    pref = page.Southbound_Mapfre_RV;
                }else if( scope[0].Policy_Type_picklist__c == 'RV' && scope[0].Underwriter_picklist__c != null && scope[0].Underwriter_picklist__c == 'Qualitas' ){
                    pref = page.Southbound_Qualitas_RV;
                }else if( scope[0].Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV' && scope[0].Underwriter_picklist__c != null 
                    && scope[0].Underwriter_picklist__c == 'Mapfre' ){
                    pref = page.Southbound_Mapfre_Motorcycle;
                }else if( scope[0].Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV' && scope[0].Underwriter_picklist__c != null 
                    && scope[0].Underwriter_picklist__c == 'Qualitas' ){
                    pref = page.Southbound_Qualitas_Motorcycle;
                }else if( scope[0].Policy_Type_picklist__c == 'Motorcycle/Street Legal ATV' && scope[0].Underwriter_picklist__c != null 
                    && scope[0].Underwriter_picklist__c == 'Chubb' ){
                    pref = page.Southbound_ChubbMotorcycle;
                }else if( scope[0].Underwriter_picklist__c != null && scope[0].Underwriter_picklist__c == 'Mapfre' ){
                    pref = page.Southbound_PolicyDeclarationPage_Mapfre;
                }else if( scope[0].Underwriter_picklist__c != null && scope[0].Underwriter_picklist__c == 'Qualitas' ){
                    pref = page.Southbound_PolicyDecPage_Qualitas;
                }else if(  scope[0].Underwriter_picklist__c != null && scope[0].Underwriter_picklist__c == 'Chubb' ){
                    pref = page.Southbound_PolicyDec_Chubb;
                }
                
                pref.getParameters().put('id',scope[0].Id);
                pref.setRedirect(true);
                Blob body = null;
                try{
                    body = pref.getContent();
                }catch( Exception e ){
                    System.debug('---Exception----'+e.getMessage());
                }
                
                Attachment attachment = new Attachment();
                attachment.Body = body;
                attachment.Name = attachmentName;
                attachment.ParentId = scope[0].Id; 
                insert attachment;
            }catch( Exception e){
                System.debug('---Exception----'+e.getMessage());
            }
        }
    }
   
    public void finish(Database.BatchableContext BC){
    }
}