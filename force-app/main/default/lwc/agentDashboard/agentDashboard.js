import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
// import getExternalIp from '@salesforce/apex/LWC_Utils.getExternalIp';
import fetchExistingLead from '@salesforce/apex/AgentAppController.fetchExistingLead';
import createUserForContact from '@salesforce/apex/AgentAppController.createUserForContact';
import searchDetails from '@salesforce/apex/AgentAppController.searchDetails';
import getLoggedInContactData from '@salesforce/apex/AgentAppController.getLoggedInContactData';
import updateContactEmail from '@salesforce/apex/AgentAppController.updateContactEmail';
import returnAccessToken from '@salesforce/apex/AgentAppController.returnAccessToken';
import getCustomMetadataForApi from '@salesforce/apex/AgentAppController.getCustomMetadataForApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import validateandGenerateQuotePDF from '@salesforce/apex/PolicyDocumentGenerator.validateandGenerateQuotePDF';
import USER_ID from '@salesforce/user/Id';
import TIME_ZONE from '@salesforce/i18n/timeZone';

const contactTableColumns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Phone', fieldName: 'Phone', type: 'phone' },
    { label: 'Email', fieldName: 'Email', type: 'email' },
    { label: 'Id', fieldName: 'Id' },
];

const actions = [
    { label: 'Show details', name: 'show_details' },
    { label: 'Delete', name: 'delete' }
]
const quoteTableColumns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Type', fieldName: 'Policy_Type_picklist__c' },
    { label: 'Term', fieldName: 'Term_Days__c' },
    { label: 'Start Date', fieldName: 'Start_Date_for_Coverage__c' },
    { label: 'End Date', fieldName: 'End_Date_for_Coverage__c' },
    { label: 'Contact', fieldName: 'Contact__c' },
    { label: 'Lead', fieldName: 'Lead__c' },
    { label: 'Id', fieldName: 'Id' },
    { type: 'action', typeAttributes: { rowActions: actions, menuAlignment: 'left' } }
];

export default class AgentDashboard extends NavigationMixin(LightningElement) {
    @track accessToken;
    @track userId = USER_ID;
    @api cmpSource;
    @track isAgentportal;
    timeZone = '';
    @track isLoading = false;
    @track isShowModal = false;
    updatedContactEmail;
    contactIdForEmailUpdate;
    @track booleanVar = {
        leadDataStatus: false, quoteDataStatus: false, contactDataStatus: false, policyDataStatus: false, noDataFound: false, createLeadButton: false
    }
    searchData = {};

    @track searchResults = {};
    @track isModalOpen = false;
    @track currentContactId;
    @track contactAgencyId;
    data = [];
    leadQuote = {};

    quoteTable = quoteTableColumns;
    actionbuttons = [{ label: 'Create Policy', name: 'create_policy' }];
    actionLeadbuttons = [{ label: 'Resume', name: 'Resume' }
    ];

    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Phone', fieldName: 'Phone', type: 'phone' },
        { label: 'Email', fieldName: 'Email', type: 'email' },
        { label: 'Id', fieldName: 'Id' },
        { type: 'action', typeAttributes: { rowActions: this.actionLeadbuttons } }
    ];

    contactColumns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Phone', fieldName: 'Phone', type: 'phone' },
        { label: 'Email', fieldName: 'Email', type: 'email' },
        { label: 'Id', fieldName: 'Id' },
        { type: 'action', typeAttributes: { rowActions: this.getActionButtons } }
    ];


    getActionButtons(row, doneCallback) {
        //console.log('insdie getActionButtons');
        let actionButtons = [];

        if (row?.Users?.totalSize > 0) {
            actionButtons.push({ label: 'Create Policy', name: 'create_policy' });
            //actionButtons.push({ label: 'Transfer Ownership', name: 'transfer_ownership' });
        } else {
            actionButtons.push({ label: 'Create Policy', name: 'create_policy' });
            actionButtons.push({ label: 'Create User', name: 'create_user' });
            //actionButtons.push({ label: 'Transfer Ownership', name: 'transfer_ownership' });
        }


        // if (cmpSource == 'comm') {
        //     
        // }
        //console.log('actionButtons:::', actionButtons);
        doneCallback(actionButtons);
    }


    async connectedCallback() {

        console.log('Test Comm');
        if (this.cmpSource == 'comm') {
            this.isAgentportal = false;

            await returnAccessToken().then(data => {
                console.log('data:::', data);
                this.accessToken = data;
            });

        } else {
            this.actionLeadbuttons.push({ label: 'Open', name: 'Open' });
            this.isAgentportal = true;
        }

        let timeOptions = {
            hour: 'numeric',
            minute: 'numeric',
            second: 'numeric',
            hour12: false,
            timeZone: TIME_ZONE,
            timeZoneName: 'shortOffset'
        }

        //use the same function to standardize the date
        this.timeZone = new Intl.DateTimeFormat('en-US', timeOptions).format(new Date());
        console.log('In the connected call back');

        if (this.cmpSource == 'comm') {
            getLoggedInContactData({ 'UserId': this.userId }).then((data) => {
                console.log('Data:::', data);
                if (data?.Agency__c != null) {
                    this.contactAgencyId = data.Agency__c;
                } else {
                    this.contactAgencyId = data.Id;
                }

                console.log('contactAgencyId:::', this.contactAgencyId);
            });
        }
    }

    // Validation....
    isInputValid(className) {
        let isValid = true;
        let inputFields = this.template.querySelectorAll(className);
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

    showToastEvent(label, message, variant) {
        const errMsg = new ShowToastEvent({
            title: label,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(errMsg);
    }

    handleInputChange = (event) => {
        this.searchData[event.target.name] = event.target.value;
    }

    handleRowAction(event) {
        console.log('handleRowAction - event');
        let actionName = event.detail.action.name;
        let currentUrl = window.location.origin;
        const row = event.detail.row.Id;
        let contactEmail = this.searchResults?.contactData.filter(data => {
            return data.Id == row ? data.Email : '';
        });
        this.contactIdForEmailUpdate = row;

        if (actionName === 'create_user') {
            this.isLoading = true;
            if (contactEmail != undefined && contactEmail != '' && contactEmail != null) {
                // Handle the logic for creating a user
                createUserForContact({ 'contactId': row }).then(item => {
                    if (item == 'Success') {
                        this.showToastEvent('User Created', 'User has been enabled you will recieve an email', 'Success');

                        this.handleSearch();
                    } else {
                        this.showToastEvent('Error', item, 'error');
                        this.isLoading = false;
                    }
                })
            } else {

                this.isShowModal = true;
            }


        } else if (actionName === 'create_policy') {
            let state = {
                c__contactId: row,
                c__actionmode: 'newPolicyFromContact'
            };

            if (this.cmpSource == 'comm') {
                location.replace(`${currentUrl}/agency/quick-quote?c__contactId=${row}&c__actionmode=newPolicyFromContact`);
            } else {
                location.replace(`${currentUrl}/lightning/n/Quick_Quote?c__contactId=${row}&c__actionmode=newPolicyFromContact`);
            }

        } else if (actionName === 'transfer_ownership') {
            console.log('User Id', this.userId);
            this.currentContactId = row;
            this.isModalOpen = true;
        }

    }

    handleLeadRowAction(event) {
        const actionName = event.detail.action.name;
        let row = event.detail.row.Id;
        console.log('currentUrl', window.location.origin);
        console.log('event ', event);
        console.log('Lead Row ', row);

        if (actionName == 'Resume') {
            let state = {
                c__contactId: row,
                c__actionmode: 'resumeLead'
            };
            //this.navigateTo('standard__navItemPage', 'Quick_Quote', state);
            let currentUrl = window.location.origin;
            if (this.cmpSource == 'comm') {
                location.replace(`${currentUrl}/agency/quick-quote?c__contactId=${row}&c__actionmode=resumeLead`);
            } else {
                location.replace(`${currentUrl}/lightning/n/Quick_Quote?c__contactId=${row}&c__actionmode=resumeLead`);
            }


        } else if (actionName == 'Open') {
            let currentUrl = window.location.origin;
            if (this.cmpSource == 'comm') {
                location.replace(`${currentUrl}/agency/lead/Lead/${row}`);
            } else {
                location.replace(`${currentUrl}/lightning/r/Lead/${row}/view`);
            }

        }


    }


    handlekeyUp(event) {
        let isEnterKey = event.keyCode === 13;
        if (isEnterKey) {
            this.handleSearch();
        }
    }

    handleSearch = async () => {
        // console.log('In the search click');
        this.isLoading = true;
        let status = this.isInputValid('.searchValidate');
        if (status) {
            this.booleanVar.createLeadButton = true;
            if (this.searchData.searchValue.length > 1) {
                // this.searchResults = {};
                let agencyId;
                if (this.cmpSource == 'comm') {
                    agencyId = this.contactAgencyId;

                    let endpointUrl;
                    await getCustomMetadataForApi({ 'developerName': 'Fetch_data_from_salesforce' }).then((data) => {
                        console.log('Query Data::', data);
                        endpointUrl = data.Endpoint_Url__c;

                    });
                    console.log('endpointUrl::', endpointUrl);
                    console.log('agencyId::', agencyId);

                    const myHeaders = new Headers();
                    myHeaders.append("Authorization", "Bearer" + " " + this.accessToken);
                    console.log('myHeaders:::', myHeaders);
                    const requestOptions = {
                        method: "GET",
                        headers: myHeaders,
                        redirect: "follow"
                    };
                    console.log('EMAIL:::', this.searchData.searchValue.trim());
                    let emailToSearch = this.searchData.searchValue.trim().replace(/\+/g, '%2B');
                    console.log('emailToSearch:::', emailToSearch);
                    console.log('Query::', endpointUrl + "/query?q=SELECT+Id,FirstName,LastName,Email+FROM+Contact+WHERE+Email='" + emailToSearch + "' AND Agency__c !='" + agencyId + "' AND Agent__c !='" + agencyId + "'");
                    fetch(endpointUrl + "/query?q=SELECT+Id,FirstName,LastName,Email+FROM+Contact+WHERE+Email='" + emailToSearch + "' AND Agency__c !='" + agencyId + "' AND Agent__c !='" + agencyId + "'", requestOptions)
                        .then((response) => response.json())
                        .then((result) => {
                            
                            if (result.totalSize > 0) {
                                
                                this.isModalOpen = true;
                                this.currentContactId = result.records[0].Id;
                            }
                            
                        })
                        .catch((error) => console.error('EROOROROOROR::', error));

                }
                
                searchDetails({ 'searchKey': (this.searchData.searchValue).trim(), 'agencyId': agencyId })
                    .then((result) => {
                        let data = JSON.parse(result);
                        this.isLoading = false;

                        this.searchResults.leadData = data.Lead != '' ? JSON.parse(data.Lead) : '';
                        this.searchResults.quoteData = data.Quote != '' ? JSON.parse(data.Quote) : '';
                        this.searchResults.contactData = data.Contact != '' ? JSON.parse(data.Contact) : '';
                        this.searchResults.policyData = data.Policy != '' ? JSON.parse(data.Policy) : '';
                        this.searchResults.contactAgencyData = data.contactAgencyData != '' ? JSON.parse(data.contactAgencyData) : '';

                        // if(this.searchResults.contactAgencyData.length > 0){
                        //     this.isModalOpen = true;
                        // }


                        if (this.searchResults.leadData.length == 0 && this.searchResults.quoteData == 0 && this.searchResults.contactData == 0 && this.searchResults.policyData == 0) {
                            // console.log('No data found');
                            this.booleanVar.noDataFound = true;
                        } else {
                            this.booleanVar.noDataFound = false;
                        }

                        if (this.searchResults.leadData.length != 0) {
                            this.data = this.searchResults.leadData;
                            this.booleanVar.leadDataStatus = true;
                        } else {
                            this.data = [];
                            this.booleanVar.leadDataStatus = false;
                        }

                        if (this.searchResults.quoteData.length != 0) {
                            this.booleanVar.quoteDataStatus = true;
                        } else {
                            this.booleanVar.quoteDataStatus = false;
                            this.searchResults.quoteData = []
                        }

                        if (this.searchResults.contactData.length != 0) {
                            this.booleanVar.contactDataStatus = true;
                        } else {
                            this.searchResults.contactData = [];
                            this.booleanVar.contactDataStatus = false;
                        }

                        // if(this.searchResults.policyData.length != 0 ) {
                        //     this.booleanVar.policyDataStatus = true;

                        //     this.searchResults.policyData.map((data) => {

                        //         if(data.Status_picklist__c == 'Terminated'){
                        //             data.disableEdit = true;
                        //             data.disableTerminate = true;
                        //             data.disableRenew = false;
                        //         }else{
                        //             data.disableEdit = false;
                        //             data.disableTerminate = false;
                        //             data.disableRenew = true;
                        //         }

                        //     })

                        // } else {
                        //     this.booleanVar.policyDataStatus = false;
                        //     this.searchResults.policyData = [];
                        // }

                        if (this.searchResults.policyData.length != 0) {
                            this.booleanVar.policyDataStatus = true;
                           
                            this.searchResults.policyData.map(policy => {
                                if (policy.Status_picklist__c == 'Expired' || policy.Status_picklist__c == 'Updated' || policy.Status_picklist__c == 'Terminated' || policy.Policy_Type_picklist__c == 'Northbound') {
                                    policy.EditBtn = false;
                                    // console.log('in the Edit if', policy.EditBtn)
                                } else {
                                    policy.EditBtn = true;
                                    // console.log('in the Edit else', policy.EditBtn)
                                }

                                if (policy.Term__c == 'Daily') {
                                    // console.log('In the daily policy type')
                                }

                                if ((policy.Status_picklist__c == 'Active' || policy.Status_picklist__c == 'Updated' || policy.Status_picklist__c == 'Terminated' || policy.Status_picklist__c == 'Expired') && policy.Policy_Type_picklist__c != 'Northbound') {
                                    policy.RenewBtn = true;
                                    // console.log('in the renew if', policy.RenewBtn)
                                } else {
                                    policy.RenewBtn = false;
                                    // console.log('in the renew else', policy.RenewBtn)
                                }

                                if (policy.Status_picklist__c == 'Active') {
                                    policy.TerminateBtn = true;
                                    let convertedStartDate = new Date(policy.Start_Date__c);
                                    let convertedEndDate = new Date(policy.End_Date__c);
                                    let formattedStartDate = convertedStartDate.toDateString();
                                    let todaysDate = new Date();

                                    // if (policy.Term__c == 'Daily' && (convertedStartDate <= todaysDate || convertedEndDate <= todaysDate)) {
                                    //     policy.TerminateBtn = false;
                                    // }
                                    if (convertedStartDate <= todaysDate && convertedEndDate <= todaysDate) {
                                        policy.TerminateBtn = false;
                                    }

                                    // console.log('In the Terminate if', policy.TerminateBtn)
                                } else {
                                    policy.TerminateBtn = false;
                                    // console.log('In the Terminate Else', policy.TerminateBtn)
                                }
                            })
                        } else {
                            this.booleanVar.policyDataStatus = false;
                            this.searchResults.policyData = [];
                        }
                        // console.log('policy' ,this.searchResults.policyData);
                        this.isLoading = false;
                        return true;
                    }).catch((err) => {
                        this.isLoading = false;
                        console.log('Error', err)
                    });
            } else {
                this.isLoading = false;
                console.log('Error:  ===');
                this.searchResults = {};
                this.data = [];
                this.booleanVar.policyDataStatus = false;
                this.booleanVar.contactDataStatus = false;
                this.booleanVar.quoteDataStatus = false;
                this.booleanVar.leadDataStatus = false;

                this.showToastEvent('Error', 'Fill in the correct details', 'error');
            }
        } else {
            console.log('Errorr didnt find any values');
            this.isLoading = false;
            this.searchResults = {};
            this.data = [];
            this.booleanVar.policyDataStatus = false;
            this.booleanVar.contactDataStatus = false;
            this.booleanVar.quoteDataStatus = false;
            this.booleanVar.leadDataStatus = false;
            this.showToastEvent('Error', 'Fill in the correct details', 'error');
        }
        //this.isLoading = false;
    }

    handleNewLead = () => {
        // console.log('handleNewLead');        
        //this.navigateTo('standard__navItemPage', 'Quick_Quote');
        let currentUrl = window.location.origin;
        if (this.cmpSource == 'comm') {
            location.replace(`${currentUrl}/agency/quick-quote`);
        } else {
            location.replace(`${currentUrl}/lightning/n/Quick_Quote`);
        }

    }
    navigateToPolicyRenew(event) {
        // Define the parameters you want to pass
        // console.log('navigate to renew mode');
        let customId = event.target.dataset.id ? event.target.dataset.id : event.currenTarget.dataset.id;
        let state = {
            // Pass parameters as key-value pairs
            c__policyId: customId,
            c__actionmode: 'renew'
        };

        // Navigate to the target LWC
        //this.navigateTo('standard__navItemPage', 'Policy_Edit_Renew', state);
        let currentUrl = window.location.origin;
        if (this.cmpSource == 'comm') {
            location.replace(`${currentUrl}/agency/policy-edit-renew?c__policyId=${customId}&c__actionmode=renew`);
        } else {
            location.replace(`${currentUrl}/lightning/n/Policy_Edit_Renew?c__policyId=${customId}&c__actionmode=renew`);
        }

    }
    navigateToPolicyEdit(event) {
        // Define the parameters you want to pass
        // console.log('navigate to edit mode');
        let customId = event.target.dataset.id ? event.target.dataset.id : event.currenTarget.dataset.id;
        let state = {
            // Pass parameters as key-value pairs
            c__policyId: customId,
            c__actionmode: 'edit'
        };

        // Navigate to the target LWC
        //this.navigateTo('standard__navItemPage', 'Policy_Edit_Renew', state);
        let currentUrl = window.location.origin;
        if (this.cmpSource == 'comm') {
            location.replace(`${currentUrl}/agency/policy-edit-renew?c__policyId=${customId}&c__actionmode=edit`);
        } else {
            location.replace(`${currentUrl}/lightning/n/Policy_Edit_Renew?c__policyId=${customId}&c__actionmode=edit`);
        }

    }


    handleCreatePolicy(event) {
        let state = {}
        let dataSets = event.target.dataset;
        console.log('dataSets', dataSets);
        if (dataSets?.obj == 'policy') {
            state = { c__obj: dataSets?.obj, c__action: dataSets?.actiontype, c__id: dataSets?.id }
            if (state.c__action == 'CREATEPOLICY') {
                console.log('LOG - Contact:::::', state.c__id);
                let currentUrl = window.location.origin;
                if (this.cmpSource == 'comm') {
                    location.replace(`${currentUrl}/agency/quick-quote?c__contactId=${state.c__id}&c__actionmode=newPolicyFromContact`);
                } else {
                    location.replace(`${currentUrl}/lightning/n/Quick_Quote?c__contactId=${state.c__id}&c__actionmode=newPolicyFromContact`);
                }

            }
        }
    }

    handleViewPolicyOperations(event) {
        let state = {}
        let dataSets = event.target.dataset;
        console.log('dataSets', dataSets);
        if (dataSets?.obj == 'policy') {
            state = { c__obj: dataSets?.obj, c__action: dataSets?.actiontype, c__id: dataSets?.id }
            if (state.c__action == 'VIEWPOLICY') {
                let currentUrl = window.location.origin;
                console.log('state.c__id', state.c__id);
                validateandGenerateQuotePDF({ 'policyId': state.c__id })
                    .then((result) => {
                        this.booleanVar.isLoading = false;
                        if (result) {
                            window.open(('/apex/' + result + '?id=' + state.c__id), '_blank');
                        } else {
                            let errEvt = new ShowToastEvent({
                                message: 'Cannot generate PDF for the current policy.',
                                title: 'Something wrong happened while generating PDF!',
                                variant: 'error',
                            });
                            this.dispatchEvent(errEvt);
                        }
                    })
                    .catch((error) => {
                        this.booleanVar.isLoading = false;
                        console.log(error);
                    });

            }
        }
    }
    handleOperations = (event) => {
        // console.log('Handle Operations')
        let state = {}
        let dataSets = event.target.dataset;

        console.log('dataSets', dataSets);

        if (dataSets?.obj == 'contact') {
            // console.log('In the contact, Navigation');
            state = { c__obj: dataSets?.obj, c__action: dataSets?.actiontype, c__id: dataSets?.id };
            // console.log('State', state);
            this.navigateTo('standard__navItemPage', 'Contact_Detail', state);
        } else if (dataSets?.obj == 'lead') {
            // console.log('in the lead ')
            state = { c__obj: dataSets?.obj, c__action: dataSets?.actiontype, c__id: dataSets?.id }
            // console.log('Data: ', state)
            this.navigateTo('standard__navItemPage', 'Quick_Quote', state);
        } else if (dataSets?.obj == 'quote') {
            //console.log('in the quote ')
            state = { c__obj: dataSets?.obj, c__action: dataSets?.actiontype, c__id: dataSets?.id }
            // console.log('Data: ', state)
            this.navigateTo('standard__navItemPage', 'Quote_Details', state);
        } else if (dataSets?.obj == 'policy') {
            // console.log('in the policy ')
            state = { c__obj: dataSets?.obj, c__action: dataSets?.actiontype, c__id: dataSets?.id }
            if (state.c__action == 'TERMINATE') {
                let currentUrl = window.location.origin;
                console.log('state.c__id', state.c__id);
                if (this.cmpSource == 'comm') {
                    location.replace(`${currentUrl}/agency/policy-terminate?c__obj=policy&c__action=TERMINATE&c__id=${state.c__id}`);
                } else {
                    location.replace(`${currentUrl}/lightning/n/Policy_Details?c__obj=policy&c__action=TERMINATE&c__id=${state.c__id}`);
                }

            } else {
                this.navigateTo('standard__navItemPage', 'Policy_Details', state);
            }


        } else {
            console.log('Error --> details are missing.')
        }
    }

    navigateTo = (type, apiName, state) => {
        this[NavigationMixin.Navigate]({
            type: type,
            attributes: {
                apiName: apiName
            },
            state: state
        });
    }

    handleEmailInput(event) {
        console.log(event.target.value);
        this.updatedContactEmail = event.target.value;
    }

    hideModalBox() {
        this.isShowModal = false;
        this.isLoading = false;
    }

    handleUpdateEmail() {
        console.log('Update Email');
        if (this.updatedContactEmail != null) {
            this.isLoading = true;
            updateContactEmail({ 'email': this.updatedContactEmail, 'contactId': this.contactIdForEmailUpdate }).then((data) => {
                console.log(data);
                if (data == 'Success') {
                    this.showToastEvent('Email updated', 'Email is updated on Contact', 'success');

                    createUserForContact({ 'contactId': this.contactIdForEmailUpdate }).then(item => {
                        if (item == 'Success') {
                            this.showToastEvent('User Created', 'User has been enabled you will recieve an email', 'Success');
                            this.handleSearch();
                        } else {
                            this.showToastEvent('Error', item, 'error');
                            this.isLoading = false;
                        }
                    })
                    this.isShowModal = false;
                } else {
                    this.showToastEvent('Error ', data, 'error');
                    this.isLoading = false;
                    this.isShowModal = false;
                }
            })

        } else {
            this.showToastEvent('Error', 'Kindly fill the Email', 'error');
        }



    }

    handlerTransferOwnership() {
        //?.transferOwnershipHandler();
        const data = this.template.querySelector('c-transfer-ownership-manager')?.transferOwnershipHandler();
        //console.log('Data', data);
    }

    cancelTransferOwnership() {
        this.isModalOpen = false;
    }

    handleToast(event) {
        const { type, title, message } = event.detail;
        this.template.querySelector('c-custom-toast').showToast(type, title, message);
    }
}