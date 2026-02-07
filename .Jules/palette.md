## 2025-02-23 - Accessibility gaps in form help text
**Learning:** The app uses `small.form-text.text-muted` for help text but consistently fails to link them to inputs using `aria-describedby`. Also, time inputs are often placed next to date inputs without their own labels.
**Action:** When working on forms, systematically check for orphaned help text and unlabeled secondary inputs (like time fields) and link/label them.

## 2025-02-23 - Inaccessible Modals and Icon Buttons
**Learning:** Found a recurring pattern of `webcalModal` usage across multiple views where the modal lacks `aria-labelledby`, the title ID is incorrect (copy-pasted `shareModalCenterTitle`), and icon-only trigger buttons lack `aria-label`.
**Action:** When working with modals or icon-only buttons, always verify `aria-labelledby` matches the title ID and ensure icon buttons have descriptive `aria-label`.
