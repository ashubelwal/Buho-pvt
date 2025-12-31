import { LightningElement,api } from 'lwc';
import updateValues from '@salesforce/apex/MEX_DataValidationBatch.updateAccountRecords';

export default class MexAcknowledged extends LightningElement {

@api
statusValue;
@api
recordId;
showMessage = false;
loadMessage = false;
get Pagemessage(){
    return this.showMessage?
    {
        'Header':'Thank You!',
        'SubNote':'We have successfully captured your response and we will very soon update our system. '
    }:
    {
        'Header':'Already Submitted!',
        'SubNote':'You have already submitted your response. For further inquiries, feel free to contact us.'
    };
}

imgUrl = 'https://mexinsurance--ca.sandbox.file.force.com/servlet/servlet.ImageServer?id=0158I000000BDJ7&oid=00D8I0000008h1W&lastMod=1682667043000';

    connectedCallback() {

        console.log(this.statusValue);
        console.log(this.recordId);

        updateValues({'statusValue':this.statusValue,'recordId':this.recordId})
        .then((result)=>{
            console.log(result);
            result = JSON.parse(result);
            if (result.isSuccess) {
                this.showMessage = true;
                this.loadMessage = true;
                
            }else{
                this.showMessage = false;
                this.loadMessage = true;
            }
        })
        .catch((error)=>{
            
        });
    }

}