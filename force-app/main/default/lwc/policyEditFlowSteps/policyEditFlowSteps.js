import {api, LightningElement } from 'lwc';
import TermOptions from '@salesforce/label/c.TR_Term_Option';
import Whendoyouneedcoverage from '@salesforce/label/c.TR_Where_do_you_need_coverage';
import FinalizeVehicle from '@salesforce/label/c.TR_Finalize_Vehicle';
import FinalizeVehicleDetails from '@salesforce/label/c.TR_Finalize_Vehicle_Details';
import DriverDetails from '@salesforce/label/c.TR_Driver_details';
import Whoisthedriver from '@salesforce/label/c.TR_Who_is_the_driver_s';
import Whatareyoutowing from '@salesforce/label/c.TR_What_are_you_towing';
import Confirmation from '@salesforce/label/c.TR_Confirmation';
import TowingDetail from '@salesforce/label/c.TR_Towing_Detail';
import Verifythedetails from '@salesforce/label/c.TR_Verify_the_details';
import FinalizeTowDetails from '@salesforce/label/c.TR_Finalize_Tow_Details';
import PaymentDetail from '@salesforce/label/c.TR_Payment_Detail';
import Justonemoresteptogo from '@salesforce/label/c.TR_Just_one_more_step_to_go';

export default class InsuranceSteps extends LightningElement {
     label = {
          TermOptions,Whendoyouneedcoverage,FinalizeVehicle,FinalizeVehicleDetails,DriverDetails,Whoisthedriver,TowingDetail,Whatareyoutowing,Confirmation,
          Verifythedetails,FinalizeTowDetails,PaymentDetail,Justonemoresteptogo
    };
    @api steps;
    @api completedSteps;
    @api policyType;

    get showTowDetails(){
        return (this.policyType && this.policyType != 'Watercraft');
    }

get steps1(){
    let fillstep = this.steps == 'steps1' ? 'filling' : '';
    fillstep += this.completedSteps > 1 ? 'fill': ''; 
    return 'flowStep ' + fillstep;
}
get steps2(){
    let fillstep = this.steps == 'steps2' ? 'filling' : '';
    fillstep += this.completedSteps > 2 ? 'fill': ''; 
    return 'flowStep ' + fillstep;
}
get steps3(){
    let fillstep = this.steps == 'steps3' ? 'filling' : '';
    fillstep += this.completedSteps > 3 ? 'fill': ''; 
    return 'flowStep ' + fillstep;
}
get steps4(){
    let fillstep = this.steps == 'steps4' ? 'filling' : '';
    fillstep += this.completedSteps > 4 ? 'fill': ''; 
    return 'flowStep ' + fillstep;
}
get steps5(){
    let fillstep = this.steps == 'steps5' ? 'filling' : '';
    fillstep += this.completedSteps > 5 ? 'fill': ''; 
    return 'flowStep ' + fillstep;
}
get steps6(){
    let fillstep = this.steps == 'steps6' ? 'filling' : '';
    fillstep += this.completedSteps > 6 ? 'fill': ''; 
    return 'flowStep ' + fillstep;
}
get steps7(){
    let fillstep = this.steps == 'steps7' ? 'filling' : '';
    fillstep += this.completedSteps > 7 ? 'fill': ''; 
    return 'flowStep ' + fillstep;
}

get completedStep1(){
    return this.completedSteps > 1 ? true : false;
}
get completedStep2(){
    return this.completedSteps > 2 ? true : false;
}
get completedStep3(){
    return this.completedSteps > 3 ? true : false;
}
get completedStep4(){
    return this.completedSteps > 4 ? true : false;
}
get completedStep5(){
    return this.completedSteps > 5 ? true : false;
}
get completedStep6(){
    return this.completedSteps > 6 ? true : false;
}
get completedStep7(){
    return this.completedSteps > 7 ? true : false;
}
}