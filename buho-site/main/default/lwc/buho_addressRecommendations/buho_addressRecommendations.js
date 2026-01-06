import { LightningElement, api, track } from 'lwc';
import getAddress from '@salesforce/apex/GoogleApiSetup.getAddress';
import getAddressDetailsByPlaceId from '@salesforce/apex/GoogleApiSetup.getPlaceDetails';

export default class Buho_addressRecommendations extends LightningElement {
    @track addressRecommendations = [];
    @track selectedAddress = '';
    @track addressDetail = {};
    @track fullAddress = '';
    @track city = '';
    @track country = '';
    @track pincode = '';
    @track state = '';
    
    @api placeholder = 'Start typing address to search...';

    get hasRecommendations() {
        return (this.addressRecommendations !== null && this.addressRecommendations.length > 0);
    }

    handleChange(event) {
        event.preventDefault();
        // Handle buho_input event
        let searchText = event.detail?.value || event.target?.value;
        
        console.log('AR Search text:', searchText);
        
        if (searchText && searchText.length > 2) {
            this.getAddressRecommendations(searchText);
        } else {
            this.addressRecommendations = [];
        }
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
                console.log('AR Recommendations:', this.addressRecommendations);
            }).catch(error => {
                console.error('AR Error getting address:', JSON.stringify(error));
                this.addressRecommendations = [];
            });
    }

    resetAddress() {
        this.city = '';
        this.country = '';
        this.pincode = '';
        this.state = '';
        this.addressDetail = {};
        this.fullAddress = '';
    }

    async handleAddressRecommendationSelect(event) {
        event.preventDefault();
        let placeId = event.currentTarget.dataset.value;
        
        console.log('AR Selected place ID:', placeId);
        
        this.addressRecommendations = [];
        this.selectedAddress = '';
        this.resetAddress();

        try {
            const response = await getAddressDetailsByPlaceId({ placeId: placeId });
            const parsedResponse = JSON.parse(response);
            
            console.log('AR Place details:', parsedResponse);
            
            if (parsedResponse?.result?.address_components) {
                parsedResponse.result.address_components.forEach(address => {
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
                
                // Build full address
                if (this.addressDetail.route) {
                    this.fullAddress = this.addressDetail.route;
                }
                
                if (this.addressDetail.streetNumber) {
                    this.fullAddress = this.addressDetail.streetNumber + ' ' + this.fullAddress;
                }

                if (this.city) {
                    this.fullAddress = this.fullAddress + ' ' + this.city;
                }
                
                if (this.addressDetail.subLocal1) {
                    this.fullAddress = this.fullAddress + ' ' + this.addressDetail.subLocal1;
                }
                
                if (this.addressDetail.subLocal2) {
                    this.fullAddress = this.fullAddress + ' ' + this.addressDetail.subLocal2;
                }
                
                console.log('AR Full address:', this.fullAddress);
            }
        } catch (error) {
            console.error('AR Error getting place details:', JSON.stringify(error));
        }

        // Dispatch custom event with address fields
        const addressFields = {
            'City': this.city,
            'State': this.state,
            'Country': this.country,
            'PostalCode': this.pincode,
            'Address': this.fullAddress
        };
        
        console.log('AR Dispatching address:', addressFields);

        const addressEvent = new CustomEvent('sendaddress', {
            detail: JSON.stringify(addressFields),
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(addressEvent);
    }

    @api validate() {
        // Optional validation method if needed
        return true;
    }
}

