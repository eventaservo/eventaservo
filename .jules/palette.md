## 2024-06-07 - Add missing aria-labels to search form inputs
**Learning:** Found an accessibility issue where search input fields were lacking context for screen readers. In one case, the main search form input lacked an `aria-label` completely. In another case, the `aria-label` used was in English ("Search") instead of matching the primary language of the application ("Serĉi" - Esperanto), leading to confusing screen reader announcements.
**Action:** Always ensure search input forms have matching semantic labels (`aria-label` or `<label>`) and properly translate any `aria-` properties to match the native UI language.

## 2025-02-27 - Add aria-labels to isolated input fields
**Learning:** Found accessibility issues where isolated input fields (`text_field_tag`) relied solely on `placeholder` text for context, missing explicit `<label>` elements or `aria-label` attributes. Screen readers often skip placeholders or fail to announce them robustly when the user starts typing, resulting in a poor UX.
**Action:** Always provide an explicit `aria: { label: "..." }` to form inputs like `text_field_tag` if they don't have an associated semantic `<label>`. Specifically, ensure the labels are translated to the UI language (e.g., Esperanto in this application).
