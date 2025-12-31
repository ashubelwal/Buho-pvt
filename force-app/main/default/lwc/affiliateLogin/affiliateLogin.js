import { LightningElement, track } from 'lwc';
import authenticateUser from '@salesforce/apex/AffiliatePortalController.authenticateUser';
import validateSessionThroughSessionId from '@salesforce/apex/AffiliatePortalController.validateSessionThroughSessionId';
import getContactData from '@salesforce/apex/AffiliatePortalController.getContactData';

export default class AffiliateLogin extends LightningElement {
    @track username = '';
    @track password = '';
    @track contact;
    @track showLoginForm = true;
    @track errorMessage = '';
    @track isLoading = true;


    // Handle changes in the input fields
    handleUsernameChange(event) {
        this.username = event.target.value;
    }

    handlePasswordChange(event) {
        this.password = event.target.value;
    }

    // Handle the login process
    handleLogin() {
            this.isLoading = true;
        authenticateUser({ username: this.username, password: this.password })
            .then(result => {
                console.log(result)
                this.contact = result;
                this.showLoginForm = false;
                this.errorMessage = '';

                document.cookie = `sessionId=${result.Session_Id__c}; path=/; max-age=${3600 * 6}; secure`;
                console.log('Saving session id in cookie', result.Session_Id__c);
                console.log('Check string', document.cookie);
                this.isLoading = false;
            })
            .catch(error => {
                this.errorMessage = error.body.message || 'Invalid Username or Password';
                this.isLoading = false;
            });
    }

    handleLoginWithSessionId(sessionId) {
        
        getContactData({ 'sessionId': sessionId })
            .then((result) => {
                if (result) {
                    this.contact = result;
                    this.showLoginForm = false;
                }
            })
            .catch((error) => {
                this.errorMessage = error.body.message || 'Please login again';
 
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
                       console.log('Inside if');
                        this.showLoginForm = true;
                    } 
                   else {
                       console.log('inside else');
                       this.handleLoginWithSessionId(sessionId);
                    }
                    this.isLoading = false;
                })
            .catch((error) => {
                console.log('Error', error);
                this.error = 'Please login again';
                this.isLoading = false;
            })
        } else {
            this.showLoginForm = true;
            this.isLoading = false;
        }
    }

}