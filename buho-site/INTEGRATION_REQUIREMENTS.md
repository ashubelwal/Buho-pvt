# BÚHO Quote Wizard - Server Integration Requirements

## Overview
The current BÚHO components are UI-only. They need full server-side integration matching `nc_customerQuote` functionality.

## 1. Apex Classes Created

### BuhoQuoteFlow.cls
- `checkCommunityUserAndFetchDetails()` - Check if user is logged in, fetch existing data
- `saveLeadUserDetails()` - Save/update lead records
- `checkalreadyExistUserAction()` - Check if user/contact/lead already exists

## 2. Main Container (`buho_quoteWizard.js`) - NEEDS MAJOR UPDATES

### Add Apex Import
```javascript
import checkCommunityUserAndFetchDetails from '@salesforce/apex/BuhoQuoteFlow.checkCommunityUserAndFetchDetails';
```

### Update connectedCallback()
```javascript
async connectedCallback() {
    try {
        // Check if community user and fetch existing data
        const data = await checkCommunityUserAndFetchDetails();
        const parseData = JSON.parse(data);
        
        if (parseData.status == 'success' && parseData.userType) {
            const cleanedData = this.transformData(parseData);
            console.log('BQW Cleaned Data', cleanedData);

            // Pre-populate payload with existing data
            this.copyDataToPayload(cleanedData, ['userDetails']);
            this.copyDataToPayload(cleanedData, ['vehicleDetails']);
            this.copyDataToPayload(cleanedData, ['UserType']);
            this.copyDataToPayload(cleanedData, ['driverDetails']);

            // Skip first step if returning customer
            this.currentStep = 2;
        }
        
        this.childLoaded = false;
        await this.loadComponent();
    } catch (err) {
        this.childLoaded = true;
        console.error('BQW Error in connectedCallback:', err.message);
    }
}
```

### Add Transform Data Method (500+ lines from nc_customerQuote)
```javascript
transformData(apiResponse) {
    // Extract data from API response
    const vehicles = apiResponse.vehicles || [];
    const vehicle = vehicles?.[0] || {};
    const drivers = apiResponse.drivers || [];
    const contact = apiResponse.contact?.[0] || {};
    const towedUnits = apiResponse.towedUnits || [];

    // Transform and return structured data
    return [
        {
            UserType: {
                UserType: "Customer"
            }
        },
        {
            userDetails: {
                Email: contact.Email || apiResponse.email || null,
                FirstName: contact.FirstName || null,
                Phone: contact.Phone || contact.MobilePhone || null,
                LastName: contact.LastName || null,
                Id: contact.Id || null,
            }
        },
        {
            vehicleDetails: {
                // ... vehicle data transformation
            }
        },
        // ... other sections
    ];
}
```

### Add copyDataToPayload Method
```javascript
copyDataToPayload(cleanedData, keysToCopy) {
    // Copy specific keys from cleanedData to payload
    // Implementation from nc_customerQuote lines 512-552
}
```

## 3. User Details Component (`buho_userDetails.js`) - NEEDS UPDATES

### Add Apex Imports
```javascript
import saveLeadUserDetails from '@salesforce/apex/BuhoQuoteFlow.saveLeadUserDetails';
import checkalreadyExistUserAction from '@salesforce/apex/BuhoQuoteFlow.checkalreadyExistUserAction';
```

### Update handleEmailBlur()
```javascript
async handleEmailBlur() {
    try {
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: false }));
        
        const result = await checkalreadyExistUserAction({
            'leadDataItem': JSON.stringify(this.inputValues)
        });

        this.returnLeadValue = result;
        
        if (this.returnLeadValue?.LeadInfo) {
            // Transform and populate data
            const transformedData = this.createTransformedData();
            this.payload = transformedData;
            
            // Dispatch to parent
            this.dispatchEvent(new CustomEvent('fullpayloadupdate', {
                detail: transformedData,
                bubbles: true,
                composed: true
            }));
        } else if (this.returnLeadValue?.userData) {
            // User exists - show login message
            this.flag.isCustomer = true;
        } else if (this.returnLeadValue?.contactData) {
            // Contact exists - show create account message
            this.flag.customerWithPortalAccess = true;
        }
        
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
    } catch (err) {
        console.error('BUD Error:', err.message);
        this.dispatchEvent(new CustomEvent('loadingstatuschange', { detail: true }));
    }
}
```

### Update getData()
```javascript
@api async getData() {
    // Save lead data before returning
    await this.insertLeadData();
    
    this.inputValues = {
        ...this.inputValues,
        Company: 'Vehicle Insurance'
    };
    
    return this.inputValues;
}

async insertLeadData() {
    this.inputValues = {
        ...this.inputValues,
        Company: 'Vehicle Insurance'
    };

    await saveLeadUserDetails({ 
        strLeadDetails: JSON.stringify(this.inputValues) 
    }).then((result) => {
        if (result.Status === 'Success') {
            this.inputValues = result.Data;
        }
    }).catch((error) => {
        this.showToast('error', 'Error', 'Error saving lead data');
    });
}
```

## 4. Additional Required Methods in Child Components

### All child components need:
1. **Server-side data persistence** - Save data to Salesforce after validation
2. **Error handling** - Toast notifications for server errors
3. **Loading states** - Dispatch loading events to parent

## 5. Final Step - Quote Submission

### In `buho_quoteWizard.js` handleQuoteSubmission()
```javascript
handleQuoteSubmission() {
    // Save quote, vehicle, territory data to Salesforce
    // Call saveQuoteRecordData Apex method
    // Navigate to quote summary/confirmation page
}
```

## 6. Testing Checklist

- [ ] Guest user flow (new lead)
- [ ] Returning customer flow (existing contact/user)
- [ ] Lead data persistence at each step
- [ ] Error handling for Apex failures
- [ ] Loading states during server calls
- [ ] Data transformation for existing customers

## Implementation Priority

1. **HIGH**: Update `buho_quoteWizard.js` with community user check
2. **HIGH**: Update `buho_userDetails.js` with Apex integration
3. **MEDIUM**: Add data persistence to other child components
4. **MEDIUM**: Implement transformData() method
5. **LOW**: Add advanced error handling and retry logic

## Notes

- All Apex methods already exist in `BuhoQuoteFlow.cls`
- Pattern exactly matches `nc_customerQuote` → `NcExistingCustomerFlow`
- CSS loading already handled globally (no changes needed)
- Current UI structure is correct (only server integration needed)

