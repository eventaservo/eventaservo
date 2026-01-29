## 2025-02-23 - Accessibility gaps in form help text
**Learning:** The app uses `small.form-text.text-muted` for help text but consistently fails to link them to inputs using `aria-describedby`. Also, time inputs are often placed next to date inputs without their own labels.
**Action:** When working on forms, systematically check for orphaned help text and unlabeled secondary inputs (like time fields) and link/label them.

## 2025-02-23 - Orphaned Help Text Fix
**Learning:** Found several instances of `small.form-text.text-muted` that were not programmatically associated with their inputs using `aria-describedby`.
**Action:** systematically use `aria-describedby` on inputs pointing to the id of the help text.
