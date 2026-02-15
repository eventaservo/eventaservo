## 2025-02-23 - Accessibility gaps in form help text
**Learning:** The app uses `small.form-text.text-muted` for help text but consistently fails to link them to inputs using `aria-describedby`. Also, time inputs are often placed next to date inputs without their own labels.
**Action:** When working on forms, systematically check for orphaned help text and unlabeled secondary inputs (like time fields) and link/label them.

## 2026-02-15 - Interactive elements using non-semantic tags
**Learning:** The "Mi interesiĝas" button was implemented as a `div` with a click handler, making it inaccessible to keyboard users and screen readers.
**Action:** When working on interactive elements, check for `div` or `span` with click handlers and refactor them to `<button>` or `<a>` with appropriate attributes and styles.
