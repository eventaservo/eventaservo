## 2025-02-23 - Accessibility gaps in form help text
**Learning:** The app uses `small.form-text.text-muted` for help text but consistently fails to link them to inputs using `aria-describedby`. Also, time inputs are often placed next to date inputs without their own labels.
**Action:** When working on forms, systematically check for orphaned help text and unlabeled secondary inputs (like time fields) and link/label them.

## 2026-02-12 - Semantic misuse of Headings and Divs
**Learning:** Critical interactive elements like the "Interested" toggle were implemented as `div`s with JS handlers, and `h1` tags were used solely for icon sizing, creating severe accessibility barriers and outline confusion.
**Action:** Refactor such elements to `<button type="button">` with utility classes (e.g., `btn-link`) and replace `h1` with styled `span`s to restore semantic integrity without breaking visuals.
