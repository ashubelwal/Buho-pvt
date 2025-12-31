import { LightningElement } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

export default class AgentDriverOpration extends NavigationMixin(LightningElement) {


    handleDrawerOprations = (event) => {
        let state = {}
        console.log('Closing')
        let dataSets = event.target.dataset;         
        if( dataSets?.id != ' ' && dataSets?.actiontype != ' ' &&  dataSets?.obj != '') {            
            console.log('state')
            state = { c__obj : dataSets?.obj, c__action : dataSets?.actiontype, c__id : dataSets?.id }                        
            this.navigateTo('standard__navItemPage', 'Contact_Detail', state);             
        }        
    }

    navigateTo = (type, apiName, state) => {        
        this[NavigationMixin.Navigate]({
            type: type,
            attributes: {
                apiName: apiName
            },
            state: state
        });
    }
}