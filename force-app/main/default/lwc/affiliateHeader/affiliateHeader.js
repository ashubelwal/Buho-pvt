import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getAffiliateUser from '@salesforce/apex/AffiliateController.getAffiliateUser';
import validateSessionThroughSessionId from '@salesforce/apex/AffiliatePortalController.validateSessionThroughSessionId';

export default class AffiliateHeader extends LightningElement {

    affiliateCode;
    affiliateUserInfo;
    ownerName;
    ownerPhoto;
    agencyLogo;
    isAffiliate = true;
    isFrame = false;
    frame;
    loginUrl = '/user-login';
    isLoggedIn = false;
    isLoggedOut = false;
    @track loginButtonLabel = 'Login';
    @track checkSessionId;
    @track pageUrl;

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            this.affiliateCode = currentPageReference.state.code;
            this.frame = currentPageReference.state.frame;
            console.log('Frame console in header', this.frame);
            console.log('Agent code in header', this.affiliateCode);
            if (this.affiliateCode) {
                this.isAffiliate = true;
                this.fetchAffiliateUser();
            } else {
                this.isAffiliate = false;
            }
            if (this.frame) {
                this.isFrame = true;
            } else {
                this.isFrame = false;
            }
            console.log(this.affiliateCode);
            console.log(this.isAffiliate);

            const url = window.location.pathname || ''; // Get the current page URL path

            if (url.includes('dashboard') || url.includes('policy-edit-renew')) {
                this.isLoggedOut = true;
                this.isLoggedIn = false;
            } else if (url.includes('user-login')) {
                this.isLoggedOut = false;
                this.isLoggedIn = false; // Disable both buttons
            } else if (url.includes('terminate')) {
                this.isLoggedOut = true;
                this.isLoggedIn = false; // Disable both buttons
            }else {
                this.isLoggedIn = true;
                this.isLoggedOut = false;
            }
        }
    }

    fetchAffiliateUser() {
        console.log('Working')
        getAffiliateUser({ 'affiliateId': this.affiliateCode })
            .then(result => {
                const data = JSON.parse(JSON.stringify(result));
                this.affiliateUserInfo = JSON.parse(data);
                console.log('Data getting from Apex');

                console.log(this.affiliateUserInfo)

                this.ownerName = this.affiliateUserInfo?.Owner_Name__c;
                this.ownerPhoto = this.affiliateUserInfo?.Owner_Photo__c;
                this.agencyLogo = this.affiliateUserInfo?.Agency_Logo__c;
                this.agentFee = this.affiliateUserInfo?.Agent_Fee__c;

                if (this.affiliateCode != undefined && this.frame != undefined ) {
                    this.loginUrl = `/user-login?code=${this.affiliateCode}&frame=true`;
                } else if (this.affiliateCode != undefined & this.frame == undefined) {
                    this.loginUrl = `/user-login?code=${this.affiliateCode}`;
                } else if (this.affiliateCode == undefined & this.frame != undefined) {
                    this.loginUrl = `/user-login?frame=true`;
                } else {
                    this.loginUrl = `/user-login`;
                }

                let currentUrl = window.location.origin;

                
                if (this.affiliateCode != undefined && this.frame != undefined ) {
                    this.pageUrl = `${currentUrl}/affiliate?code=${this.affiliateCode}&frame=true`;
                } else if (this.affiliateCode != undefined & this.frame == undefined) {
                    this.pageUrl = `${currentUrl}/affiliate?code=${this.affiliateCode}`;
                } else if (this.affiliateCode == undefined & this.frame != undefined) {
                    this.pageUrl = `${currentUrl}/affiliate?frame=true`;
                } else {
                    this.pageUrl = `${currentUrl}/affiliate`;
                }

                console.log(this.ownerName);
                console.log(this.ownerPhoto);
                console.log(this.agentFee);
                console.log(this.agencyLogo);

            }).catch(error => {
                this.isAffiliate = false;
                console.log(error);
            });
    }


    async connectedCallback() {
        console.log('Cookie in the agent dashboard', document.cookie);
        const cookies = document.cookie.split('; ').reduce((acc, cookie) => {
            const [key, ...valueParts] = cookie.split('=');
            acc[key] = valueParts.join('=');
            return acc;
        }, {});
    
        const sessionId = cookies.sessionId;
        console.log('Session Id', sessionId);

        if (sessionId !== undefined) {
            console.log('inside validating session login');
           await validateSessionThroughSessionId({ 'sessionId': sessionId})
               .then((result) => {
                   console.log('Data fetched');
                   const data = JSON.parse(JSON.stringify(result));
                   if (data.toLowerCase() === 'false') {
                       this.loginButtonLabel = 'Login';
                    } 
                   else {
                       this.loginButtonLabel = 'Dashboard';
                       const url = window.location.pathname || '';
                       if (url.includes('user-login')) {
                        this.isLoggedOut = true;
                    }
                    }
                })
               .catch((error) => {
                this.loginButtonLabel = 'Login';
                console.log('Error', error);
                this.error = 'Please login again';
            })
        } else {
            this.loginButtonLabel = 'Login';

        }
        this.monitorSessionCookie();
    }

    handleLogOut() {
        // Deleting the sessionId cookie
       document.cookie = "sessionId=; path=/; max-age=0; secure";
       location.reload();
    }
    
    monitorSessionCookie() {
        const cookies = document.cookie.split('; ').reduce((acc, cookie) => {
            const [key, ...valueParts] = cookie.split('=');
            acc[key] = valueParts.join('=');
            return acc;
        }, {});
    
        const sessionId = cookies.sessionId;
        console.log('Session Id', sessionId);

        this.checkSessionId = sessionId;

        // Set up an interval to check the cookie every second
        this.cookieInterval = setInterval(() => {
            const cookies = document.cookie.split('; ').reduce((acc, cookie) => {
                const [key, ...valueParts] = cookie.split('=');
                acc[key] = valueParts.join('=');
                return acc;
            }, {});
        
            const sessionId = cookies.sessionId;
            const currentSessionId = sessionId;
            if (this.checkSessionId !== currentSessionId) {
                this.checkSessionId = currentSessionId;

                // Trigger the method when the session ID changes
                this.handleChangedSessionUpdate();
            }
        }, 1000); // Check every second
    }
    
    async handleChangedSessionUpdate() {

        console.log('Runnnninnngggg');
      
        const cookies = document.cookie.split('; ').reduce((acc, cookie) => {
            const [key, ...valueParts] = cookie.split('=');
            acc[key] = valueParts.join('=');
            return acc;
        }, {});
    
        const sessionId = cookies.sessionId;

        if (sessionId !== undefined) {
            console.log('inside validating session login');
           await validateSessionThroughSessionId({ 'sessionId': sessionId})
               .then((result) => {
                   console.log('Data fetched');
                   const data = JSON.parse(JSON.stringify(result));
                   if (data.toLowerCase() === 'false') {
                      // this.loginButtonLabel = 'Login';
                    } 
                   else {
                       this.loginButtonLabel = 'Dashboard';
                       const url = window.location.pathname || '';
                       if (url.includes('user-login')) {
                        this.isLoggedOut = true;
                        }
                    }
                })
               .catch((error) => {
               // this.loginButtonLabel = 'Login';
                console.log('Error', error);
                this.error = 'Please login again';
            })
        } else {
           // this.loginButtonLabel = 'Login';

        }
    }

    handleImageClick() {
        location.replace(this.pageUrl);
    }

}