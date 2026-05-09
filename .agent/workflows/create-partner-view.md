---
description: Create a dynamic partner view HTML layout for an LWC component aligned to the Agent Portal theme via dual template rendering.
---

# Create Partner View Workflow

This workflow systematically generates a modernized UI layout for an existing Salesforce LWC component by grafting a custom "Agent Portal" template onto it via conditional rendering, preserving the component's original legacy SLDS appearance elsewhere.

1. **Understand Initial Component Structure**:
   - Run `view_file` on the target component's `.html` and `.js` files.
   - Map out the exact UI conditions, `if:true` bounds, loops, and raw `slds` datatables currently driving the layout.
   - Ensure you completely understand all data-bindings so no variable logic is accidentally rewritten.

2. **Generate `partner<ComponentName>.html`**:
   - Create a secondary HTML file via `write_to_file` located strictly alongside the existing standard `.html` component.
   - Strip out basic SLDS structures (`lightning-layout-items`, raw datatables) and rebuild the shell using modern Bootstrap `.section-card`, `.section-card-header`, and `<table class="data-table">` layout rules.
   - Ensure the new tables match the aesthetics laid out inside `agentdashboardResource/css/style.css`, specifically leveraging icons (`bi-person`, `bi-shield-check`) and stylized badge classes.
   - Maintain 100% data-binding fidelity.

3. **Wire Dual Template Loading**:
   - Utilize `multi_replace_file_content` to edit the component's Controller (`.js` file).
   - Ensure `api` is imported from `lwc`.
   - Setup `@api isAgentPortal = false;`.
   - Explicitly import both layout architectures at the very top of the script:
     ```javascript
     import defaultTemplate from './[originalName].html';
     import partnerTemplate from './partner[originalName].html';
     ```
   - Wire up the native `render()` lifecycle method:
     ```javascript
     render() {
         return this.isAgentPortal ? partnerTemplate : defaultTemplate;
     }
     ```

4. **Update Parent Container Injections**:
   - Check where the target component is actually rendered (like inside `agentContainer.html`).
   - Append the `is-agent-portal` tag cleanly so the container explicitly commands the child view to trigger the custom overlay: `<c-[component-name] is-agent-portal></c-[component-name]>`.
