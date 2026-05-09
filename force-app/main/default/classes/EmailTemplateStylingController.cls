public without sharing class EmailTemplateStylingController {
    public User currentUser { get; set; }
    
    public EmailTemplateStylingController() {
        this.currentUser = [SELECT Id, Name, Logo_URL__c, Partner_Id__c, Partner_Name__c, Partner_email__c, Website__c, Agent_Id__c, 
                           City, State, Country, PostalCode, Street 
                           FROM User 
                           WHERE Id = :UserInfo.getUserId()];
    }
    
    public String getLogoUrl() {
        return (String.isNotBlank(currentUser.Logo_URL__c)) ? currentUser.Logo_URL__c : 'https://www.mexinsurance.com/wp-content/uploads/2023/11/cropped-Logo-1-2048x312.png';
    }
    
    public String getPartnerName() {
        return (String.isNotBlank(currentUser.Partner_Name__c)) ? currentUser.Partner_Name__c : 'MexInsurance®';
    }
    
    public String getPartnerId() {
        return (String.isNotBlank(currentUser.Partner_Id__c)) ? currentUser.Partner_Id__c.toUpperCase() : 'MEXICO INSURANCE SERVICES, INC.';
    }
    
    public String getAgentId() {
        return (String.isNotBlank(currentUser.Agent_Id__c)) ? currentUser.Agent_Id__c : '0G35864';
    }
    
    public String getWebsite() {
        String site = currentUser.Website__c;
        if (String.isNotBlank(site)) {
            if (!site.startsWith('http')) {
                site = 'https://' + site;
            }
            return site;
        }
        return 'https://www.mexinsurance.com/';
    }
    
    public String getWebsiteLabel() {
        if (String.isNotBlank(currentUser.Website__c)) {
            String ws = currentUser.Website__c.replace('https://', '').replace('http://', '').replace('www.', '');
            if (ws.endsWith('/')) {
                ws = ws.substring(0, ws.length() - 1);
            }
            return ws.toUpperCase();
        }
        return 'MEXINSURANCE.COM';
    }
    
    public String getUserName() {
        return currentUser.Name;
    }
    
    public String getAddress() {
        List<String> parts = new List<String>();
        if (String.isNotBlank(currentUser.Street)) parts.add(currentUser.Street);
        if (String.isNotBlank(currentUser.City)) parts.add(currentUser.City);
        if (String.isNotBlank(currentUser.State)) parts.add(currentUser.State);
        if (String.isNotBlank(currentUser.PostalCode)) parts.add(currentUser.PostalCode);
        if (String.isNotBlank(currentUser.Country)) parts.add(currentUser.Country);
        return String.join(parts, ', ');
    }
}
