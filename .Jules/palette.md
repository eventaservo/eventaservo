## 2025-02-23 - Accessibility gaps in form help text
**Learning:** The app uses `small.form-text.text-muted` for help text but consistently fails to link them to inputs using `aria-describedby`. Also, time inputs are often placed next to date inputs without their own labels.
**Action:** When working on forms, systematically check for orphaned help text and unlabeled secondary inputs (like time fields) and link/label them.

## 2025-01-30 - Icon-only buttons and hardcoded text
**Learning:** Found icon-only buttons (calendar dropdown) lacking accessible names, making them invisible to screen readers. Also, the dropdown header text was hardcoded in Esperanto, bypassing i18n.
**Action:** Always check icon-only buttons for `aria-label`. Verify that user-facing text in views uses translation keys `t(...)` instead of raw strings.
