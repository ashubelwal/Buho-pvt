import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import AGENT_LOGO from '@salesforce/resourceUrl/menuLogoAgent';
import AGENT_MOBILE_LOGO from '@salesforce/resourceUrl/agentHamburgerMenuLogo';
import AZINSURANCE_LOGO from '@salesforce/resourceUrl/azinsurancelogo';
import AZINSURANCE_MOBILE_LOGO from '@salesforce/resourceUrl/marketingHamburgerMenuLogo';
import CUSTOMER_LOGO from '@salesforce/resourceUrl/menuLogoCustomer';
import CUSTOMER_MOBILE_LOGO from '@salesforce/resourceUrl/customerHamburgerMenuLogo';

import getBranding from "@salesforce/apex/customBranding.getBranding";
import Id from '@salesforce/user/Id';

export default class NavigationMenuLogo extends NavigationMixin(
    LightningElement
) {
    @api formfactor;
    @api page;    
    userId = Id;
    /**
     * the azInsuranceLogo (NavigationMenu Logo) pulled from static resources
     */

    connectedCallback () {
        console.log('userId', userId);
        let puserId = CurrentUser.id
        getBranding({'userId': puserId })
        .then(result => {
            console.log(result)
        })
        .catch( err => {
            console.log(err)
        })
    }

    @api
    set logo(value) {
        this.azInsuranceLogo = value;
    }

    get logo() {
        if (this.formfactor === 'hamburger') {
            switch (this.page) {
                case 'agent':
                    return AGENT_MOBILE_LOGO;
                case 'customer':
                    return CUSTOMER_MOBILE_LOGO;
                default:
                    return AZINSURANCE_MOBILE_LOGO;
            }
        }
        switch (this.page) {
            case 'agent':
                return AGENT_LOGO;
            case 'customer':
                return CUSTOMER_LOGO;
            default:
                return AZINSURANCE_LOGO;
        }
    }

    _azInsuranceLogo;

    handleClick(evt) {
        // use the NavigationMixin from lightning/navigation to perform the navigation.
        // prevent default anchor link since lightning navigation will be handling the click
        evt.stopPropagation();
        evt.preventDefault();
        // Navigate to the home page
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        });
    }
}