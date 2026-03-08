## 2025-02-23 - Accessibility gaps in form help text
**Learning:** The app uses `small.form-text.text-muted` for help text but consistently fails to link them to inputs using `aria-describedby`. Also, time inputs are often placed next to date inputs without their own labels.
**Action:** When working on forms, systematically check for orphaned help text and unlabeled secondary inputs (like time fields) and link/label them.

## 2025-03-08 - ARIA labels for icon-only link_to tags
**Learning:** In Rails apps using `link_to icon(...)` heavily, many icon-only links miss `aria-label`s. Because these are links with an empty or non-existent textual body, standard automated tools often miss them.
**Action:** When adding or auditing `link_to` tags that use the `icon()` helper without subsequent link text, explicitly add `aria: { label: '...' }` to the options hash.
