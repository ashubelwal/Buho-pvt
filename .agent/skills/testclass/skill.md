---
name: "Salesforce Apex Minimal Test Class"
description: |
  Generate a compact Apex test class for a Salesforce Apex class or trigger that maximizes code coverage with minimal code.
  Focus on happy‑path execution, minimal test data, and low token usage.
  Do not cover all corner cases, edge cases, or negative scenarios unless strictly required for coverage.
scope: "salesforce"
tags: ["salesforce", "apex", "test", "coverage"]
---
## Goal

Given an Apex class or trigger, generate the smallest possible `@isTest` class that:
- Touches as many lines as possible with minimal setup.
- Uses happy‑path data only.
- Avoids exhaustive negative or bulk‑case testing.
- Helps satisfy Salesforce’s 75% deployment‑coverage bar without over‑engineering tests.

## When to use this skill

Use this skill when:
- You want a coverage‑oriented test to pass `sfdx` deployment or org validation.
- You do **not** need comprehensive behavior tests (positive/negative/bulk) yet.
- You want low‑token, low‑code tests that still exercise the main logic branches.

Do **not** use this skill when:
- You are doing long‑term quality assurance or release‑branch testing.
- You need full test coverage of business rules, validations, and edge cases.
- The stakeholder explicitly requires “best‑practice” full test suites.

## Step‑by‑step instructions

1. **Identify the target**  
   - If the user tags a file or snippet, assume it is the Apex class or trigger to test.
   - If the user names a class (`MyService`, `AccountTrigger`), look for that class or its trigger.

2. **Decide test structure**  
   - Create **one `@isTest` class** for that unit (e.g., `MyService_Test`).
   - Use `@testSetup` only if multiple test methods reuse the same data.
   - Aim for **1–2 test methods maximum** unless extra coverage is clearly needed.

3. **Minimize test data**  
   - Create only the records and fields that are strictly required to pass validations and execute the main logic.
   - Prefer `insert new Account(Name = 'Test')` style over elaborate factories unless they already exist.
   - Reuse existing `@testSetup` data if present.

4. **Optimize for coverage, not scenarios**  
   - Focus on one or two high‑value execution paths:
     - Happy‑path insert/update for triggers.
     - Main public method for classes.
   - Skip negative cases, validation‑error paths, and multiple bulk‑size scenarios unless explicitly requested.
   - Avoid loops or complex `for`‑block mocks just to “hit lines”.

5. **Use compact patterns**

   For a **service class**:
   ```apex
   @isTest
   private class MyService_Test {
       @testSetup
       static void setup() {
           // Insert minimal required records
           Account acc = new Account(Name = 'Test');
           insert acc;
       }

       @isTest
       static void test_main_flow() {
           Account acc = [SELECT Id, Name FROM Account LIMIT 1];

           Test.startTest();
           MyService.execute(acc.Id);
           Test.stopTest();

           // Very light assertion
           System.assertNotEquals(null, acc.Name);
       }
   }
   ```

   For a **trigger**:
   ```apex
   @isTest
   private class AccountTrigger_Test {
       @isTest
       static void test_insert_happy_path() {
           Test.startTest();
           insert new Account(Name = 'Test');
           Test.stopTest();

           System.assert(true, 'Happy‑path insert executed');
       }
   }
   ```

6. **Assertions (minimal)**  
   - Use assertions only where cheap and obvious:
     - `System.assertNotEquals(null, result)`
     - `System.assertEquals(expected, actual)` only if the value is simple and strongly typed.
   - Avoid long chains of assertions or coverage‑only assertions.

7. **Async / DML / `@future` / `Queueable` / `Schedulable`**  
   - Wrap async entry points in `Test.startTest()` / `Test.stopTest()`.
   - Do not try to test every possible async state or governor‑limit scenario.

8. **Avoid**  
   - Single class with 10+ test methods.
   - Highly branched `if‑else` generator logic in the tests.
   - Long comments or unnecessary logging.
   - Full‑blown factories or helper classes unless already present in the org.

## Output rules

- Return **only Apex test‑class code** unless the user explicitly asks for explanation.
- If the user wants both explanation and code, put the explanation above the code block and keep it short.
- Do **not** spend extra tokens on:
  - Testing every trigger event (insert/update/delete/undelete).
  - Coverage‑only `System.assert(true)`.
  - Fake bulk‑size tests (e.g., inserting 200 records) without a business reason.

## Example user prompt this skill expects

- “Create a minimal test class for `MyService` to maximize coverage with as little code as possible.”
- “Write a compact Apex test for `AccountTrigger` for deployment coverage, no edge cases.”