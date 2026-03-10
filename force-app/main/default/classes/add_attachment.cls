/**
 * Class: add_attachment
 * Purpose:
 * - Provide utilities to work with Policy__c IDs and generate/attach PDF documents to Policy__c records.
 *
 * Key Methods:
 * - sendpolicyid(List<Id> policyid): Returns the last Id from the provided list (legacy helper).
 * - attachpdf(List<Id> policyIds) @future(callout=true): For each Policy__c in the list,
 *   computes the Visualforce page URL via Mex_PolicyEditController.preViewPdfAction,
 *   renders the page to PDF, and inserts the PDF as an Attachment on the Policy__c.
 *
 * Notes:
 * - Uses a single SOQL query and bulkifies Attachment inserts.
 * - Uses PageReference.getContent() which requires asynchronous/future context for callouts.
 * - Errors per record are caught and logged to avoid failing the entire transaction.
 *
 * Considerations:
 * - Ensure the running user has access to the Visualforce page and controller.
 * - In Lightning Experience, consider migrating from Attachment to ContentVersion for files.
 * - Mex_PolicyEditController.preViewPdfAction must return a valid VF URL path (e.g. /apex/SomePage).
 */
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
    // Asynchronously renders a VF page to PDF for each Policy__c and attaches it to the policy record.
    // Bulk-safe: queries all policies in a single SOQL and inserts attachments in a single DML.
    // Exceptions per policy are handled individually to maximize successful inserts.
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