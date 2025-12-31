/**
 * Quote Summary Page JavaScript
 */

// =============================================================================
// State
// =============================================================================

let quoteData = {};
let selectedTerm = 'semi-annual';
let selectedPrice = 322.50;

// =============================================================================
// Initialization
// =============================================================================

function init() {
    // Load quote data from sessionStorage
    const storedData = sessionStorage.getItem('quoteData');
    if (storedData) {
        quoteData = JSON.parse(storedData);
        console.log('Quote data loaded:', quoteData);
    }

    // Setup coverage card selection
    setupCoverageCards();

    // Setup option change handlers
    setupOptionHandlers();
}

// =============================================================================
// Coverage Card Selection
// =============================================================================

function setupCoverageCards() {
    const cards = document.querySelectorAll('.coverage-card');
    
    cards.forEach(card => {
        card.addEventListener('click', () => {
            // Remove selected from all cards
            cards.forEach(c => c.classList.remove('selected'));
            
            // Add selected to clicked card
            card.classList.add('selected');
            
            // Update selected term and price
            selectedTerm = card.dataset.term;
            selectedPrice = parseFloat(card.dataset.price);
            
            // Update buy button
            updateBuyButton();
        });
    });
}

// =============================================================================
// Option Handlers
// =============================================================================

function setupOptionHandlers() {
    const liabilitySelect = document.getElementById('combinedLiability');
    const medicalSelect = document.getElementById('medical');

    if (liabilitySelect) {
        liabilitySelect.addEventListener('change', () => {
            recalculatePrice();
        });
    }

    if (medicalSelect) {
        medicalSelect.addEventListener('change', () => {
            recalculatePrice();
        });
    }
}

// =============================================================================
// Price Calculation
// =============================================================================

function recalculatePrice() {
    // Base prices
    const basePrices = {
        'single': 187.50,
        'semi-annual': 322.50,
        'annual': 445.00
    };

    // Get current selections
    const liability = document.getElementById('combinedLiability')?.value || '200000';
    const medical = document.getElementById('medical')?.value || '10k-50k';

    // Calculate adjustment based on options
    let adjustment = 0;

    // Liability adjustments
    switch (liability) {
        case '100000': adjustment -= 20; break;
        case '300000': adjustment += 30; break;
        case '500000': adjustment += 75; break;
    }

    // Medical adjustments
    switch (medical) {
        case '5k': adjustment -= 15; break;
        case '50k-100k': adjustment += 25; break;
        case '100k+': adjustment += 50; break;
    }

    // Update prices on all cards
    const cards = document.querySelectorAll('.coverage-card');
    cards.forEach(card => {
        const term = card.dataset.term;
        const basePrice = basePrices[term];
        const newPrice = (basePrice + adjustment).toFixed(2);
        
        card.dataset.price = newPrice;
        card.querySelector('.coverage-card-price').textContent = `$${newPrice}`;
        
        // Update selected price if this is the selected card
        if (card.classList.contains('selected')) {
            selectedPrice = parseFloat(newPrice);
        }
    });

    updateBuyButton();
}

function updateBuyButton() {
    const priceEl = document.getElementById('buyPrice');
    if (priceEl) {
        priceEl.textContent = selectedPrice.toFixed(2);
    }
}

// =============================================================================
// Actions
// =============================================================================

function downloadQuotePDF() {
    // Simulate PDF download
    alert('Downloading Quote PDF...\n\nIn production, this would generate and download a PDF with your quote details.');
    console.log('Download PDF requested', { quoteData, selectedTerm, selectedPrice });
}

function emailQuotePDF() {
    const email = quoteData.user?.email || '';
    
    if (email) {
        alert(`Quote PDF will be sent to: ${email}\n\nIn production, this would send an email with the quote PDF attached.`);
    } else {
        alert('Email Quote PDF\n\nIn production, this would prompt for an email address and send the quote.');
    }
    
    console.log('Email PDF requested', { quoteData, selectedTerm, selectedPrice });
}

function proceedToPayment() {
    // Save final selection to sessionStorage
    const finalQuote = {
        ...quoteData,
        coverage: {
            term: selectedTerm,
            price: selectedPrice,
            liability: document.getElementById('combinedLiability')?.value,
            medical: document.getElementById('medical')?.value
        }
    };
    
    sessionStorage.setItem('finalQuote', JSON.stringify(finalQuote));
    
    // In production, redirect to payment page
    alert(`Proceeding to payment...\n\nTotal: $${selectedPrice.toFixed(2)}\nTerm: ${formatTerm(selectedTerm)}\n\nIn production, this would redirect to the payment gateway.`);
    
    console.log('Proceeding to payment', finalQuote);
}

function formatTerm(term) {
    const terms = {
        'single': 'Single Trip',
        'semi-annual': 'Semi-Annual',
        'annual': 'Annual'
    };
    return terms[term] || term;
}

// =============================================================================
// Initialize
// =============================================================================

document.addEventListener('DOMContentLoaded', init);

// Make functions globally accessible
window.downloadQuotePDF = downloadQuotePDF;
window.emailQuotePDF = emailQuotePDF;
window.proceedToPayment = proceedToPayment;

