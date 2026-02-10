## 2025-02-23 - Accessibility gaps in form help text
**Learning:** The app uses `small.form-text.text-muted` for help text but consistently fails to link them to inputs using `aria-describedby`. Also, time inputs are often placed next to date inputs without their own labels.
**Action:** When working on forms, systematically check for orphaned help text and unlabeled secondary inputs (like time fields) and link/label them.

## 2025-02-25 - Icon-only links in navbar lack accessible names
**Learning:** The desktop navbar uses icon-only links (`<i>` inside `<a>`) with tooltips on the icon, but the `<a>` tag lacks an accessible name, making it announced as just "link" or the icon class by some screen readers.
**Action:** Always add `aria-label` to the `<a>` or `<button>` tag when it contains only an icon, ensuring the label matches the visible tooltip text.
