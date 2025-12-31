public class PolicyAutoRenewalEmailHandler implements Queueable, Database.AllowsCallouts {
    public Set<String> policyIdsSet;
    public Boolean addAttachment;

    public PolicyAutoRenewalEmailHandler(Set<String> policyIdsSet, Boolean addAttachment) {
        this.addAttachment = addAttachment;
        this.policyIdsSet = policyIdsSet;
    }

    public void execute(QueueableContext qc) {
        
        Mex_Insurance_Calloututility.sendEmail(policyIdsSet, addAttachment);
        
    }
}