import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class AgentPolicyOprations extends LightningElement {

    @track actionTypeDefault = false;    
    @track actionTypePolicy = false;
    @track actionTypeQuote = false;
    @track actionTypePolicyTerminate = false;
    stateContact = {}

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        console.log('In the wire method')
        this.actionTypePolicyTerminate = false;
        if (currentPageReference ) {
            let params = currentPageReference.state;            

            this.stateContact = {
                'id': params?.c__id,                
                'obj': params?.c__obj,
                'actionType': params?.c__action
            }

            console.log(' Params: ', this.stateContact)

            this.actionTypeDefault = Object.keys(params).length == 0 ? true : false;                              
            this.actionTypePolicy = params?.c__obj === 'policy' ? true : false;
            this.actionTypeQuote = params?.c__obj === 'quote' ? true : false;
            if(params?.c__obj === 'policy' &&  params?.c__action == 'TERMINATE'){

                console.log('Record Id0: ', sessionStorage.getItem('recordId'))
                console.log('Action type0: ', sessionStorage.getItem('actionType'))

                sessionStorage.setItem('recordId', params?.c__id);
                sessionStorage.setItem('actionType', params?.c__action);

                console.log('Record Id1: ', sessionStorage.getItem('recordId'))
                console.log('Action type1: ', sessionStorage.getItem('actionType'))
                this.actionTypePolicyTerminate = true;
                console.log('Loading data');
               
            }
            
        } else {
            this.actionTypePolicyTerminate = false;
            console.log('Params are not there')
        }
    }

    // connectedCallback() {
    //     this.actionTypePolicyTerminate = false;
    //     console.log('In the Connected call back', this.stateContact);
    // }

}