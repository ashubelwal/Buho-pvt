public class add_attachment {

    public static Policy__c policy1;
    public static list<id> pidlist;
    public static list<id> pidlist1;
    
    public static string sendpolicyid(list<id> policyid){
        
        string poid ;
        pidlist1 = policyid;
        for(id k:policyid){
            poid = k;
        }
       /* system.debug('    poid   '+poid);
        pagereference page= new pagereference('/apex/page/Declaration_Page_Insurance_controller?policyid='+poid);*/
        return poid;
        
    }
    
    
@future(callout = true)
public static void attachpdf(List<Id> policyIds) {
    try {
        // Query once outside loop
        List<Policy__c> policies = [
            SELECT Id, Name, Underwriter_picklist__c, Policy_Type_picklist__c 
            FROM Policy__c 
            WHERE Id IN :policyIds
        ];

        List<Attachment> attachmentsToInsert = new List<Attachment>();

        for (Policy__c policy : policies) {
            try {
                // Use your existing method to get the correct VF URL
                String pageUrl = Mex_PolicyEditController.preViewPdfAction(policy.Id);

                if (String.isNotBlank(pageUrl)) {
                    // Extract page name from URL
                    String pageName = pageUrl.replace('/apex/', '');

                    // Create dynamic PageReference using URL
                    PageReference pdfPage = new PageReference('/apex/' + pageName);
                    pdfPage.getParameters().put('id', policy.Id);

                    Blob pdfBlob = pdfPage.getContent();

                    Attachment attachment = new Attachment(
                        ParentId = policy.Id,
                        Name = policy.Name + '.pdf',
                        Body = pdfBlob
                    );
                    attachmentsToInsert.add(attachment);
                }
            } catch (Exception innerEx) {
                System.debug('Failed to attach PDF for policy ' + policy.Id + ': ' + innerEx.getMessage());
            }
        }

        if (!attachmentsToInsert.isEmpty()) {
            insert attachmentsToInsert;
        }

    } catch (Exception ex) {
        System.debug('Main error in attachpdf: ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
    }
}


}