import { LightningElement, api, track, wire } from 'lwc';
import getAddress from '@salesforce/apex/GoogleApiSetup.getAddress';
import getAddressDetailsByPlaceId from '@salesforce/apex/GoogleApiSetup.getPlaceDetails';

export default class AddressRecommendations extends LightningElement {
    addressRecommendations = [];
    selectedAddress = '';
    addressDetail = {};
    fullAddress = '';

    get hasRecommendations() {
        return (this.addressRecommendations !== null && this.addressRecommendations.length);
    }

    handleChange(event) {
        event.preventDefault();
        let searchText = event.target.value;
        if (searchText) this.getAddressRecommendations(searchText);
        else this.addressRecommendations = [];
    }

    getAddressRecommendations(searchText) {
        getAddress({ searchString: searchText })
            .then(response => {
                let addressRecommendations = [];
                response.forEach(prediction => {
                    addressRecommendations.push({
                        main_text: prediction.AddComplete,
                        secondary_text: prediction.AddComplete,
                        place_id: prediction.placeId,
                    });
                });
                this.addressRecommendations = addressRecommendations;
            }).catch(error => {
                console.log('error : ' + JSON.stringify(error));
            });
    }

    resetAddress() {
        this.city = '';
        this.country = '';
        this.pincode = '';
        this.state = '';
    }

    async handleAddressRecommendationSelect(event) {
        event.preventDefault();
        let placeId = event.currentTarget.dataset.value;
        this.addressRecommendations = [];
        this.selectedAddress = '';
        this.resetAddress();


        await getAddressDetailsByPlaceId({ placeId: placeId })
            .then(response => {
                response = JSON.parse(response);
                response.result.address_components.forEach(address => {
                    console.log('address : ',address);
                    let type = address.types[0];
                    switch (type) {
                        case 'locality':
                            this.selectedAddress = this.selectedAddress + ' ' + address.long_name;
                            this.city = address.long_name;
                            break;
                        case 'country':
                            this.selectedAddress = this.selectedAddress + ' ' + address.long_name;
                            this.country = address.long_name;
                            break;
                        case 'administrative_area_level_1':
                            this.selectedAddress = this.selectedAddress + ' ' + address.long_name;
                            this.state = address.long_name;
                            break;
                        case 'postal_code':
                            this.selectedAddress = this.selectedAddress + ' ' + address.long_name;
                            this.pincode = address.long_name;
                            break;
                        case 'sublocality_level_2':
                            this.selectedAddress = this.selectedAddress + ' ' + address.long_name;
                            this.addressDetail.subLocal2 = address.long_name;
                            break;
                        case 'sublocality_level_1':
                            this.selectedAddress = this.selectedAddress + ' ' + address.long_name;
                            this.addressDetail.subLocal1 = address.long_name;
                            break;
                        case 'street_number':
                            this.selectedAddress = this.selectedAddress + ' ' + address.long_name;
                            this.addressDetail.streetNumber = address.long_name;
                            break;
                        case 'route':
                            this.selectedAddress = this.selectedAddress + ' ' + address.short_name;
                            this.addressDetail.route = address.short_name;
                            break;
                        default:
                            break;
                    }
                });
                if(this.addressDetail.route != undefined){
                    this.fullAddress = this.addressDetail.route;
                }
                console.log('this.fullAddress : ',this.fullAddress);
                if(this.addressDetail.streetNumber != undefined){
                    this.fullAddress = this.addressDetail.streetNumber+' '+ this.fullAddress;
                }

                if (this.addressDetail.city != undefined) {
                    this.fullAddress = this.fullAddress + ' ' + this.addressDetail.city;
                    console.log ('this.fullAddress : ',this.fullAddress);
                }
                
                console.log('this.fullAddress : ',this.fullAddress);
                if(this.addressDetail.subLocal1 != undefined){
                    this.fullAddress = this.fullAddress  + ' ' + this.addressDetail.subLocal1;
                }
                console.log('this.fullAddress : ',this.fullAddress);
                if(this.addressDetail.subLocal2 != undefined){
                    this.fullAddress = this.fullAddress  + ' ' + this.addressDetail.subLocal2;
                }
                console.log('this.fullAddress : ',this.fullAddress);
                //this.fullAddress = this.addressDetail.route + ' ' + this.addressDetail.streetNumber + ' ' + this.addressDetail.subLocal1 + ' ' + this.addressDetail.subLocal2
            })
            .catch(error => {
                console.log('error : ' + JSON.stringify(error));
            });

        let addressFields = {
            'City': this.city,
            'State': this.state,
            'Country': this.country,
            'PostalCode': this.pincode,
            'Address' : this.fullAddress
        }
        console.log('addressFields : ',JSON.stringify(addressFields));

        let address = new CustomEvent('sendaddress', {
            detail: JSON.stringify(addressFields)
        });
        this.dispatchEvent(address);
        console.log('Tes---- : ');
    }

}