## 2025-02-23 - Accessibility gaps in form help text
**Learning:** The app uses `small.form-text.text-muted` for help text but consistently fails to link them to inputs using `aria-describedby`. Also, time inputs are often placed next to date inputs without their own labels.
**Action:** When working on forms, systematically check for orphaned help text and unlabeled secondary inputs (like time fields) and link/label them.

## 2026-02-01 - Divs as interactive buttons
**Learning:** Found interactive elements (toggle buttons) implemented as `div`s with Stimulus actions but no keyboard support (tabindex, role) or semantic markup.
**Action:** Replace `div`s with `<button type="button">` when possible, preserving styles with utility classes to avoid breaking layout while gaining native accessibility.
