import { api, LightningElement } from 'lwc';
import image from '@salesforce/resourceUrl/mexJs';
import AdditionalQuickQuote from '@salesforce/label/c.TR_Additional_Quick_Quote';
import Vehicle from '@salesforce/label/c.TR_Vehicle';
import Days from '@salesforce/label/c.TR_Days';
import Daysintow from '@salesforce/label/c.TR_Days_in_tow';
import VehicleValue from '@salesforce/label/c.TR_Vehicle_Value';
import CombinedLiability from '@salesforce/label/c.TR_Combined_Liability';
import Purchase from '@salesforce/label/c.TR_Purchase';
import Fullterms from '@salesforce/label/c.TR_Full_Terms';
import Recommended from '@salesforce/label/c.TR_Recommended';
import Next from '@salesforce/label/c.TR_Next';
import Prev from '@salesforce/label/c.TR_Prev';
import YouindicatedyourATVwasstreetlegal from '@salesforce/label/c.TR_You_indicated_your_ATV_was_street_legal_Once_it_is_removed_from_the_Bentley';
import LiabilityOnly from '@salesforce/label/c.TR_Liability_Only';


export default class SouthboundTowedQuickQuote extends LightningElement {
     label = {
          AdditionalQuickQuote,Vehicle,CombinedLiability,VehicleValue,Daysintow,Days,LiabilityOnly,Purchase,Fullterms,Recommended,Vehicle,Next,Prev,YouindicatedyourATVwasstreetlegal,
    };

    @api changesnextscreen;
    @api changeprevscreen;

    additionalQuickQuote = true;
    isHighlightView = false;

    qualitasImg = image + '/mexJs/images/qualitas.png';
    chubbImg = image + '/mexJs/images/chubb.png';
    mapfreImg = image + '/mexJs/images/mapfre-logo.png';

    handleNextClick(){
        this.changesnextscreen();
    }

    handlePrevClick(){
        this.changeprevscreen();
    }

}