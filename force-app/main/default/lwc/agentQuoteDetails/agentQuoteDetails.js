import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import searchQuoteDeatails from '@salesforce/apex/AgentAppController.searchDetails';
export default class AgentQuoteDetails extends LightningElement {

    @track quoteDetails =[] ;
    stateQuote;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference ) {
            let params = currentPageReference.state;            

            this.stateQuote = {
                'id': params?.c__id,                
                'obj': params?.c__obj,
                'actionType': params?.c__action
            }
            console.log(params?.c__obj);
            console.log('ID--->',params?.c__id);
            if(params?.c__id != null){
                searchQuoteDeatails({'searchKey':params?.c__id, 'agencyId':''})
                .then((result) => {
                    let data = JSON.parse(result);
                    console.log(data);
                    if(data.Quote){
                        this.quoteDetails = JSON.parse(data.Quote);
                        console.log('Quote Details-->', JSON.parse(data.Quote));
                        console.log('Quote Details-->', this.quoteDetails);
                    }else{
                        console.log('Error Quote iS Empty...........');
                    }
                    
                })
                .catch((error) => {
                    console.log(error);
                })
            }else{
                console.log('Id is not there in URl');
            }
        } else {
            console.log('Params are not there')
        }
    }

    handleViewQuote(){
        console.log('handle View Quote-->>');
        console.log(this.stateQuote.id);
        window.location.replace(`https://mexinsurance--ca.sandbox.lightning.force.com/${this.stateQuote.id}`);
    }


}