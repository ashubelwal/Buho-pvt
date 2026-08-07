---
name: Affiliate Portal Context
description: Provides context and architectural guidelines for working on the Affiliate Portal (affiliate_quoteWizard and related components). Use this skill when making changes to the white-labeled iframe affiliate portal.
---

# Affiliate Portal Context

## Architecture
The Affiliate Portal is built around the `affiliate_quoteWizard` isolated wizard shell or the `affiliateQuickPolicy` LWC wizard. It is designed to be embedded in partner websites via iframe.
- **Entry Point**: `affiliate_quoteWizard` LWC or `affiliateQuickPolicy` LWC.
- **Components**: Reuses step components from the customer portal (e.g., `buho_userDetails`, `buho_vehicleDetails`, etc.) loaded dynamically via `lwc:component lwc:is`.
- **Dynamic Templates**: Enhanced components use a multi-template approach (using `render()` in LWC to load `enhanced.html` when `isEnhanced` is enabled, and falling back to default template otherwise).
- **Auto-Scrolling**: Navigation transitions automatically trigger window and container scroll-to-top actions to prevent page positioning issues.
- **Lead Conversion Safety**: Upon Lead conversion, the portal connectedCallback identifies the converted status (`ConvertedContactId` populated) and retrieves the policy ID from the Quotes subquery to automatically route the user to the Step 7 Confirmation screen, avoiding page reset loops.

## Styling & Theming
- **Theming**: The wrapper `div.theme-wrapper` or `.enhanced-wizard-wrapper` receives dynamic CSS variables based on `Affiliate__c` custom fields (`Theme_Primary_Color__c`, `Theme_Accent_Color__c`, `Theme_Light_Color__c`).
- **Enhanced Styling**: Uses the `AgentStyle.css` static resource stylesheet along with Bootstrap styling (grids, rows, cols) for modern responsive spacing and layout configurations.
- **Sidebar**: The sidebar is styled with a fixed width of `240px` and constant visibility of step labels, using green checkmark icons for completed stages.
- **URL Overrides**: URL parameters `hideHeader=true` and `hideSidebar=true` can be passed to dynamically strip out layout chrome for deep embedding.

## Component & Asset Map
- **[affiliateQuickPolicy](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/lwc/affiliateQuickPolicy)**: The main wizard wrapper which switches between the accordion-based default layout and the 7-step wizard layout (`enhanced.html`).
- **[affiliatePolicyQuickActions](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/lwc/affiliatePolicyQuickActions)**: Confirmation page actions, switching to `enhanced.html` and `affiliatePolicyQuickActions.css` to render an animated success checkmark card and PDF download action.
- **[AgentStyle.css](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/staticresources/AgentStyle.css)**: The primary static stylesheet governing the wizard layout, sidebar metrics, active states, and custom transitions.

## Business Logic
- **Authentication**: Direct public access via URL parameter `?code=AFFILIATE_ID`.
- **Pricing**: Includes `Agent_Fee__c` in the total price shown to the customer. This fee must be explicitly queried from `Affiliate__c` and injected into the payload.
- **Apex Controller**: Uses `AffiliateController.cls` (e.g., `getAffiliateUser`, `saveLeadDetails`).

## Rules
- **DO NOT** hardcode pink/blue buho styles in affiliate-specific containers.
- **ALWAYS** pass the `agentFee` through the shared payload to ensure `buho_quotePage` calculates totals correctly.
- **ALWAYS** query and check `ConvertedContactId` on Leads during initial load to prevent user redirection to Step 1 post-transaction.
- Ensure any modifications to shared `buho_*` components do not break the customer portal flow, which operates with `agentFee = 0`.
