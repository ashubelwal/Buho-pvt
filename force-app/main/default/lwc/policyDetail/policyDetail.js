import {api, LightningElement } from 'lwc';
import image from '@salesforce/resourceUrl/mexinsurance_assets';
import community_Url from '@salesforce/label/c.community_Url';
import sendEmailDocumentAction from '@salesforce/apex/Mex_QuickQuoteCommonController.sendEmailDocumentAction';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import complete from '@salesforce/label/c.TR_Complete';
import theinsurancepacket from '@salesforce/label/c.TR_The_insurance_packet_is_on_its_way_to';
import important from '@salesforce/label/c.TR_Important';
import youraccountisready from '@salesforce/label/c.TR_Your_Account_is_ready_to_go';
import checkyouremail from '@salesforce/label/c.TR_Check_your_email_for_the_link_button';
import autoinsurance from '@salesforce/label/c.TR_Auto_Insurance';
import homeinnsuranceformex from '@salesforce/label/c.TR_Home_Insurance_for_Mexico';
import confirmthedates from '@salesforce/label/c.TR_Confirm_the_dates_and_type_of_coverage_and_pay_online_via_credit_card';
import medicalinsurance from '@salesforce/label/c.TR_Medical_Insurance';
import downloadyour from '@salesforce/label/c.TR_Download_your_insurance_policy_immediately_and_print_it_out';
import grabyourvehicle from '@salesforce/label/c.TR_Grab_your_vehicle_s_VIN_number';
import policy from '@salesforce/label/c.TR_Policy';
import MYMEXINSURANCE from '@salesforce/label/c.TR_MY_MEXINSURANCE';
import Success from '@salesforce/label/c.TR_Success';
import Emailsentsuccessfully from '@salesforce/label/c.TR_Email_sent_successfully';
import fetchPolicyDetails from '@salesforce/apex/Mex_NewLeadProcess.fetchPolicyDetails';


export default class PolicyDetail extends NavigationMixin(LightningElement) {
     label = {
        complete,theinsurancepacket,policy,important,youraccountisready,Success,Emailsentsuccessfully,checkyouremail,autoinsurance,homeinnsuranceformex,confirmthedates,medicalinsurance,downloadyour,grabyourvehicle,MYMEXINSURANCE,
    };

    @api policyName;
    @api communityUser;
    roundCar = image + '/images/icon-round-car.svg';
    roundHouse = image + '/images/icon-round-house.svg'
    roundSteering = image + '/images/icon-round-steering.svg'
    
    async connectedCallback() {
        console.log("policyName ", this.policyName);
         console.log("policyName ", JSON.stringify( this.policyName));
        let policyIdSet = [this.policyName.PolicyId];
        console.log(window.dataLayer);
        
        if( this.policyName ){
            if (!this.communityUser) {
                console.log('OUTPUT : NOT Community--');
                let eventExist = window.dataLayer.find((data) => data.event === 'purchase');
                console.log('OUTPUT : NOT CommeventExistunity--' + eventExist);
                if (eventExist == undefined){
                    fetchPolicyDetails({'policyId':this.policyName.PolicyId})
                    .then((result)=>{
                        if(result){
                            let parseData = JSON.parse(result);
                            console.log
                            window.dataLayer.push({

                                event: "purchase",
                                step_number: 'step_13',
                                step_name: 'order_confirmation', 
                                insurance_category: 'RV', 
                                ecommerce: {
                                    transaction_id: parseData.transactionId,
                                    affiliation: parseData.policyId,
                                    value: parseData.policyAmount,       
                                    tax: parseData.ivaTax,
                                    shipping: 0.00, //shipping cost.
                                    currency: "USD", 
                                    coupon: "N/A",
                                    items: [{
                                        item_name: parseData.policyType,  // 
                                        item_id: this.policyName.data,
                                        price: parseData.netPremium, 
                                        item_brand: "MexInsurance",
                                        item_category: parseData.vehicleType, 
                                        item_category2: parseData.term, 
                                        item_category3: parseData.territory,  
                                        item_category4: parseData.underWriter, 
                                        index: 1, // position of the item
                                        quantity:1
                                    }]
                                }
                            });
                            
                        }
                    })
                    .catch((error)=>{
                        console.log(error);
                        this.setDataLayer(this.policyName?.transactionId, this.policyName?.amount);
                    });


                }else{
                    console.log('running on else');
                }
            }else{
                console.log('OUTPUT : Comuunity');
                fetchPolicyDetails({'policyId':this.policyName.PolicyId})
                    .then((result)=>{
                        if(result){
                            let parseData = JSON.parse(result);
                                //  window.dataLayer.push({

                                //     event: "purchase",
                                //     step_number: 'step_13',
                                //     step_name: 'order_confirmation', 
                                //     insurance_category: 'RV', 
                                //     ecommerce: {
                                //         transaction_id: parseData.transactionId,
                                //         affiliation: parseData.policyId,
                                //         value: parseData.policyAmount,       
                                //         tax: parseData.ivaTax,
                                //         shipping: 0.00, //shipping cost.
                                //         currency: "USD", 
                                //         coupon: "N/A",
                                //         items: [{
                                //         item_name: parseData.policyType, 
                                //         item_id: this.policyName,
                                //         price: parseData.netPremium, 
                                //         item_brand: "MexInsurance",
                                //         item_category: parseData.vehicleType, 
                                //         item_category2: parseData.term, 
                                //         item_category3: parseData.territory,  
                                //         item_category4: parseData.underWriter, 
                                //         index: 1, // position of the item
                                //         quantity:1
                                //         }]
                                //     }
                                // });
                            
                        }
                    })
                    .catch((error)=>{
                        console.log(error);
                        this.setDataLayer(this.policyName?.email, this.policyName?.data);
                    });
                
            }
			let action = await sendEmailDocumentAction({'policyIds':JSON.stringify(policyIdSet)});
            console.log('Testt Log');
			const evt = new ShowToastEvent({
                title: this.label.Success,
                message: this.label.Emailsentsuccessfully,
                variant: 'success',
            });
            this.dispatchEvent(evt);
		}
         console.log("policyName ", window.dataLayer);
    }

    setDataLayer(transId, amt) {
        console.log("Called Datalayer");
        window.dataLayer.push({
            event: "payment_complete_sucessfully",
            transaction_id: transId,   
            amount: amt
        });
    }

    gotohome(){
        console.log("policyName ", this.policyName);
        console.log("call policy detail page");
        window.open(community_Url , "_blank");
       
    }
}