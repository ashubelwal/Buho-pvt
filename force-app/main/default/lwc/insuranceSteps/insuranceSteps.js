import {api, LightningElement } from 'lwc';
import image from '@salesforce/resourceUrl/mexinsurance_assets';
import userdetail from '@salesforce/label/c.TR_User_Detail';
import tellusabout from '@salesforce/label/c.TR_Tell_us_about_yourself';
import vehicledetails from '@salesforce/label/c.TR_Vehicle_Details';
import vehicleneedscoverage from '@salesforce/label/c.TR_What_vehicle_needs_coverage';
import termoption from '@salesforce/label/c.TR_Term_Option';
import whendoyouneed from '@salesforce/label/c.TR_When_do_you_need_coverage';
import toweddetails from '@salesforce/label/c.TR_Towed_details';
import whatareyoutowing from '@salesforce/label/c.TR_What_are_you_towing';
import territory from '@salesforce/label/c.TR_Territory';
import wheredoyouneed from '@salesforce/label/c.TR_Where_do_you_need_coverage';

export default class InsuranceSteps extends LightningElement {
     label = {
        userdetail,tellusabout,vehicledetails,vehicleneedscoverage,termoption,whendoyouneed,toweddetails,whatareyoutowing,territory,wheredoyouneed,
    };
    @api steps;
    @api completedSteps;
    @api policyType;
    @api isTowing;
    checkmark = image + '/images/icon-blue-checkmark.png';

get isShowTowedOption(){
    console.log('--policyType--insurence flow--', this.policyType);
    console.log('--policyType--insurence flow- isTowing-', this.isTowing);
    return this.isTowing ? this.isTowing : false;
}
get isShowTerritory(){
    return this.policyType != undefined ? (this.policyType != 'Watercraft' && this.policyType != 'Northbound') : false;
}
get steps1(){
    let fillstep = this.steps == 'steps1' ? 'filling' : '';
    fillstep += this.completedSteps > 1 ? 'fill': ''; 
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

}