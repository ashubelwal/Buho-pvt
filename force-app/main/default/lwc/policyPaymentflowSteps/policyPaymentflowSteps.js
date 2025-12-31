import {api, LightningElement } from 'lwc';
import TowDetails from '@salesforce/label/c.TR_Tow_Details';
import Finalizetowdetails from '@salesforce/label/c.TR_Finalize_Tow_Details';
import VehicleDetail from '@salesforce/label/c.TR_Vehicle_Detail';
import Finalizvehicledetails from '@salesforce/label/c.TR_Finalize_Vehicle_Details';
import DriverDetails from '@salesforce/label/c.TR_Driver_details';
import Whoisthedrivers from '@salesforce/label/c.TR_Who_is_the_driver_s';
import Confirmation from '@salesforce/label/c.TR_Confirmation';
import Verifythedetails from '@salesforce/label/c.TR_Verify_the_details';
import ConfirmtheTermsConditions from '@salesforce/label/c.TR_Renew_Policy';
import PaymentDetail from '@salesforce/label/c.TR_Payment_Detail';
import Justonemoresteptogo from '@salesforce/label/c.TR_Just_one_more_step_to_go';
import Complete from '@salesforce/label/c.TR_Complete';
import Welldone from '@salesforce/label/c.TR_Well_done';
import Policyterms from '@salesforce/label/c.TR_Policy_Terms';
import ReviewVehicle from '@salesforce/label/c.TR_Review_Vehicle';
import Policyandterms from '@salesforce/label/c.TR_Policy_and_terms';
import Completed from '@salesforce/label/c.TR_Completed';


export default class InsuranceSteps extends LightningElement {
     label = {
          TowDetails,Finalizetowdetails,VehicleDetail,Finalizvehicledetails,DriverDetails,Whoisthedrivers,Confirmation,Verifythedetails,ConfirmtheTermsConditions,
          PaymentDetail,Justonemoresteptogo,Complete,Welldone,Policyterms,ReviewVehicle,DriverDetails,Confirmation,Policyandterms,Completed,
    };
    @api steps;
    @api completedSteps;
    @api isTowing;

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
        return this.completedSteps > 5 ? true : false;
    }
    get completedStep7(){
        return this.completedSteps > 6 ? true : false;
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
get showSteps2(){
    return this.isTowing ? 2 : 1;
}
get showSteps3(){
    return this.isTowing ? 3 : 2;
}
get showSteps4(){
    return this.isTowing ? 4 : 3;
}
get showSteps5(){
    return this.isTowing ? 5 : 4;
}
get showSteps6(){
    return this.isTowing ? 6 : 5;
}
get showSteps7(){
    return this.isTowing ? 7 : 6;
}

}