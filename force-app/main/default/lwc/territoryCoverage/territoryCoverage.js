import { LightningElement } from 'lwc';
import image from '@salesforce/resourceUrl/mexJs';
import mexImage from '@salesforce/resourceUrl/mexinsurance_assets';
import whatterritorycoverage from '@salesforce/label/c.TR_What_territory_coverage_are_you_looking_for';
import bajasonora from '@salesforce/label/c.TR_Baja_Sonora';
import bajasonorach from '@salesforce/label/c.TR_Baja_Sonora_Chihuahua_Coahuila_Nuevo_Leon_Tamaulipas';
import PartialUSAdjacent from '@salesforce/label/c.TR_Partial_US_Adjacent';
import EntireMexico from '@salesforce/label/c.TR_Entire_Mexico';
import Next from '@salesforce/label/c.TR_Next';
import Prev from '@salesforce/label/c.TR_Prev';

export default class TerritoryCoverage extends LightningElement {
     label = {
        whatterritorycoverage,bajasonora,bajasonorach,PartialUSAdjacent,EntireMexico,Next,Prev,
    };

    territorycoverage=true;
    towedoption=false;
    quickquote=false;
    screenName='territorycoverage';

    imagebaja = image + '/mexJs/images/MexicoBajaSonora.png';
    imageparital = mexImage + '/images/max-mexico-partial@2x.png';
    imagemexico = mexImage + '/images/map-mexico-full@2x.png';

    NextClickHandle(){
        if(this.screenName=='territorycoverage'){
            this.territorycoverage=false;
            this.quickquote=true;
        }
    }

    PrevClickHandle(){
        if(this.screenName=='territorycoverage'){
            this.territorycoverage=false;
            this.towedoption=true;
        }
    }
}