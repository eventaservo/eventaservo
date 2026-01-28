## 2025-02-23 - Accessibility gaps in form help text
**Learning:** The app uses `small.form-text.text-muted` for help text but consistently fails to link them to inputs using `aria-describedby`. Also, time inputs are often placed next to date inputs without their own labels.
**Action:** When working on forms, systematically check for orphaned help text and unlabeled secondary inputs (like time fields) and link/label them.

## 2026-01-28 - FontAwesome Verification
**Learning:** `font-awesome` is available via `font-awesome-sass` gem, but it's not explicitly in `package.json`.
**Action:** Always check `Gemfile` for asset gems when standard `package.json` dependencies are missing expected UI libraries.
