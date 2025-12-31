trigger DriverAction on Driver__c (before insert, before Update) {
    if( trigger.isBefore && ( trigger.isInsert || trigger.isBefore )){
        for(Driver__c dr : trigger.new){
            if( dr.License_Country__c != null && dr.License_state__c != null && dr.license_number__c != null ){
                String countryCode = QuickQuotationCtrl.getCountryCode(dr.License_Country__c);
                String stateCode = QuickQuotationCtrl.getStateCode(dr.License_state__c);

                dr.LN_With_Country__c = ( countryCode != null? countryCode+'-':'' ) + ( stateCode != null? stateCode+'-':'' )+dr.license_number__c;
            }
        }
    }
}