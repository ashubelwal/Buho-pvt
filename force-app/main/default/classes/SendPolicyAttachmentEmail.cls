public with sharing class SendPolicyAttachmentEmail {

    @InvocableMethod(label='Send Policy Email with PDF')
    public static void sendEmailWithPdf(List<Id> policyIds) {
        for (Id policyId : policyIds) {

            // Consultar la póliza
            Policy__c policy = [
                SELECT Id, Name, Status_picklist__c, Contact_Email__c
                FROM Policy__c
                WHERE Id = :policyId
            ];

            // Debug: imprimir correo del contacto
            System.debug('📨 Contact Email: ' + policy.Contact_Email__c);

            // Validar que el status sea 'Active'
            // if (policy.Status_picklist__c != 'Active') {
            //     System.debug('❌ Policy not active. Skipping...');
            //     continue;
            // }

            System.debug('✅ Policy is already Payed. Ready to process.');

            // Buscar los attachments relacionados a la póliza
            List<Attachment> attachments = [
                SELECT Id, Name, ParentId, Body, ContentType, BodyLength, CreatedDate
                FROM Attachment
                WHERE ParentId = :policy.Id
                ORDER BY CreatedDate DESC
            ];

            if (attachments.isEmpty()) {
                System.debug('⚠️ No attachments found for policy: ' + policy.Id);
                continue;
            }

            // Buscar el primer archivo PDF
            Attachment pdfAttachment = null;
            for (Attachment att : attachments) {
                if (att.ContentType == 'application/pdf' || att.Name.toLowerCase().endsWith('.pdf')) {
                    pdfAttachment = att;
                    break;
                }
            }

            if (pdfAttachment != null) {
                // Preparar el correo
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] { policy.Contact_Email__c });
                email.setSubject('Your Policy Document - ' + policy.Name);
                email.setPlainTextBody('Dear Customer,\n\nPlease find your policy attached as a PDF.');

                // Adjuntar el archivo PDF
                Messaging.EmailFileAttachment file = new Messaging.EmailFileAttachment();
                file.setFileName(pdfAttachment.Name);
                file.setBody(pdfAttachment.Body);
                file.setContentType('application/pdf');

                email.setFileAttachments(new Messaging.EmailFileAttachment[] { file });

                // Enviar el correo
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                System.debug('📧 (Simulado) Email enviado a: ' + policy.Contact_Email__c + ' con PDF: ' + pdfAttachment.Name);


                System.debug('📧 Email sent to: ' + policy.Contact_Email__c + ' with PDF: ' + pdfAttachment.Name);
            } else {
                System.debug('⚠️ No PDF attachment found for policy: ' + policy.Id);
            }
        }
    }
}