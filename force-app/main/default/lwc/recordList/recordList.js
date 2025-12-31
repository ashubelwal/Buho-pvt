import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getListUi } from 'lightning/uiListApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import basePath from '@salesforce/community/basePath';
import getLeadId from '@salesforce/apex/AgencyController.getLeadId';
import validateandGenerateQuotePDF from '@salesforce/apex/PolicyDocumentGenerator.validateandGenerateQuotePDF';

const actions = [{ label: 'Open', name: 'open_record' }];

export default class RecordList extends NavigationMixin(LightningElement) {
    @api detailPage;
    @api listView;
    @api object;
    @api showListViewLabel;
    @api actionBtn
    @api cmpSource;
    actionList = []

    @track sortBy;
    @track sortDirection;

    columnFields;
    @track iscustomTableData = false;
    @track vehicleTable = false ;
    customTableData;
    error;
    fields;
    listViewLabel;
    records;
    pageName;
    getObjectApiName;

    temp = '';

    @wire(getObjectInfo, { objectApiName: '$object' })
    objectInfo({ error, data }) {
        if (data) {
            this.fields = data.fields;
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getListUi, {
        objectApiName: '$object',
        listViewApiName: '$listView',
        pageSize: 2000
    })
    results({ data, error }) {
        if (data) {
            console.log(JSON.stringify(data));
            console.log(data);
            console.log('CHeck ---> ');
            console.log(' this.object  --->',this.object);
            if(this.object=='Vehicle__c'){
                this.vehicleTable = true;
            }          
            this.columnFields = data.info.displayColumns;
            this.records = data.records.records;
            console.log('Working in the wire')
            console.log(this.records);
            this.getObjectApiName = data.records.listReference.objectApiName;            
            console.log(this.getObjectApiName)
            this.customTableData = this.getCustomTableData();
            this.error = undefined;

            let objName = this.object.split('__c', 1);
            this.pageName = objName[0].toLowerCase();
            console.log(' Page namea ',this.pageName);
            console.log(' this.object',this.object);
            // if(this.pageName)
            this.iscustomTableData = true;
        }
        if (error) {
            this.error = error;
        }
    }

    get columns() {
        let columns = [];
        if (this.columnFields && this.fields) {
            columns = this.columnFields.map((field) => {
                let formattedField = {};
                formattedField.label = field.label;
                formattedField.fieldName = field.fieldApiName;                                                
                const dataType = this.fields[field.fieldApiName]?.dataType;
                console.log(field.fieldApiName + ' | ' + dataType)
                if (dataType === 'DateTime' || dataType === 'Date') {
                    formattedField.type = 'date-local';
                    formattedField.sortable = true;
                } else {
                    formattedField.type = dataType;
                }
                return formattedField;
            });
            if(this.vehicleTable != true){
            columns.push({
                type: 'action',
                typeAttributes: { rowActions: this.getActionButtons }
            });
            }
        }
        return columns;
    }    

    reFormatProxyData(data) {
        
    }

    getActionButtons(row, callBack) {
        console.log('Row data Test clicked',JSON.stringify(row));
        console.log(row);
        let pathName = window.location.pathname.split('/')[3];
        console.log('pathName---->',pathName);

        if(pathName == 'Quote__c') {
            console.log('Working Quote__c');
            callBack([
                { label: 'Resume', name: 'Resume' }]);

        } else if(pathName == 'Policy__c'){
            console.log('Else Policy__c');
            const handler1 = {};
            const proxy1 = new Proxy(row, handler1);  
            console.log(JSON.stringify(proxy1));  
            console.log(proxy1);
        
            if(proxy1?.Status_picklist__c == "Active"){
                const todayDate = new Date();

                // Assuming row.End_Date__c is in 'YYYY-MM-DD' format or a valid date string
                if (row.End_Date__c) {
                const endDate = new Date(row.End_Date__c); // Convert End_Date__c to a Date object

                 // Check if End_Date__c is less than today
                  if (endDate < todayDate) {
                     callBack([
                    { label: 'View', name: 'View' },
                    // { label: 'Edit', name: 'Edit' }
                    /*{ label: 'Terminate', name: 'Terminate' },*/
                    /*{ label: 'View Policy', name: 'ViewPolicy' },*/
                    ]);  
                   } else {
                        callBack([
                    { label: 'View', name: 'View' },
                    { label: 'Edit', name: 'Edit' },
                    { label: 'Terminate', name: 'Terminate' },
                    /*{ label: 'View Policy', name: 'ViewPolicy' },*/
                    ]);
                  }
                } 
            } else if(proxy1?.Status_picklist__c == "Terminated"){
                callBack([
                    { label: 'View', name: 'View' },
                    ]);
            }
            else if(proxy1?.Status_picklist__c == "Expired"){
                callBack([
                    { label: 'View', name: 'View' },
                    { label: 'Renew', name: 'Renew' },
                    ]);
            }
            else if(proxy1?.Status_picklist__c == "Updated"){
                     callBack([
                    { label: 'View', name: 'View' }
                    ]);  
            }
            else{
                callBack([
                    { label: 'View', name: 'View' },
                    { label: 'Edit', name: 'Edit' },
                    { label: 'Terminate', name: 'Terminate' },
                ]); 
            }       
        }

        
    }

    getCustomTableData() {
        const formattedRecords = [];
        this.records.forEach((record) => {
            const formattedRecord = {};
            Object.keys(record.fields).forEach((key) => {
                formattedRecord[key] = record.fields[key].value;
            });

            
            formattedRecords.push(formattedRecord);
        });
        return formattedRecords;
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log('actionName', actionName)
        switch (actionName) {
            case 'View':
                this.actionOpenRecord(row,'View');
                break;
            case 'Edit':
                this.actionOpenRecord(row,'Edit');
                break;
            case 'Resume':
                this.actionOpenRecord(row,'Resume');
                break;
            case 'Terminate':
                this.actionOpenRecord(row,'Terminate');
                break;
            case 'Renew':
                this.actionOpenRecord(row,'Renew');
                break;
            case 'ViewPolicy':
            this.actionOpenRecord(row,'ViewPolicy');
            break; 
                            
            default:
        }
    }

    handleSearch = (event) => {
        let searchKey = event.target.value.toLowerCase();
        if (searchKey) {
            let searchRecords = [];
            for (let record of this.customTableData) {
                let policyData = Object.values(record);
                for (let policy of policyData) {
                    let strVal = String(policy);
                    if (strVal) {
                        if (strVal.toLowerCase().includes(searchKey)) {
                            searchRecords.push(record);
                            break;
                        }
                    }
                }
            }
            this.customTableData = searchRecords;
        } else {
            this.customTableData = this.getCustomTableData();
        }
    }

    doSorting(event) {
        console.log('Do Sorting');
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);

        console.log(this.sortBy)
        console.log(this.sortDirection);
    }

    sortData(fieldname, direction) {
        console.log('Sort data');
        let parseData = this.customTableData;
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.customTableData = parseData;
    }  

    async actionOpenRecord(row, actionName) {
        console.log('Testing', basePath);
        console.log('actionOpenRecord Test');
        console.log(JSON.stringify(row));
        console.log('Data in a row---->',row);
        console.log(row.Id);
        let currentUrl = window.location.origin;
        let url;
        let navigate = true;
        if(actionName == 'View'){
            url = `policy/${row.Id}`;
        }else if(actionName == 'Edit'){
            url = `policy-edit-renew?c__policyId=${row.Id}&c__actionmode=edit`;
        }else if(actionName == 'Resume'){
            console.log('Record Id:',row.Id);
            await getLeadId({'recordId': row.Id}).then((data) => {
                console.log('data->',data);
                if(data != null){
                    console.log('Inside if of resume');
                    url = `quick-quote?c__contactId=${data}&c__actionmode=resumeLead`;
                }else{
                    console.log('Inside else of resume');
                    console.log('No data');
                }
            });
           
        }else if(actionName == 'Renew'){
            url = `policy-edit-renew?c__policyId=${row.Id}&c__actionmode=renew`;
        }else if(actionName == 'Terminate'){
            if(this.cmpSource == 'comm'){
                navigate = false;
                console.log('Inside Terminate---',currentUrl);
                sessionStorage.setItem('recordId', row.Id);
                console.log('Session Storage',sessionStorage.getItem('recordId'));
                location.replace(`${currentUrl}/agency/policy-terminate`);
            }else{
                url = `policy-terminate?c__obj=policy&c__action=TERMINATE&c__id=${row.Id}`;
            }
            
        }else if(actionName == 'ViewPolicy'){
            navigate = false;
            console.log('INSIDE VIEW POLICY');
            await validateandGenerateQuotePDF({ 'policyId': row.Id })
            .then((result) => {
                console.log('result-->',result);
                if (result) {
                    window.open(('/apex/' + result + '?id=' + row.Id), '_blank');
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
                console.log(error);
            });
        }

        console.log('URL---->',url);

        if(navigate == true){
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: `${basePath}/${url}`
                },
                state: {
                    recordId: row.Id
                }
            });
        }
        
    }

    connectedCallback() {
        console.log('Action buttonss')

        console.log('Working in connectedCallBack')
        if(this.customTableData != '') {
            console.log('working')
        } else {
            console.log('Not working')
        }

        console.log(this.pageName);
        console.log(this.object);
        
        let actionB = JSON.parse(JSON.stringify(this.actionBtn.split(',')));
        console.log(actionB);
        let actionBtnList = [];

        actionB.map(item => {
            console.log(item);
            let temp = {
                'label': item,
                'name': item
            }
            // console.log('temp', temp);
            actionBtnList.push(temp)
        })
        this.actionList = JSON.parse(JSON.stringify(actionBtnList));
        console.log(this.actionList);
        console.log('See |asdhfj', JSON.stringify(actionBtnList))
    }
}