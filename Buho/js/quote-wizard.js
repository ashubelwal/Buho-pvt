/**
 * Quote Wizard JavaScript
 * Multi-step form wizard for BÚHO Insurance
 */

// =============================================================================
// State Management
// =============================================================================

const wizardState = {
    currentStep: 1,
    totalSteps: 4,
    data: {
        user: {},
        vehicle: {},
        dates: {},
        territory: 'baja-extended'
    }
};

// =============================================================================
// DOM Elements
// =============================================================================

const elements = {
    steps: document.querySelectorAll('.wizard-step'),
    progressSegments: document.querySelectorAll('.progress-segment'),
    currentStepEl: document.getElementById('currentStep'),
    totalStepsEl: document.getElementById('totalSteps'),
    backBtn: document.getElementById('backBtn'),
    termButtons: document.querySelectorAll('.term-btn'),
    timeSelection: document.getElementById('timeSelection'),
    territoryCards: document.querySelectorAll('.territory-card')
};

// =============================================================================
// Initialization
// =============================================================================

function init() {
    // Set total steps
    if (elements.totalStepsEl) {
        elements.totalStepsEl.textContent = wizardState.totalSteps;
    }

    // Initialize date pickers
    initDatePickers();

    // Initialize time pickers
    initTimePickers();

    // Populate vehicle year dropdown
    populateYearDropdown();

    // Setup event listeners
    setupEventListeners();

    // Update UI for current step
    updateUI();
}

// =============================================================================
// Date & Time Pickers
// =============================================================================

function initDatePickers() {
    const datepickers = document.querySelectorAll('.datepicker');
    
    datepickers.forEach(picker => {
        flatpickr(picker, {
            dateFormat: 'm/d/Y',
            minDate: 'today',
            disableMobile: true,
            onChange: function(selectedDates, dateStr, instance) {
                // Auto-set end date based on term type
                if (instance.element.id === 'startDate') {
                    updateEndDate(selectedDates[0]);
                }
            }
        });
    });
}

function initTimePickers() {
    const timepickers = document.querySelectorAll('.timepicker');
    
    timepickers.forEach(picker => {
        flatpickr(picker, {
            enableTime: true,
            noCalendar: true,
            dateFormat: 'h:i K',
            time_24hr: false,
            disableMobile: true
        });
    });
}

function updateEndDate(startDate) {
    if (!startDate) return;

    const endDatePicker = document.getElementById('endDate');
    const termType = document.querySelector('.term-btn.active')?.dataset.term || 'daily';
    
    let endDate = new Date(startDate);
    
    switch (termType) {
        case 'daily':
            endDate.setDate(endDate.getDate() + 1);
            break;
        case 'semi-annual':
            endDate.setMonth(endDate.getMonth() + 6);
            break;
        case 'annual':
            endDate.setFullYear(endDate.getFullYear() + 1);
            break;
    }

    // Update the end date picker
    const fp = endDatePicker._flatpickr;
    if (fp) {
        fp.setDate(endDate);
    }
}

// =============================================================================
// Vehicle Year Dropdown
// =============================================================================

function populateYearDropdown() {
    const yearSelect = document.getElementById('vehicleYear');
    if (!yearSelect) return;

    const currentYear = new Date().getFullYear();
    const startYear = currentYear + 1; // Allow next year
    const endYear = 1990;

    for (let year = startYear; year >= endYear; year--) {
        const option = document.createElement('option');
        option.value = year;
        option.textContent = year;
        yearSelect.appendChild(option);
    }
}

// =============================================================================
// Event Listeners
// =============================================================================

function setupEventListeners() {
    // Back button
    if (elements.backBtn) {
        elements.backBtn.addEventListener('click', (e) => {
            e.preventDefault();
            prevStep();
        });
    }

    // Term type buttons
    elements.termButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            elements.termButtons.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');

            // Show/hide time selection for daily
            if (btn.dataset.term === 'daily') {
                elements.timeSelection?.classList.add('visible');
            } else {
                elements.timeSelection?.classList.remove('visible');
            }

            // Update end date if start date is selected
            const startDatePicker = document.getElementById('startDate');
            if (startDatePicker?._flatpickr?.selectedDates[0]) {
                updateEndDate(startDatePicker._flatpickr.selectedDates[0]);
            }

            wizardState.data.dates.termType = btn.dataset.term;
        });
    });

    // Territory cards
    elements.territoryCards.forEach(card => {
        card.addEventListener('click', () => {
            elements.territoryCards.forEach(c => c.classList.remove('selected'));
            card.classList.add('selected');
            wizardState.data.territory = card.dataset.territory;
        });
    });

    // Vehicle value formatting
    const vehicleValue = document.getElementById('vehicleValue');
    if (vehicleValue) {
        vehicleValue.addEventListener('input', (e) => {
            let value = e.target.value.replace(/[^0-9]/g, '');
            if (value) {
                value = parseInt(value).toLocaleString('en-US');
            }
            e.target.value = value;
        });
    }

    // Vehicle make change - populate models
    const vehicleMake = document.getElementById('vehicleMake');
    if (vehicleMake) {
        vehicleMake.addEventListener('change', (e) => {
            populateModels(e.target.value);
        });
    }

    // Phone number formatting
    const phoneInput = document.getElementById('phone');
    if (phoneInput) {
        phoneInput.addEventListener('input', (e) => {
            let value = e.target.value.replace(/\D/g, '');
            if (value.length > 10) {
                value = value.substring(0, 10);
            }
            if (value.length >= 6) {
                value = `(${value.substring(0, 3)}) ${value.substring(3, 6)}-${value.substring(6)}`;
            } else if (value.length >= 3) {
                value = `(${value.substring(0, 3)}) ${value.substring(3)}`;
            }
            e.target.value = value;
        });
    }
}

// =============================================================================
// Vehicle Models (Sample Data)
// =============================================================================

const vehicleModels = {
    acura: ['Integra', 'MDX', 'RDX', 'TLX', 'NSX'],
    audi: ['A3', 'A4', 'A6', 'Q3', 'Q5', 'Q7', 'e-tron'],
    bmw: ['3 Series', '5 Series', 'X3', 'X5', 'X7', 'iX'],
    chevrolet: ['Silverado', 'Tahoe', 'Suburban', 'Equinox', 'Traverse', 'Colorado'],
    ford: ['F-150', 'Explorer', 'Escape', 'Bronco', 'Mustang', 'Edge'],
    honda: ['Civic', 'Accord', 'CR-V', 'Pilot', 'HR-V', 'Odyssey'],
    hyundai: ['Elantra', 'Sonata', 'Tucson', 'Santa Fe', 'Palisade'],
    jeep: ['Wrangler', 'Grand Cherokee', 'Cherokee', 'Compass', 'Gladiator'],
    kia: ['Seltos', 'Sportage', 'Sorento', 'Telluride', 'K5'],
    mazda: ['Mazda3', 'CX-30', 'CX-5', 'CX-50', 'CX-9'],
    mercedes: ['C-Class', 'E-Class', 'GLC', 'GLE', 'S-Class'],
    nissan: ['Altima', 'Sentra', 'Rogue', 'Pathfinder', 'Frontier'],
    subaru: ['Outback', 'Forester', 'Crosstrek', 'Impreza', 'Ascent'],
    tesla: ['Model 3', 'Model Y', 'Model S', 'Model X', 'Cybertruck'],
    toyota: ['Camry', 'Corolla', 'RAV4', 'Highlander', 'Tacoma', '4Runner'],
    volkswagen: ['Jetta', 'Passat', 'Tiguan', 'Atlas', 'ID.4']
};

function populateModels(make) {
    const modelSelect = document.getElementById('vehicleModel');
    if (!modelSelect) return;

    // Clear existing options
    modelSelect.innerHTML = '<option value="">Select Model</option>';

    // Add models for selected make
    const models = vehicleModels[make] || [];
    models.forEach(model => {
        const option = document.createElement('option');
        option.value = model.toLowerCase().replace(/\s+/g, '-');
        option.textContent = model;
        modelSelect.appendChild(option);
    });
}

// =============================================================================
// Navigation
// =============================================================================

function nextStep() {
    // Validate current step
    if (!validateStep(wizardState.currentStep)) {
        return;
    }

    // Save current step data
    saveStepData(wizardState.currentStep);

    // Move to next step or redirect to summary page
    if (wizardState.currentStep < wizardState.totalSteps) {
        wizardState.currentStep++;
        updateUI();
    } else if (wizardState.currentStep === wizardState.totalSteps) {
        // Save all data to sessionStorage and redirect to quote summary
        sessionStorage.setItem('quoteData', JSON.stringify(wizardState.data));
        window.location.href = 'quote-summary.html';
    }
}

function prevStep() {
    if (wizardState.currentStep > 1) {
        wizardState.currentStep--;
        updateUI();
    } else {
        // Go back to previous page
        window.history.back();
    }
}

function goToStep(step) {
    if (step >= 1 && step <= wizardState.totalSteps) {
        wizardState.currentStep = step;
        updateUI();
    }
}

// =============================================================================
// UI Updates
// =============================================================================

function updateUI() {
    // Update step visibility
    elements.steps.forEach((step, index) => {
        step.classList.toggle('active', index + 1 === wizardState.currentStep);
    });

    // Update progress bar
    elements.progressSegments.forEach((segment, index) => {
        const stepNum = index + 1;
        segment.classList.remove('active', 'completed');
        
        if (stepNum < wizardState.currentStep) {
            segment.classList.add('completed');
        } else if (stepNum === wizardState.currentStep) {
            segment.classList.add('active');
        }
    });

    // Update step counter
    if (elements.currentStepEl) {
        elements.currentStepEl.textContent = wizardState.currentStep;
    }

    // Scroll to top
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

// =============================================================================
// Validation
// =============================================================================

function validateStep(step) {
    switch (step) {
        case 1:
            return validateUserDetailsForm();
        case 2:
            return validateVehicleForm();
        case 3:
            return validateDatesForm();
        case 4:
            return validateTerritoryForm();
        default:
            return true;
    }
}

function validateUserDetailsForm() {
    const email = document.getElementById('userEmail')?.value;
    const firstName = document.getElementById('firstName')?.value;
    const lastName = document.getElementById('lastName')?.value;
    const phone = document.getElementById('phone')?.value;

    if (!email || !firstName || !lastName || !phone) {
        alert('Please fill in all required fields.');
        return false;
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        alert('Please enter a valid email address.');
        return false;
    }

    // Validate phone (at least 10 digits)
    const phoneDigits = phone.replace(/\D/g, '');
    if (phoneDigits.length < 10) {
        alert('Please enter a valid phone number.');
        return false;
    }

    return true;
}

function validateVehicleForm() {
    const vehicleType = document.getElementById('vehicleType')?.value;
    const vehicleYear = document.getElementById('vehicleYear')?.value;
    const vehicleMake = document.getElementById('vehicleMake')?.value;
    const vehicleModel = document.getElementById('vehicleModel')?.value;
    const vehicleValue = document.getElementById('vehicleValue')?.value;

    if (!vehicleType || !vehicleYear || !vehicleMake || !vehicleModel || !vehicleValue) {
        alert('Please fill in all vehicle information fields.');
        return false;
    }

    return true;
}

function validateDatesForm() {
    const startDate = document.getElementById('startDate')?.value;
    const endDate = document.getElementById('endDate')?.value;

    if (!startDate || !endDate) {
        alert('Please select start and end dates.');
        return false;
    }

    return true;
}

function validateTerritoryForm() {
    const selectedTerritory = document.querySelector('.territory-card.selected');
    
    if (!selectedTerritory) {
        alert('Please select a territory.');
        return false;
    }

    return true;
}

// =============================================================================
// Data Management
// =============================================================================

function saveStepData(step) {
    switch (step) {
        case 1:
            wizardState.data.user = {
                email: document.getElementById('userEmail')?.value,
                firstName: document.getElementById('firstName')?.value,
                lastName: document.getElementById('lastName')?.value,
                countryCode: document.getElementById('countryCode')?.value,
                phone: document.getElementById('phone')?.value
            };
            break;
        case 2:
            wizardState.data.vehicle = {
                type: document.getElementById('vehicleType')?.value,
                year: document.getElementById('vehicleYear')?.value,
                make: document.getElementById('vehicleMake')?.value,
                model: document.getElementById('vehicleModel')?.value,
                value: document.getElementById('vehicleValue')?.value,
                hybridElectric: document.getElementById('hybridElectric')?.checked,
                driversUnder21: document.getElementById('driversUnder21')?.checked,
                businessSignage: document.getElementById('businessSignage')?.checked,
                salvageTitle: document.getElementById('salvageTitle')?.checked,
                rentalVehicle: document.getElementById('rentalVehicle')?.checked,
                towingAnything: document.getElementById('towingAnything')?.checked
            };
            break;
        case 3:
            wizardState.data.dates = {
                termType: document.querySelector('.term-btn.active')?.dataset.term,
                startDate: document.getElementById('startDate')?.value,
                endDate: document.getElementById('endDate')?.value,
                startTime: document.getElementById('startTime')?.value,
                endTime: document.getElementById('endTime')?.value
            };
            break;
        case 4:
            wizardState.data.territory = document.querySelector('.territory-card.selected')?.dataset.territory;
            break;
    }
}


// =============================================================================
// Initialize on DOM Ready
// =============================================================================

document.addEventListener('DOMContentLoaded', init);

// Make functions globally accessible
window.nextStep = nextStep;
window.prevStep = prevStep;
window.goToStep = goToStep;

