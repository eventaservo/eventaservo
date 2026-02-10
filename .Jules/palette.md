## 2025-02-23 - Accessibility gaps in form help text
**Learning:** The app uses `small.form-text.text-muted` for help text but consistently fails to link them to inputs using `aria-describedby`. Also, time inputs are often placed next to date inputs without their own labels.
**Action:** When working on forms, systematically check for orphaned help text and unlabeled secondary inputs (like time fields) and link/label them.

## 2026-02-06 - Navbar icon-only links accessibility
**Learning:** The desktop navbar uses icon-only links (inside `d-lg-block` elements) which rely on tooltips (`title` on `i`) but lack accessible names (`aria-label`) for screen readers.
**Action:** When working on navigation or icon-only buttons, always ensure the container link/button has an `aria-label` and the icon itself is hidden from screen readers (`aria-hidden="true"`).
