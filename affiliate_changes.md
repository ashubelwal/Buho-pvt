# Production Deployment Checklist & Uncommitted Files

This document lists all currently uncommitted files in the repository (modified and untracked) and identifies the specific files required for the **Affiliate Portal Enhancement** production deployment.

---

## 🚀 Part 1: Files Required for Affiliate Portal Deployment

These files contain the new features, bug fixes, custom theming capabilities, and database schemas required to deploy the enhanced Affiliate Portal.

### 1. Database Schema & Fields
* **Custom Object Fields**:
  * [Theme_Primary_Color__c.field-meta.xml](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/objects/Affiliate__c/fields/Theme_Primary_Color__c.field-meta.xml) — Stores the hex value for the affiliate's primary branding color.
  * [Theme_Light_Color__c.field-meta.xml](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/objects/Affiliate__c/fields/Theme_Light_Color__c.field-meta.xml) — Stores the hex value for the affiliate's light background/theme color.
  * [Theme_Accent_Color__c.field-meta.xml](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/objects/Affiliate__c/fields/Theme_Accent_Color__c.field-meta.xml) — Stores the hex value for the affiliate's accent/interaction color.

### 2. Static Resources (Styling)
* **Static Resource Files**:
  * [AgentStyle.css](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/staticresources/AgentStyle.css) — Custom stylesheet providing CSS overrides for the enhanced portal (fixed sidebar widths, non-hover visible step labels, custom success checkmark sizing, and green check indicators).
  * [AgentStyle.resource-meta.xml](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/staticresources/AgentStyle.resource-meta.xml) — XML metadata file for the static resource.

### 3. Apex Controllers & Tests
* **Apex Classes**:
  * [AffiliateController.cls](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/classes/AffiliateController.cls) — Modified to query the new styling parameters (`Theme_Primary_Color__c`, etc.) and correctly map the `Affiliate__c` lookup relationship on created Leads.
  * [AffiliateControllerTest.cls](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/classes/AffiliateControllerTest.cls) — Updated test assertions to cover the Affiliate relationship assignment on Lead.
  * [AfterPolicyCreated.cls](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/classes/AfterPolicyCreated.cls) — Changed to run `without sharing` to bypass access restrictions during post-purchase asynchronous PDF generation.
  * [AfterPolicyCreatedTest.cls](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/classes/AfterPolicyCreatedTest.cls) — Supporting unit tests updated for coverage.

### 4. Lightning Web Components (LWC)
* **`affiliateQuickPolicy` Component (The Wizard Flow)**:
  * [affiliateQuickPolicy.html](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/lwc/affiliateQuickPolicy/affiliateQuickPolicy.html) — Structural changes.
  * [affiliateQuickPolicy.js](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/lwc/affiliateQuickPolicy/affiliateQuickPolicy.js) — Implements automatic scroll-to-top on step transitions, parses URL parameters (`hideHeader`, `hideSidebar`), queries active affiliate custom branding colors, and dynamically renders the enhanced layout.
  * [affiliateQuickPolicy.js-meta.xml](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/lwc/affiliateQuickPolicy/affiliateQuickPolicy.js-meta.xml) — Metadata definitions.
  * [enhanced.html](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/lwc/affiliateQuickPolicy/enhanced.html) — Secondary layout template dynamically rendered to hide/show the header and sidebar and apply inline/dynamic colors.

* **`affiliatePolicyQuickActions` Component (The Post-Purchase Page)**:
  * [affiliatePolicyQuickActions.html](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/lwc/affiliatePolicyQuickActions/affiliatePolicyQuickActions.html) — Updated actions.
  * [affiliatePolicyQuickActions.js](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/lwc/affiliatePolicyQuickActions/affiliatePolicyQuickActions.js) — Contains PDF print, download, and email dispatch logic. Now renders the confirmation card instead of instantly redirecting to the first page.
  * [affiliatePolicyQuickActions.css](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/lwc/affiliatePolicyQuickActions/affiliatePolicyQuickActions.css) — Custom LWC styles.
  * [enhanced.html](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/lwc/affiliatePolicyQuickActions/enhanced.html) — Enhanced layout with Bootstrap action buttons, SVG success logo, and customized UI.

* **`affiliateHeader` & `affiliatePolicyUtils`**:
  * [affiliateHeader.css](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/lwc/affiliateHeader/affiliateHeader.css)
  * [affiliateHeader.html](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/lwc/affiliateHeader/affiliateHeader.html)
  * [affiliateHeader.js](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/lwc/affiliateHeader/affiliateHeader.js)
  * [affiliatePolicyUtils.js](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/lwc/affiliatePolicyUtils/affiliatePolicyUtils.js)

---

## 📂 Part 2: Other Uncommitted Files in Repository

These files are modified or new but belong to the **Direct-to-Customer Portal (Buho Site)**, **Agent Dashboard / Partner Portal**, or general utilities. They should either be excluded from the Affiliate deployment or deployed as part of their respective releases.

### 1. Direct-to-Customer Portal (Buho Site)
* **Classes**:
  * [Mex_ShowSelectedQuotePdf.cls](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/buho-site/main/default/classes/Mex_ShowSelectedQuotePdf.cls)
  * [Mex_ShowSelectedQuotePdfTest.cls](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/buho-site/main/default/classes/Mex_ShowSelectedQuotePdfTest.cls)
  * [QuickQuotationCtrl.cls](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/buho-site/main/default/classes/QuickQuotationCtrl.cls)
* **Visualforce Pages**:
  * [selectedQuoteNewRate.page](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/buho-site/main/default/pages/selectedQuoteNewRate.page)
* **Lightning Web Components**:
  * [buho_driverDetails](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/buho-site/main/default/lwc/buho_driverDetails/)
  * [buho_input](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/buho-site/main/default/lwc/buho_input/)
  * [buho_login](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/buho-site/main/default/lwc/buho_login/)
  * [buho_quoteWizard](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/buho-site/main/default/lwc/buho_quoteWizard/)
  * [buho_towed](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/buho-site/main/default/lwc/buho_towed/)
  * [buho_userDetails](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/buho-site/main/default/lwc/buho_userDetails/)
  * [buho_vehicleDetails](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/buho-site/main/default/lwc/buho_vehicleDetails/)
  * [buhodb_policyCustomButtonComponent](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/buho-site/main/default/lwc/buhodb_policyCustomButtonComponent/)
  * [buhodb_policydetail](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/buho-site/main/default/lwc/buhodb_policydetail/)
  * [affiliate_quoteWizard](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/buho-site/main/default/lwc/affiliate_quoteWizard/)

### 2. Agent Dashboard & Partner Portal
* **Classes**:
  * [AgencyPortalController.cls](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/agent-dashboard/main/default/classes/AgencyPortalController.cls)
  * [AgencyPortalControllerBase.cls](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/agent-dashboard/main/default/classes/AgencyPortalControllerBase.cls)
* **Lightning Web Components**:
  * [agentEndorsement](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/agent-dashboard/main/default/lwc/agentEndorsement/)
  * [agentLogin](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/agent-dashboard/main/default/lwc/agentLogin/)
  * [agentQuickQuote](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/agent-dashboard/main/default/lwc/agentQuickQuote/)
  * [agentRenewals](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/agent-dashboard/main/default/lwc/agentRenewals/)
  * [agentUnderwriting](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/agent-dashboard/main/default/lwc/agentUnderwriting/)
  * [partnerProfile](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/agent-dashboard/main/default/lwc/partnerProfile/)
  * [policyEditRenew](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/agent-dashboard/main/default/lwc/policyEditRenew/)
* **Static Resources**:
  * [agentdashboardResource/css/style.css](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/agent-dashboard/main/default/staticresources/agentdashboardResource/css/style.css)
  * `agentdashboardResource/images/` (Chubb.png, Mapfre.png, Qualitas.png)

### 3. Shared/System Files & Email Templates
* **System Settings**:
  * [.prettierrc](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/.prettierrc)
  * [manifest/package.xml](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/manifest/package.xml)
* **Agent Core Classes**:
  * [AgentAppBaseService.cls](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/classes/AgentAppBaseService.cls)
  * [AgentAppController.cls](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/classes/AgentAppController.cls)
  * [AgentAppControllerTest.cls](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/classes/AgentAppControllerTest.cls)
  * [agentPolicyQuickActions.js](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/lwc/agentPolicyQuickActions/agentPolicyQuickActions.js)
  * [ag_quotePageCopy](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/lwc/ag_quotePageCopy/)
  * [agentConsoleWrapper](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/lwc/agentConsoleWrapper/)
* **Email Template Classes**:
  * [EmailTemplateStylingController.cls](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/classes/EmailTemplateStylingController.cls)
  * [EmailTemplateStylingControllerTest.cls](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/classes/EmailTemplateStylingControllerTest.cls)
  * [EmailTemplateStyling.component](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/components/EmailTemplateStyling.component)
  * [New_Policy_Purchase.email](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/email/unfiled$public/New_Policy_Purchase.email)
  * [New_Policy_Purchase_DriverLicense.email](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/email/unfiled$public/New_Policy_Purchase_DriverLicense.email)
  * [New_Policy_Purchase_Watercraft.email](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/email/unfiled$public/New_Policy_Purchase_Watercraft.email)
* **General Visualforce & Calculation Classes**:
  * [PropertyDamageCalculation.cls](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/classes/PropertyDamageCalculation.cls)
  * [Southbound_PolicyDecPage_Qualitas.page](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/pages/Southbound_PolicyDecPage_Qualitas.page)
  * [Southbound_PolicyDeclarationPage_Mapfre.page](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/pages/Southbound_PolicyDeclarationPage_Mapfre.page)
  * [test.page](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/pages/test.page)
  * [customToast.html](file:///Users/ashutoshbelwal/Documents/vsCode/Mex-Inscurance/force-app/main/default/lwc/customToast/customToast.html)

---

## 🛠️ Step 3: Deployed Packages & Deployment Order

When pushing changes to the Salesforce Sandbox or Production environment:

1. **Deploy Metadata Schema First**:
   * Deploy the fields on `Affiliate__c`: `Theme_Primary_Color__c`, `Theme_Light_Color__c`, `Theme_Accent_Color__c`.
2. **Deploy Classes and Static Resources**:
   * Deploy `AffiliateController.cls`, `AffiliateControllerTest.cls`, `AfterPolicyCreated.cls`, `AfterPolicyCreatedTest.cls`.
   * Deploy Static Resource `AgentStyle` (css stylesheet).
3. **Deploy Lightning Web Components**:
   * Deploy `affiliateHeader`, `affiliatePolicyUtils`, `affiliateQuickPolicy`, and `affiliatePolicyQuickActions`.
