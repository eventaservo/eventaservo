---
name: eventaservo-code-review
description: Reviews a Pull Request or validates local changes before opening a PR, following the eventaservo architecture and Rails patterns. Analyzes committed, staged, and unstaged changes.
argument-hint: "[base branch (default: auto-detect or main)]"
allowed-tools: Bash(git *), Bash(gh *), Read, Grep, Glob
---

# EventaServo Code Review & Pre-PR Check

This skill performs a deep analysis of changes to ensure the code follows EventaServo standards. It considers the current state of the code (including uncommitted changes) and compares it with the correct base branch.

## Step 1: Gather Context and Operation Mode

### 1.1 Identify Base Branch
If not provided as an argument, determine the base branch:
1. Check the upstream branch (`git rev-parse --abbrev-ref --symbolic-full-name @{u}`).
2. If none, try to identify if it was created from another branch (stacked branch) by comparing with recent local branches or use `main` as a fallback.

### 1.2 Collect Git Data
You must analyze **all** work done on the current branch relative to the base:
- **Total Changes (Committed + Staged + Unstaged):** Use `git diff $(git merge-base HEAD <base>)`.
- **Current Status:** `git status --short`.
- **PR Context:** `gh pr view --json title,url,number 2>/dev/null || echo "PRE_PR_MODE"`.

## Step 2: Understand the Changes and Requirements

1. **Link Issue:** First, check if the branch name or commits reference a GitHub issue (e.g., `#1234`). If so, use `gh issue view <number> --json title,url,number` to fetch details and validate acceptance criteria.
2. **Full Reading:** Read the changed files in their entirety to understand the context, not just the snippets in the diff.
3. **Layer Analysis:** Validate compliance with the responsibilities defined in `AGENTS.md`.

## Step 3: Apply Review Guidelines (AGENTS.md)

Rigorously validate:
1. **Ruby/Rails Patterns:** Ruby 3.4.9, Rails 8.1, `ApplicationService` pattern, YARD documentation for all methods.
2. **Documentation:** YARD in English for all new/modified methods/classes.
3. **Security:** Proper use of authorizations and data protection.
4. **UI/UX:** Compliance with patterns in `app/views/admin/mockups/`. **Exclusive use of Bootstrap 5.3.** Tailwind CSS is forbidden.
5. **Language:** Everything (variables, methods, comments, documentation) must be in **English**.
6. **Test Architecture Compliance:** Use `TEST_ARCHITECTURE.md` Section 7 (Code Review Checklist) to validate every changed or new test file:

   - [ ] **Directory**: File is in the correct directory per Section 2 (models, controllers, services, queries)?
     - Controllers: `test/controllers/<controller_name>/<action>_test.rb`
     - Namespaced controllers: `test/controllers/<namespace>/<controller>/<action>_test.rb` (e.g. `test/controllers/events/by_continent/show_test.rb`)
   - [ ] **Naming**: Class uses the correct namespace matching the file path?
     - Simple controllers: `EventsController::IndexTest`
     - Namespaced controllers: `Events::ByContinentController::ShowTest`
     - Inherits from `ActionDispatch::IntegrationTest` for controllers
   - [ ] **Data**: Uses fixtures instead of FactoryBot (unless justified)? Check `test/fixtures/` for existing fixtures.
   - [ ] **Test names**: Descriptive — clearly explain expected behavior?
   - [ ] **Assertions**: Specific and clear (e.g. `assert_redirected_to`, `assert_select`, not `assert_response 302`)?
   - [ ] **Responsibility**: Each file has ONE responsibility (one action per file)?
   - [ ] **Migration**: If migrating existing tests, follows Section 10 (migrate gradually, remove old file only after new one works)?

   Use `glob('test/**/*')` to list changed/new test files, then read them to verify.

## Step 4: Produce the Report

Present the report EXCLUSIVELY in English.

---

## 🔍 Analysis: `<branch_name>`

**Mode:** `<🚀 PR Review | 🛠️ Pre-PR Validation>`
**Comparison Base:** `<base_branch>`
**Issue:** `<GitHub Issue ID | "Not found">`
**Risk:** `<Low | Medium | High>` - `<justification>`

### 📝 Summary
`<2-3 sentence summary of what the changes do and if they meet the goal>`

### 🔴 Critical Issues (Blockers)
`<Issues that prevent merging or opening the PR. If none, "None found.">`

### 🟡 Recommendations (Major)
`<Important improvements to maintain project standards.>`

### 🟢 Minor Suggestions (Minor)
`<Style, readability, micro-optimizations.>`

### 🌟 What Went Well
`<Positive highlights of the implementation.>`

### 🧪 Test Coverage
- **New behavior covered?** `<Yes/No/Partial>`
- **Missing tests:** `<list of files/scenarios>`

### 📐 Test Architecture Compliance

Checklist based on `TEST_ARCHITECTURE.md` Section 7:

- **Directory structure** ✅/❌ — e.g., `test/controllers/events/by_city/show_test.rb` exists as a per-action file
- **Class naming** ✅/❌ — e.g., `Events::ByCityController::ShowTest`
- **Fixtures over FactoryBot** ✅/❌ — list any unjustified `create(:...)` calls
- **Descriptive test names** ✅/❌ — flag generic names
- **Specific assertions** ✅/❌ — flag `assert_response 302`, `assert events.any?`
- **Single responsibility per file** ✅/❌

---

## 🏁 CONCLUSIONS (MANDATORY)

**Overall Rating:** `<Score from 0 to 10>`

**Verdict:**
- **PR Mode:** `<APPROVE | REQUEST CHANGES | COMMENT>`
- **Pre-PR Mode:** `<READY FOR SUBMISSION | ADJUSTMENTS NEEDED>`

**Executive Summary:**
`<Small summary for quick reading (2-3 lines) synthesizing the overall state of the code.>`

---

## Guidelines for AI (Mandatory)

1. **ALWAYS** show the `🏁 CONCLUSIONS` section at the end, with Rating, Verdict, and Executive Summary. Never omit this part.
2. **Analyze the current code**, ignoring whether it is staged or not. The goal is to validate what will be sent in the end.
3. **Detect stacked branches**: If the base is a branch other than `main`, make sure to compare only the delta of the current branch using the merge base point.
4. **Consult Mockups**: Before criticizing UI, check if the code follows the patterns in `app/views/admin/mockups/`.
5. **Be specific**: Reference files and lines.
6. **Validate test architecture**: Always use `glob('test/**/*')` to find changed/new test files, read them, and cross-check each against the Step 3.6 checklist. Do NOT skip this step even if the diff is small.
