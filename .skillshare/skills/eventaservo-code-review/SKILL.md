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
1. **Ruby/Rails Patterns:** Ruby 3.4.8, Rails 8.1, `ApplicationService` pattern, YARD documentation for all methods.
2. **Documentation:** YARD in English for all new/modified methods/classes.
3. **Security:** Proper use of authorizations and data protection.
4. **UI/UX:** Compliance with patterns in `app/views/admin/mockups/`. **Exclusive use of Bootstrap 5.3.** Tailwind CSS is forbidden.
5. **Language:** Everything (variables, methods, comments, documentation) must be in **English**.
6. **Testing:** Read and apply `TEST_ARCHITECTURE.md` rules. Verify directory structure, namespacing conventions, fixtures preference over FactoryBot, and appropriate use of test templates. Missing tests for new behavior must be reported.
7. **Internationalization (i18n):** For every new or modified view file (`.html.erb`, `.turbo_stream.erb`), verify that all user-facing strings use `t()` or `I18n.t()` instead of hardcoded text. Check that corresponding keys exist in the locale files for the three supported languages (eo, en, pt_BR). This is evaluated in its own dedicated section and does not block PRs.

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

### 🧪 Test Assessment

Evaluate tests against `TEST_ARCHITECTURE.md` rules. Test failures are not counted here — the focus is on **coverage and compliance**.

| Criterion | Status | Notes |
|-----------|--------|-------|
| New behavior has tests | `<Yes/No/Partial>` | `<details>` |
| Correct directory structure | `<Yes/No/N/A>` | `<details>` |
| Proper namespacing | `<Yes/No/N/A>` | `<details>` |
| Fixtures preferred over FactoryBot | `<Yes/No/N/A>` | `<details>` |
| Test templates followed | `<Yes/No/N/A>` | `<details>` |

- **Missing tests:** `<list of files/scenarios that should have tests but don't, or "None">`
- **Compliance notes:** `<any deviations from TEST_ARCHITECTURE.md>`

**Test Score:** `<0-10>`

### 🌐 Internationalization (i18n)

Evaluate whether new or modified views are properly internationalized. This section does **not** block PRs but contributes to the overall quality assessment.

| File | Hardcoded strings found | Uses `t()` / `I18n.t()` | Locale keys present (eo, en, pt_BR) |
|------|------------------------|-------------------------|--------------------------------------|
| `<file_path>` | `<Yes/No>` | `<Yes/No/Partial>` | `<Yes/No/Partial>` |

- **Details:** `<list specific hardcoded strings and missing locale keys, or "All views properly internationalized.">`

**i18n Score:** `<0-10>`

---

## 🏁 CONCLUSIONS (MANDATORY)

| Metric | Score |
|--------|-------|
| **Overall Rating** | `<0-10>` |
| **Test Score** | `<0-10>` |
| **i18n Score** | `<0-10>` |

The **Overall Rating** reflects the general quality of the code (architecture, patterns, security, documentation). The **Test Score** and **i18n Score** are independent assessments that complement the overall picture. A low Test or i18n score does not automatically block a PR, but should be flagged for attention.

**Verdict:**
- **PR Mode:** `<APPROVE | REQUEST CHANGES | COMMENT>`
- **Pre-PR Mode:** `<READY FOR SUBMISSION | ADJUSTMENTS NEEDED>`

**Executive Summary:**
`<Small summary for quick reading (2-3 lines) synthesizing the overall state of the code, including test and i18n status.>`

---

## Guidelines for AI (Mandatory)

1. **ALWAYS** show the `🏁 CONCLUSIONS` section at the end, with all three scores (Overall, Test, i18n), Verdict, and Executive Summary. Never omit this part.
2. **Analyze the current code**, ignoring whether it is staged or not. The goal is to validate what will be sent in the end.
3. **Detect stacked branches**: If the base is a branch other than `main`, make sure to compare only the delta of the current branch using the merge base point.
4. **Consult Mockups**: Before criticizing UI, check if the code follows the patterns in `app/views/admin/mockups/`.
5. **Be specific**: Reference files and lines.
6. **Test Assessment**: Read `TEST_ARCHITECTURE.md` before evaluating tests. Missing tests for new behavior must always be reported in the Test Assessment section, never as Critical or Recommendations. Test failures are out of scope.
7. **i18n Assessment**: For every changed `.html.erb` or `.turbo_stream.erb` file, scan for hardcoded user-facing strings (ignoring HTML attributes, CSS classes, and data attributes). Report findings in the i18n section only, never as Critical or Recommendations. Check the locale files (`config/locales/`) for corresponding keys in all three languages (eo, en, pt_BR).
8. **Score independence**: The three scores are independent. A perfect Overall Rating (10) with a low i18n Score (2) is a valid outcome — it means the code is excellent but i18n needs work. Do not let i18n or test findings inflate/deflate the Overall Rating, and vice versa.
