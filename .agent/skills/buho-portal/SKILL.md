---
name: Buho Customer Portal Context
description: Provides context and architectural guidelines for working on the Buho Customer Portal (buho_quoteWizard and related components). Use this skill when making changes to the direct-to-customer quote flow.
---

# Buho Customer Portal Context

## Architecture
The Buho Customer Portal is a direct-to-customer quote and policy creation wizard.
- **Entry Point**: `buho_quoteWizard` LWC.
- **Components**: Utilizes a highly modular structure with single-purpose child components (e.g., `c-buho_userDetails`, `c-buho_vehicleDetails`, `c-buho_quotePage`, etc.).
- **Styling**: Implements the Buho Design System with vibrant primary blue (`#13203D`), accent pink (`#E53C7B`), and light blue (`#89DBEF`) defined in `buhoStyles.css`.

## Business Logic
- **Authentication**: Direct public access, no login required for guest quotes.
- **Pricing**: Does NOT charge an agent fee (`agentFee = 0`). Customers see the base price + taxes/fees, but no affiliate markups.
- **Apex Controller**: Uses `CustomerQuoteFlow` and `NcExistingCustomerFlow`.

## Shared Components
- The `buho_*` step components are shared with the Affiliate Portal.
- When modifying these components, **ensure backward compatibility** with the Affiliate Portal (e.g., dynamic theming via CSS variables should remain intact, and `agentFee` logic should gracefully default to 0 if not present).

## Rules
- Focus on a vibrant, modern, glassmorphic UI with smooth animations.
- Rely on standard CSS variables from `buhoStyles.css` (`--primary-blue`, `--accent-pink`, etc.).
