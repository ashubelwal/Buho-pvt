public without sharing class BuhoLoginFlowController {

    private static final String TARGET_SITE_URL  = 'https://u.gobuho.com';

    public String  frontdoorUrl    { get; private set; }
    

    public BuhoLoginFlowController() {}

    public void finishFlow() {
        Auth.SessionManagement.finishLoginFlow();
        frontdoorUrl = TARGET_SITE_URL;
    }

    
}