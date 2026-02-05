## 2025-02-23 - Accessibility gaps in form help text
**Learning:** The app uses `small.form-text.text-muted` for help text but consistently fails to link them to inputs using `aria-describedby`. Also, time inputs are often placed next to date inputs without their own labels.
**Action:** When working on forms, systematically check for orphaned help text and unlabeled secondary inputs (like time fields) and link/label them.

## 2025-02-23 - Development Environment Configuration
**Learning:** The development server crashes without a Google Maps API key due to Timezone lookup. Setting `GOOGLE_MAPS_KEY=dummy` bypasses this.
**Action:** Use `GOOGLE_MAPS_KEY=dummy` when starting the server or running tasks if a real key is not available.
