import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getCustomData from '@salesforce/apex/AgencyController.getUserData';
import HAMBURGER_ICON from '@salesforce/resourceUrl/marketingHamburgerIcon';
import X_ICON from '@salesforce/resourceUrl/marketingXIcon';
import getNavigationMenuItems from '@salesforce/apex/NavigationMenuItemsController.getNavigationMenuItems';
import isGuestUser from '@salesforce/user/isGuest';
import basePath from '@salesforce/community/basePath';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

/**
 * This is a custom LWC navigation menu component.
 * Make sure the Guest user profile has access to the NavigationMenuItemsController apex class.
 */
export default class NavigationMenuCopy extends NavigationMixin(LightningElement) {
    @api buttonLabel;
    @api buttonRedirectPageAPIName;
    @api menuName;
    
    error;
    href = basePath;
    isLoaded;
    menuItems = [];
    publishedState;
    showHamburgerMenu;

    hamburgerIcon = HAMBURGER_ICON;
    xIcon = X_ICON;
    @track getUrl = 'https://www.mexinsurance.com/wp-content/uploads/2024/01/mexico-insurance-services-logo-small.png';
    @track partnerEmail;
    @track partnerId;
    @track partnerName;
    @track primaryColor = '#eee';

    @track
    items = [
       /* {
            id: 'managePayment',
            label: 'Manage Payment',
            value: 'ManagePayment',
        },*/
        {
            id: 'profile',
            label: 'Profile',
            value: 'profile',
        },
        {
            id: 'logout',
            label: 'Logout',
            value: 'logout',
        },
    ];


    @wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD, EMAIL_FIELD] })
    user;

    @wire(getCustomData, { 'recordId': USER_ID})
    customMetaData({data,error}){
        if(data){
            
            console.log('Custom Meta data',data);
            if(data?.Primary_Color__c != null && data?.Primary_Color__c != undefined ){
                this.primaryColor = `background-color: ${data.Primary_Color__c};`;
            }

            if(data?.Primary_Color__c != null && data?.Primary_Color__c != undefined ){
                this.partnerName = data.Partner_Name__c;
            }

            if(data?.Primary_Color__c != null && data?.Primary_Color__c != undefined ){
                this.partnerId = data.Partner_Id__c;
            }

            if(data?.Primary_Color__c != null && data?.Primary_Color__c != undefined ){
                this.partnerEmail = data.Partner_email__c;
            }

            if(data?.Primary_Color__c != null && data?.Primary_Color__c != undefined ){
                this.getUrl = data.Logo_URL__c;
            }
            
            console.log('primaryColor--->',this.primaryColor);
            console.log('getUrl--->',this.getUrl);
           
        }else{
            console.log('error',error);
        }
    }

    get logoUrl(){
        return getCustomData
    }
    get userName() {
        return getFieldValue(this.user.data, NAME_FIELD) != null ? getFieldValue(this.user.data, NAME_FIELD) : null;
    }

    get userEmail() {
        return getFieldValue(this.user.data, EMAIL_FIELD) != null ? getFieldValue(this.user.data, EMAIL_FIELD) : null;
    }

    @wire(getNavigationMenuItems, {
        menuName: '$menuName',
        publishedState: '$publishedState'
    })
    wiredMenuItems({ error, data }) {
        if (data && !this.isLoaded) {
            this.menuItems = data
                .map((item, index) => {
                    return {
                        target: item.Target,
                        id: index,
                        label: item.Label,
                        defaultListViewId: item.DefaultListViewId,
                        type: item.Type,
                        accessRestriction: item.AccessRestriction
                    };
                })
                .filter((item) => {
                    // Only show "Public" items if guest user
                    return (
                        item.accessRestriction === 'None' ||
                        (item.accessRestriction === 'LoginRequired' &&
                            !isGuestUser)
                    );
                });
            this.error = undefined;
            this.isLoaded = true;
        } else if (error) {
            this.error = error;
            this.menuItems = [];
            this.isLoaded = true;
            console.log(`Navigation menu error: ${JSON.stringify(this.error)}`);
        }
    }

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        const app =
            currentPageReference &&
            currentPageReference.state &&
            currentPageReference.state.app;
        if (app === 'commeditor') {
            this.publishedState = 'Draft';
        } else {
            this.publishedState = 'Live';
        }
    }

    handleClick() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: this.buttonRedirectPageAPIName
            }
        });
    }

    handleHamburgerMenuToggle(evt) {
        evt.stopPropagation();
        evt.preventDefault();
        if (this.showHamburgerMenu) {
            this.showHamburgerMenu = false;
        } else {
            this.showHamburgerMenu = true;
        }
    }

    connectedCallback(){
        console.log('In connectedcallback----');
        console.log('USER_ID',USER_ID);
        console.log('NAME_FIELD',NAME_FIELD);
        console.log('EMAIL_FIELD',EMAIL_FIELD);
        console.log('user check test');
    }

    // renderedCallBack(){
    //     var css= this.template.host.style;
    //     console.log('css-----',this.primaryColor);
    //     css.setProperty('--bgColor', this.primaryColor);
    //     console.log('css----- TESt', this.primaryColor);
    // }

    handleMenuSelect(event) {
    const selectedItemValue = event.detail.value;
    if (selectedItemValue === 'logout') {
        console.log('logout');
        // Redirige al logout y luego al login de /customer
        location.replace('https://at.mexinsurance.com/agency/secur/logout.jsp?retUrl=/customer/login');
        // También podrías usar dispatchEvent si manejas logout personalizado
        // this.dispatchEvent(new CustomEvent('logout'));
    } else if (selectedItemValue === 'profile') {
        console.log('profile');
        event.preventDefault();
        // Redirige al perfil del cliente
        location.replace('https://at.mexinsurance.com/customer/profile');
    } else {
        console.log('manage payment');
        // Aquí puedes agregar lógica si es necesario
    }
    }
}