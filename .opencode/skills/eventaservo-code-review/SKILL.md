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
6. **Testing:** Verify if tests follow `TEST_ARCHITECTURE.md` (fixtures over FactoryBot, proper namespacing).

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
